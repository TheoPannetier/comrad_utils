#!/bin/bash
#SBATCH --output=install_comsie.log
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --time=00:05:57
#SBATCH --partition=gelifes
module load R

export OMP_NUM_THREADS=32

VERSION=${1}
R CMD INSTALL --preclean /data/$USER/fabrika/libs/comsie_${VERSION}.tar.gz

Rscript -e "utils::packageVersion(\"comsie\"); comsie::run_simulation(path_to_output = NULL, nb_gens = 1000, immigration_rate = 0.01, brute_force_opt = \"simd_omp\")"
