include: "doe.smk"

rule compile:
  input:
    expand("daphne-src/{implem}/bin/daphne", implem=IMPLEMENTATIONS),
    expand("daphne-src/{implem}-mpi/bin/daphne", implem=IMPLEMENTATIONS)

rule download_and_compile:
  input:
    singularity="daphne-dev.sif"
  output:
    "daphne-src/{implem}/bin/daphne"
  wildcard_constraints:
    implem="|".join(IMPLEMENTATIONS)
  params:
    commit = lambda w: COMMITS[w.implem][1],
    url = lambda w: COMMITS[w.implem][0]
  shell:
    """
      rm -rf daphne-src/{wildcards.implem}
      mkdir -p daphne-src
      git clone {params.url} daphne-src/{wildcards.implem}
      cd daphne-src/{wildcards.implem}
      git checkout {params.commit}
      cd ../..
      singularity exec {input.singularity} bash -c "cd daphne-src/{wildcards.implem}; ./build.sh --no-deps --installPrefix /usr/local"
    """

rule download_and_compile_mpi:
  input:
    singularity="daphne-dev.sif"
  output:
    "daphne-src/{implem}-mpi/bin/daphne"
  wildcard_constraints:
    implem="|".join(IMPLEMENTATIONS)
  params:
    commit = lambda w: COMMITS[w.implem][1],
    url = lambda w: COMMITS[w.implem][0]
  shell:
    """
      rm -rf daphne-src/{wildcards.implem}-mpi
      mkdir -p daphne-src
      git clone {params.url} daphne-src/{wildcards.implem}-mpi
      cd daphne-src/{wildcards.implem}-mpi
      git checkout {params.commit}
      cd ../..
      singularity exec {input.singularity} bash -c "cd daphne-src/{wildcards.implem}-mpi; ./build.sh --no-deps --mpi --installPrefix /usr/local"
    """

rule build_container:
  output:
    "daphne-dev.sif"
  shell:
    """
    singularity build {output} docker://daphneeu/daphne-dev:2024-10-16_X86-64_BASE_ubuntu24.04
    """
