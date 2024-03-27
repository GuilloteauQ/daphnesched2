#!/bin/bash

#SBATCH --job-name=daphnesched2
#SBATCH --nodes=1
#SBATCH --partition=xeon
#SBATCH --exclude=cl-node[001-004]
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=20
#              d-hh:mm:ss
#SBATCH --time=0-02:00:00
#SBATCH --wait

set -ex

NUM_THREADS=$1
SOURCEFILE=$2
MATRIX_PATH=$3
MATRIX_SIZE=$4
RESULT=$5

EXECUTABLE=$(dirname ${SOURCEFILE})/$(basename ${SOURCEFILE} .cpp)

singularity exec ${SLURM_SUBMIT_DIR}/jupycpp.sif g++ ${SLURM_SUBMIT_DIR}/${SOURCEFILE} -o ${SLURM_SUBMIT_DIR}/${EXECUTABLE} `pkg-config --cflags eigen3` -O3 -fopenmp

OMP_NUM_THREADS=${NUM_THREADS} srun --cpus-per-task=${NUM_THREADS} singularity exec ${SLURM_SUBMIT_DIR}/jupycpp.sif ${SLURM_SUBMIT_DIR}/${EXECUTABLE} ${SLURM_SUBMIT_DIR}/${MATRIX_PATH} ${MATRIX_SIZE} > ${SLURM_SUBMIT_DIR}/${RESULT}

exit 0
