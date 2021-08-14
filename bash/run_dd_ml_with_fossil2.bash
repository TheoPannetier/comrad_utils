#!/bin/bash
#SBATCH --partition=short
#SBATCH --output=/data/%u/fabrika/comrad_data/logs/dd_ml_with_fossil_%j.log
#SBATCH --time=00:28:57
#SBATCH --array=1-1000

module load R

# COMRAD_V=$( Rscript -e "packageVersion(\"comrad\")" ) # version on the HPC
# DDD_V=$( Rscript -e "packageVersion(\"DDD\")" ) # version on the HPC
TIME_SUBM=$(date "+%Y-%m-%d %H:%M:%S")

# echo "${SLURM_JOB_ID},${TIME_SUBM},NA,NA,${SIGA},${SIGK},${DDMODEL},${TREE},${COMRAD_V},${DDD_V}" >> /data/${USER}/fabrika/comrad_data/logs/logbook_dd_ml_with_fossil2.csv

Rscript -e "source(\"/data/$USER/fabrika/R/run_dd_ml_array.R\"); run_dd_ml_array(func_name = \"run_dd_ml_hpc_with_fossil2\", task_id = ${SLURM_ARRAY_TASK_ID}, job_id = ${SLURM_JOB_ID}, logbook_file = \"/data/${USER}/fabrika/comrad_data/logs/logbook_dd_ml_with_fossil2.csv\", time_subm = \"${TIME_SUBM}\")"
