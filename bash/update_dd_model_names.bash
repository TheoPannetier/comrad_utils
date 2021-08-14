#!/bin/bash
#SBATCH --partition=gelifes
#SBATCH --output=update_dd_model_names.log
#SBATCH --time=04:28:00

module load R

WITH_FOSSIL=$1

Rscript -e "source(\"/data/$USER/fabrika/R/update_dd_model_name_rds.R\"); update_dd_model_name_rds(with_fossil = ${WITH_FOSSIL})"
