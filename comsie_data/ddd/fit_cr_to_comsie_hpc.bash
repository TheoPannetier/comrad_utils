#!/bin/bash
#SBATCH --partition=short
#SBATCH --output=/data/%u/fabrika/comsie_data/ddd/logs/cr_ml_%j.log
#SBATCH --time=01:57:59

module load R

SIGA=$1
GAMMA=$2
REP=$3
PARAMS_I=$4
PATH_TO_DIR=/data/${USER}/fabrika/comsie_data/ddd

module load R

Rscript -e "source(\"${PATH_TO_DIR}/fit_cr_to_comsie.R\"); fit_cr_to_comsie(siga_ibm = ${SIGA}, gamma_ibm = ${GAMMA}, replicate = ${REP}, params_i = ${PARAMS_I}, path_to_dir = \"${PATH_TO_DIR}\", job_id = ${SLURM_JOB_ID})"
