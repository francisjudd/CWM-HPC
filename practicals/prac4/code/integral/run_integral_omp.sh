#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
#SBATCH --time=00:05:00
#SBATCH --job-name=integral

module purge
module load gcc/4.9.2

export OMP_NUM_THREADS=1

./integral_omp < integral.inp
./integral_omp < integral1.inp
./integral_omp < integral2.inp

export OMP_NUM_THREADS=2

./integral_omp < integral.inp
./integral_omp < integral1.inp
./integral_omp < integral2.inp

export OMP_NUM_THREADS=4

./integral_omp < integral.inp
./integral_omp < integral1.inp
./integral_omp < integral2.inp

export OMP_NUM_THREADS=8

./integral_omp < integral.inp
./integral_omp < integral1.inp
./integral_omp < integral2.inp

export OMP_NUM_THREADS=16

./integral_omp < integral.inp
./integral_omp < integral1.inp
./integral_omp < integral2.inp
