#!/bin/bash
#SBATCH --time=69:57:55
#SBATCH --partition=gelifes
#SBATCH --mail-type=END,FAIL,TIME_LIMIT
#SBATCH --mail-user=t.s.c.pannetier@rug.nl
#SBATCH --output=/data/%u/comrad/data/logs/comrad_sim_%j.log

## Script description ##

## Parameters ##
NB_GENS=$1
SIG_A=$2
SIG_K=$3
K_OPT=$4
Z_OPT=$5
GROWTH=$6
PROB_MUT=$7
SIG_MU=$8
Z_DIST_SP=$9

## Write logbook entry ##

DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M:%S)

echo "${SLURM_JOB_ID},${DATE},${TIME},pending_check,NA,${NB_GENS},${SIG_A},${SIG_K},${K_OPT},${Z_OPT},${GROWTH},${PROB_MUT},${SIG_MU},${Z_DIST_SP}" >> /data/${USER}/comrad/data/logs/logbook.csv

## Some job info ##
echo "job ${SLURM_JOB_ID}\n"

OUTPUT=/data/${USER}/comrad/data/sims/comrad_sim_${SLURM_JOB_ID}.csv
echo "Output saved at ${OUTPUT}\n"

##  Run simulation ##

module load R

Rscript -e "comrad::run_simulation(path_to_output = \"${OUTPUT}\", nb_gens = ${NB_GENS}, competition_sd = ${SIG_A}, carrying_cap_sd = ${SIG_K}, carrying_cap_opt = ${K_OPT}, trait_opt = ${Z_OPT}, growth_rate = ${GROWTH}, prob_mutation = ${PROB_MUT}, mutation_sd = ${SIG_MU}, trait_dist_sp = ${Z_DIST_SP}, hpc_job_id = ${SLURM_JOB_ID})"
