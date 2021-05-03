#!/bin/bash
#SBATCH --partition=gelifes
#SBATCH --output=/data/%u/fabrika/comrad_data/logs/dd_ml_without_fossil_%j.log
#SBATCH --time=04:58:00

module load R

SIGA=$1
SIGK=$2
DDMODEL=$3
TREE=$4
BATCH_ID=$5

COMRAD_V=$( Rscript -e "packageVersion(\"comrad\")" ) # version on the HPC
DDD_V=$( Rscript -e "packageVersion(\"DDD\")" ) # version on the HPC
TIME_SUBM=$(date "+%Y-%m-%d %H:%M:%S")

echo "${BATCH_ID},${SLURM_JOB_ID},${TIME_SUBM},NA,NA,${SIGA},${SIGK},${DDMODEL},${TREE},${COMRAD_V},${DDD_V}" >> /data/${USER}/fabrika/comrad_data/logs/logbook_dd_ml_without_fossil.csv

Rscript -e "source(\"/data/$USER/fabrika/R/run_dd_ml_hpc_without_fossil.R\"); run_dd_ml_hpc_without_fossil(siga = ${SIGA}, sigk = ${SIGK}, dd_model = comrad::dd_model_${DDMODEL}(), i = ${TREE}, job_id = ${SLURM_JOB_ID})"
