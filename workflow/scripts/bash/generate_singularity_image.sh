#/bin/bash

set -xe

DEV_IMAGE=daphne-dev.sif
HERE=$(pwd)
PATCH_FOLDER=${HERE}/patches
DAPHNE_COMMIT=5de5748659d21f1e5b63c3d67d150b9cedd68b50 # March 2nd 2024

# download the dev image
singularity build ${DEV_IMAGE} docker://daphneeu/daphne-dev:2024-03-02_X86-64_BASE_ubuntu20.04

git clone https://github.com/daphne-eu/daphne ${HERE}/daphne-src
cd ${HERE}/daphne-src
git checkout ${DAPHNE_COMMIT}

if [ -d "${PATCH_FOLDER}" ]
  then
  for patch in "${PATCH_FOLDER}"/*.patch
  do
    patch -p1 < ${patch}
  done
fi

cd ${HERE}
# MPI
singularity exec ${DEV_IMAGE} bash -c "cd daphne-src; ./build.sh --mpi --no-deps --installPrefix /usr/local" # --mpi && cp bin/daphne bin/daphne-mpi"
# Normal
#singularity exec ${DEV_IMAGE} bash -c "cd daphne-src; ./build.sh --no-deps --installPrefix /usr/local"
