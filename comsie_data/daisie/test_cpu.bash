#!/bin/bash
#SBATCH --partition=short
#SBATCH --output=test_cpu.log
#SBATCH --time=00:02:00
#SBATCH --cpus-per-task=4

echo "${SLURM_CPUS_PER_TASK}"

