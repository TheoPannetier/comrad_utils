#!/bin/bash
#SBATCH --partition=gelifes
#SBATCH --output=/data/%u/fabrika/comsie_data/daisie/logs/daisie_ml_%j.log
#SBATCH --time=9-23:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=64G

module load R

SIGA=$1
GAMMA=$2
REP=$3
F=$4
CS_OR_IW=IW
DDMODEL=$5
PARAMS_I=$6
N_CPUS=$SLURM_CPUS_PER_TASK
PATH_TO_DIR=/data/${USER}/fabrika/comsie_data/daisie

echo "${SLURM_JOB_ID},${TIME_SUBM},NA,NA,${SIGA},${GAMMA},${REP},${F},${CS_OR_IW},${DDMODEL},${PARAMS_I},NA,NA,${N_CPUS}" >> /data/${USER}/fabrika/comsie_data/daisie/logs/logbook_daisie_ml.csv

echo "\n${SLURM_JOB_ID} \n${SIGA} \n${GAMMA} \n${REP} \n${F} \n${CS_OR_IW} \n${DDMODEL} \n${PARAMS_I} \n"

module load R

Rscript -e "source(\"${PATH_TO_DIR}/fit_daisie_to_comsie.R\");DAISIE::DAISIE_IW_num_threads(${N_CPUS}); fit_daisie_to_comsie(siga_ibm = ${SIGA}, gamma_ibm = ${GAMMA}, replicate = ${REP}, f = ${F}, daisie_version = \"${CS_OR_IW}\", ddmodel = ${DDMODEL}, params_i = ${PARAMS_I}, path_to_dir = \"${PATH_TO_DIR}\", job_id = ${SLURM_JOB_ID})"
