#!/bin/bash
#SBATCH --partition=gelifes
#SBATCH --output=/data/%u/fabrika/comrad_data/logs/ml_%j.log
#SBATCH --time=00:58:00

SIGA=$1
SIGK=$2
DDMODEL=$3
TREE=$4

module load R

Rscript -e "source(\"/data/$USER/fabrika/R/run_dd_ml_hpc_without_fossil.R\"); run_dd_ml_hpc_without_fossil(siga = ${SIGA}, sigk = ${SIGK}, dd_model = comrad::dd_model_${DDMODEL}(), i = ${TREE})"
