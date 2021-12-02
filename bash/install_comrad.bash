#!/bin/bash
#SBATCH --output=install_comrad.log
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --time=00:05:57
#SBATCH --partition=gelifes
module load R

export OMP_NUM_THREADS=32

VERSION=${1}
R CMD INSTALL --preclean /data/$USER/fabrika/libs/comrad_${VERSION}.tar.gz

Rscript -e "utils::packageVersion(\"comrad\"); comrad::run_simulation(path_to_output = NULL, nb_gens = 1000, brute_force_opt = \"simd_omp\")"
