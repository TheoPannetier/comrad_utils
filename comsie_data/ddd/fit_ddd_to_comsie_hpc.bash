#!/bin/bash
#SBATCH --partition=gelifes
#SBATCH --output=/data/%u/fabrika/comsie_data/ddd/logs/dd_ml_%j.log
#SBATCH --time=00:27:59

module load R

SIGA=$1
GAMMA=$2
REP=$3
F=$4
PARAMS_I=$5
PATH_TO_DIR=/data/${USER}/fabrika/comsie_data/ddd

echo "${SLURM_JOB_ID},${TIME_SUBM},NA,NA,${SIGA},${GAMMA},${REP},${F},${PARAMS_I},DD,NA,NA" >> /data/${USER}/fabrika/comsie_data/ddd/logs/logbook_ddd_ml.csv

module load R

Rscript -e "source(\"${PATH_TO_DIR}/fit_ddd_to_comsie.R\"); fit_ddd_to_comsie(siga_ibm = ${SIGA}, gamma_ibm = ${GAMMA}, replicate = ${REP}, f = ${F}, params_i = ${PARAMS_I}, path_to_dir = \"${PATH_TO_DIR}\", job_id = ${SLURM_JOB_ID})"
