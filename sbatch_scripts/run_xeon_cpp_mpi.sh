#!/bin/bash

#SBATCH --job-name=daphnesched2
#SBATCH --partition=xeon
#SBATCH --exclude=cl-node[001-004]
#              d-hh:mm:ss
#SBATCH --time=0-02:00:00
#SBATCH --wait

set -ex

NUM_THREADS=$1
SOURCEFILE=$2
MATRIX_PATH=$3
MATRIX_SIZE=$4
RESULT=$5

EXECUTABLE=$(dirname ${SOURCEFILE})/$(basename ${SOURCEFILE} .cpp)_${NUM_THREADS}_mpi

CFLAGS=$(PKG_CONFIG_PATH=/share/pkgconfig singularity exec ${SLURM_SUBMIT_DIR}/jupycpp.sif pkg-config --cflags eigen3)

OPTIONS="${CFLAGS} -O3"

export UCX_TLS=self,sm
export OMPI_MCA_PML="ucx"
#export PMIX_MCA_gds="hash"
export PMIX_MCA_gds=^ds12 
export OMPI_MCA_gds=^ds12 
#export PMIX_MCA_btl="^openib,sm"
#export OMPI_MCA_btl="^openib,sm"
export PMIX_MCA_btl="self,vader"
export OMPI_MCA_btl="self,vader"
#export PMIX_DEBUG=1


singularity exec ${SLURM_SUBMIT_DIR}/jupycpp.sif mpic++ ${SLURM_SUBMIT_DIR}/${SOURCEFILE} -o ${SLURM_SUBMIT_DIR}/${EXECUTABLE} ${OPTIONS}

OMP_NUM_THREADS=${NUM_THREADS} srun --mpi=pmix_v4 --cpus-per-task=${NUM_THREADS} singularity exec ${SLURM_SUBMIT_DIR}/jupycpp.sif ${SLURM_SUBMIT_DIR}/${EXECUTABLE} ${SLURM_SUBMIT_DIR}/${MATRIX_PATH} ${MATRIX_SIZE} > ${SLURM_SUBMIT_DIR}/${RESULT}

exit 0
