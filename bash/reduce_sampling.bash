#!/bin/bash
#SBATCH --partition=short
#SBATCH --output=/data/%u/fabrika/comrad_data/logs/reduce_sampling_%j.log

module load R

JOBID=$1
SAMPL_FRAC=$2

Rscript -e "source(\"/data/$USER/fabrika/R/reduce_sampling_hpc.R\"); reduce_sampling_hpc(job_id = \"${JOBID}\", new_sampling_frac = ${SAMPL_FRAC})"
