#!/bin/bash
#SBATCH --partition=gelifes
#SBATCH --output=/data/%u/fabrika/comrad_data/logs/ml_%j.log
#SBATCH --time=05:28:00

SIGA=$1
SIGK=$2
DDMODEL=$3

module load R

Rscript -e "source(\"/data/$USER/fabrika/R/run_dd_ml_hpc.R\"); run_dd_ml_hpc(siga = ${SIGA}, sigk = ${SIGK}, dd_model = comrad::dd_model_${DDMODEL}())"
