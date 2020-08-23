#!/bin/bash
#SBATCH --output=install_comrad.log --partition=short --time=00:09:59

module load R

Rscript -e "remotes::install_github(\"TheoPannetier/comrad\")"
