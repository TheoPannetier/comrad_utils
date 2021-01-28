#!/bin/bash
#SBATCH --partition=gelifes
#SBATCH --output=/data/%u/fabrika/comrad_data/logs/ml_%j.log
#SBATCH --time=05:28:00

SIGA=$1
SIGK=$2
DDMODSIM=$3
DDMODEL=$4

module load R

Rscript -e "source(\"/data/$USER/fabrika/R/run_dd_ml_hpc_simtrees.R\"); run_dd_ml_hpc_simtrees(siga = ${SIGA}, sigk = ${SIGK}, ddmod_sim = \"${DDMODSIM}\", dd_model = comrad::dd_model_${DDMODEL}())"
