#!/bin/bash
#SBATCH --partition=gelifes
#SBATCH --output=/data/%u/fabrika/comrad_data/logs/ddd_ml_%j.log
#SBATCH --mail-type=END,FAIL,TIME_LIMIT
#SBATCH --mail-user=t.s.c.pannetier@rug.nl
#SBATCH --time=15:28:00

SIGA=$1
SIGK=$2
DDMODEL=$3

module load R

Rscript -e "source(\"/data/$USER/fabrika/R/ddd_ml_hpc.R\"); ddd_ml_hpc(siga = ${SIGA}, sigk = ${SIGK}, ddmodel = ${DDMODEL})"
