#!/bin/bash
#SBATCH --partition=gelifes
#SBATCH --output=/data/%u/fabrika/comsie_data/logs/comsie_sim_%j.log

module load R

## Script description ##

## Parameters ##
NB_GENS=$2
IMMIG=$3
NB_SP_M=$4
Z_SD_M=$5
SIG_A=$6
SIG_K=$7
K_OPT=$8
Z_OPT=$9
GROWTH=${10}
SIG_MU=${11}
Z_DIST_SP=${12}
SAMPL_ON_EVENT=${13}
SAMPL_FREQ=${14}
SAMPL_FRAC=${15}
BRUTE_FORCE_OPT=${16}
SEED=${17}

## Write logbook entry ##
BATCH_ID=$1
TIME_SUBM=$(date "+%Y-%m-%d %H:%M:%S")
COMSIE_V=$( Rscript -e "packageVersion(\"comrad\")" ) # version on the HPC
COMRAD_V=$( Rscript -e "packageVersion(\"comsie\")" ) # version on the HPC

echo "${BATCH_ID},${SLURM_JOB_ID},${TIME_SUBM},pending_check,NA,${NB_GENS},${IMMIG},${NB_SP_M},${Z_SD_M},${SIG_A},${SIG_K},${K_OPT},${Z_OPT},${GROWTH},${SIG_MU},${Z_DIST_SP},${SEED},${COMRAD_V},${COMSIE_V},${SAMPL_ON_EVENT},${SAMPL_FREQ},${SAMPL_FRAC},${BRUTE_FORCE_OPT},NA" >> /data/${USER}/fabrika/comsie_data/logs/logbook_comsie.csv

## Some job info ##
echo "job ID ${SLURM_JOB_ID}\n"

OUTPUT=/data/${USER}/fabrika/comsie_data/sims/comsie_sim_${SLURM_JOB_ID}.csv
echo "Output saved at ${OUTPUT}\n\n"

##  Run simulation ##
Rscript -e "comsie::run_simulation(path_to_output = \"${OUTPUT}\", nb_gens = ${NB_GENS}, immigration_rate = ${IMMIG}, mainland_nb_species = ${NB_SP_M}, mainland_z_sd = ${Z_SD_M}, competition_sd = ${SIG_A}, carrying_cap_sd = ${SIG_K}, carrying_cap_opt = ${K_OPT}, trait_opt = ${Z_OPT}, growth_rate = ${GROWTH}, mutation_sd = ${SIG_MU}, trait_dist_sp = ${Z_DIST_SP}, hpc_job_id = ${SLURM_JOB_ID}, seed = ${SEED}, sampling_on_event = ${SAMPL_ON_EVENT}, sampling_freq = ${SAMPL_FREQ}, sampling_frac = ${SAMPL_FRAC}, brute_force_opt = \"${BRUTE_FORCE_OPT}\")"

