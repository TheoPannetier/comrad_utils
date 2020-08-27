#!/bin/bash
#SBATCH --output=install_comrad.log --partition=short --time=00:04:59

module load R

REF=${1:-master}

Rscript -e "remotes::install_github(\"TheoPannetier/comrad\", ref=\"${REF}\"); packageVersion(\"comrad\")"
