include: "doe.smk"

rule compile:
  input:
    "daphne-dev.sif",
    "jupycpp.sif",
    "daphne-src/bin/daphne",
    "daphne-src-mpi/bin/daphne",

rule download_and_compile:
  input:
    singularity="daphne-dev.sif",
    sbatch="sbatch_scripts/build_vega_daph.sh"
  output:
    "daphne-src/bin/daphne"
  params:
    commit = DAPHNE_GIT_COMMIT,
    url = DAPHNE_GIT_URL
  shell:
    """
      rm -rf daphne-src
      mkdir -p daphne-src
      git clone {params.url} daphne-src
      cd daphne-src
      git checkout {params.commit}
      # for patch in ../patches/*.patch
      # do
      #   patch -p1 < $patch
      # done
      cd ../
      sbatch {input.sbatch} daphne-src
    """

rule download_and_compile_mpi:
  input:
    singularity="daphne-dev.sif",
    sbatch="sbatch_scripts/build_vega_daph.sh"
  output:
    "daphne-src-mpi/bin/daphne"
  params:
    commit = DAPHNE_GIT_COMMIT,
    url = DAPHNE_GIT_URL
  shell:
    """
      rm -rf daphne-src-mpi
      mkdir -p daphne-src-mpi
      git clone {params.url} daphne-src-mpi
      cd daphne-src-mpi
      git checkout {params.commit}
      # for patch in ../patches/*.patch
      # do
      #   patch -p1 < $patch
      # done
      cd ../
      sbatch {input.sbatch} daphne-src-mpi --mpi
    """

rule build_container:
  output:
    "daphne.sif"
  params:
    docker_tag = DAPHNE_DOCKER_TAG
  shell:
    """
    singularity build {output} docker://daphneeu/daphne:{params.docker_tag}
    """

rule build_container_dev:
  output:
    "daphne-dev.sif"
  params:
    docker_tag = DAPHNE_DOCKER_TAG
  shell:
    """
    singularity build {output} docker://daphneeu/daphne-dev:{params.docker_tag}
    """

rule build_container_jupycpp:
  output:
    "jupycpp.sif"
  params:
    docker_tag = JUPYCPP_DOCKER_TAG
  shell:
    """
    singularity build {output} docker://guilloteauq/jupycpp:{params.docker_tag}
    """
