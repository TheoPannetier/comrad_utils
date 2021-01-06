#!/bin/bash
#SBATCH --partition=gelifes
#SBATCH --output=/data/%u/fabrika/comrad_data/logs/ml_%j.log

SIGA=$1
SIGK=$2
DDMODEL=$3

module load R

Rscript -e "fabrika::run_dd_ml_hpc(siga = ${SIGA}, sigk = ${SIGK}, dd_model = ${DDMODEL})"
