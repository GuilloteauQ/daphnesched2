#!/bin/bash

#SBATCH --job-name=daphnesched2
#SBATCH --partition=xeon
#SBATCH --exclude=cl-node[001-004]
#              d-hh:mm:ss
#SBATCH --time=0-02:00:00
#SBATCH --wait

set -ex

export UCX_TLS=self,sm
export OMPI_MCA_PML="ucx"
#export PMIX_MCA_gds="hash"
export PMIX_MCA_gds=^ds12 
export OMPI_MCA_gds=^ds12 
#export PMIX_MCA_btl="vader,self"
#export OMPI_MCA_btl="vader,self"
export PMIX_MCA_btl="^openib,sm"
export OMPI_MCA_btl="^openib,sm"

#PARTITIONING=STATIC
#QUEUE_LAYOUT=CENTRALIZED
#VICTIM_SELECTION=SEQ

PARTITIONING=GSS
QUEUE_LAYOUT=CENTRALIZED
VICTIM_SELECTION=SEQ

NUM_THREADS=$1
SCRIPT=$2
MATRIX_PATH=$3
MATRIX_SIZE=$4 # unsued but kept to have the same api as for the other sbatch scripts
RESULT=$5


srun --mpi=pmix_v4 --cpus-per-task=${NUM_THREADS} singularity exec ${SLURM_SUBMIT_DIR}/daphne-dev.sif ${SLURM_SUBMIT_DIR}/daphne-src/bin/daphne --vec \
                      --distributed \
                      --num-threads=${NUM_THREADS} \
                      --dist_backend=MPI \
                      --select-matrix-repr \
                      --partitioning=${PARTITIONING} \
                      --queue_layout=${QUEUE_LAYOUT} \
                      --victim_selection=${VICTIM_SELECTION} \
                      ${SLURM_SUBMIT_DIR}/${SCRIPT} f=\"${SLURM_SUBMIT_DIR}/${MATRIX_PATH}\" &> ${SLURM_SUBMIT_DIR}/${RESULT}


exit 0
