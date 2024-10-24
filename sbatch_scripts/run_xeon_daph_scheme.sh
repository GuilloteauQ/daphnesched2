#!/bin/bash

#SBATCH --job-name=daphnesched2
#SBATCH --nodes=1
#SBATCH --partition=xeon
#SBATCH --ntasks-per-node=1
#SBATCH --hint=nomultithread
#SBATCH --cpus-per-task=20
#              d-hh:mm:ss
#SBATCH --time=0-04:00:00
#SBATCH --wait

set -ex

PARTITIONING=STATIC
QUEUE_LAYOUT=CENTRALIZED
VICTIM_SELECTION=SEQ

NUM_THREADS=$1
SCRIPT=$2
MATRIX_PATH=$3
MATRIX_SIZE=$4 # unsued but kept to have the same api as for the other sbatch scripts
PARTITIONING=$5
RESULT=$6

OPTIONS=""

if [ "${NUM_THREADS}" -gt "1" ]
then
  OPTIONS="--vec --num-threads=${NUM_THREADS} --partitioning=${PARTITIONING} --queue_layout=${QUEUE_LAYOUT} --victim_selection=${VICTIM_SELECTION} --pin-workers"
fi


srun --cpus-per-task=${NUM_THREADS} singularity exec ${SLURM_SUBMIT_DIR}/daphne-dev.sif ${SLURM_SUBMIT_DIR}/daphne-src/bin/daphne \
					            --select-matrix-repr \
                      ${OPTIONS} \
					            --args f=\"${SLURM_SUBMIT_DIR}/${MATRIX_PATH}\"\
					            ${SLURM_SUBMIT_DIR}/${SCRIPT} &> ${SLURM_SUBMIT_DIR}/${RESULT}

exit 0
