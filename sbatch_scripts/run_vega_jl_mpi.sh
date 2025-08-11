#!/bin/bash

#SBATCH --job-name=daphnesched2
#SBATCH --partition=cpu
#SBATCH --hint=nomultithread
#              d-hh:mm:ss
#SBATCH --time=0-02:00:00
#SBATCH --wait
#SBATCH --mem=8G

set -ex

NUM_THREADS=$1
SCRIPT=$2
MATRIX_PATH=$3
MATRIX_SIZE=$4 # unsued but kept to have the same api as for the other sbatch scripts
RESULT=$5

export OMP_NUM_THREADS=${NUM_THREADS}
export OPENBLAS_NUM_THREADS=${NUM_THREADS}
export MKL_NUM_THREADS=${NUM_THREADS}
export VECLIB_MAXIMUM_THREADS=${NUM_THREADS}
export NUMEXPR_NUM_THREADS=${NUM_THREADS}

export OMPI_MCA_PML="ucx"     
# replace the byte transport layer (BTL) for point-to-point comm 
# with Unified Communication X (UCX)
    # PML is either either:
        # ucx: Unified Communication X with things like
            # cma/memory: shared memory access via Cross-Memory Attach (CMA) — for inter-process comm on the same node
            # rc, rc_verbs: Infiniband Reliable Connection
        # cm: Connection Management PML (delegates all communication to mtl)
        # ob1: Open Byte Transfer Layer 1 (delegates communication to btl)

export UCX_TLS="rc,sm,self"    
# with UCX, only use: 
    # rc: inter node Infiniband reliable connection
    # sm: intra node shared memory
    # self: loopback MPI talking to itself

#export PMIX_MCA_gds="hash"
# https://github.com/open-mpi/ompi/issues/7516
# GDS (Global Data Store) component, do not use the ds12 component.
export PMIX_MCA_gds="^ds12"
export OMPI_MCA_gds="^ds12" 

# avoid btl fallback with tcp or vader on VEGA --> so crash instead of fallback
#export OMPI_MCA_btl="^vader,tcp,openib"
#export PMIX_MCA_btl="^vader,tcp,openib"
# btl fallback choices for intra node (no tcp/openib set for inter node --> crash)
export PMIX_MCA_btl="self,vader"
export OMPI_MCA_btl="self,vader"

srun --cpus-per-task=${NUM_THREADS} singularity exec --no-mount /cvmfs ${SLURM_SUBMIT_DIR}/jupycpp.sif julia --project=$(dirname ${SLURM_SUBMIT_DIR}/${SCRIPT}) -e "using Pkg; Pkg.instantiate()"
srun --cpus-per-task=${NUM_THREADS} singularity exec --no-mount /cvmfs ${SLURM_SUBMIT_DIR}/jupycpp.sif julia --threads ${NUM_THREADS} --project=$(dirname ${SLURM_SUBMIT_DIR}/${SCRIPT}) ${SLURM_SUBMIT_DIR}/${SCRIPT} ${SLURM_SUBMIT_DIR}/${MATRIX_PATH} > ${SLURM_SUBMIT_DIR}/${RESULT}

# srun --mpi=pmix --cpus-per-task=${NUM_THREADS} singularity exec --no-mount /cvmfs ${SLURM_SUBMIT_DIR}/jupycpp.sif julia --project=$(dirname ${SLURM_SUBMIT_DIR}/${SCRIPT}) -e "using Pkg; Pkg.instantiate()"
# srun --mpi=pmix --cpus-per-task=${NUM_THREADS} singularity exec --no-mount /cvmfs ${SLURM_SUBMIT_DIR}/jupycpp.sif julia --threads ${NUM_THREADS} --project=$(dirname ${SLURM_SUBMIT_DIR}/${SCRIPT}) ${SLURM_SUBMIT_DIR}/${SCRIPT} ${SLURM_SUBMIT_DIR}/${MATRIX_PATH} > ${SLURM_SUBMIT_DIR}/${RESULT}


exit 0
