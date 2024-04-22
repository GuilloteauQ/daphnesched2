include: "doe.smk"
include: "matrices.smk"

rule all:
  input:
    expand("data/mpi/{matrix}/{benchmark}/{lang}/{mpi_procs}/{iter}.dat",\
      matrix=MATRICES,\
      benchmark=SCRIPTS_MPI,\
      lang=["cpp", "py", "jl", "daph"],\
      mpi_procs=MPI_DISTRIBUTION.keys(),\
      iter=ITERATIONS),

rule run_expe_mpi_with_matrix:
  input:
    sbatch="sbatch_scripts/run_xeon_{lang}_mpi.sh",
    script="benchmark_scripts/{benchmark}-mpi/{lang}/{benchmark}.{lang}",
    mtx="matrices/{matrix}/{matrix}_ones.mtx",
    meta="matrices/{matrix}/{matrix}_ones.mtx.meta"
  output:
    "data/mpi/{matrix}/{benchmark}/{lang}/{mpi_procs}/{iter}.dat"  
  wildcard_constraints:
    matrix="|".join(matrices.keys()),
    benchmakr="|".join(SCRIPTS_MPI)
  params:
    matrix_size = lambda w: matrices[w.matrix]["meta"]["numRows"],
    tasks_per_node = lambda w: MPI_DISTRIBUTION[w.mpi_procs][0],
    cpus_per_task = lambda w: MPI_DISTRIBUTION[w.mpi_procs][1],
    nb_nodes = MPI_NB_NODES
  shell:
    "sbatch --nodes={params.nb_nodes} \
            --ntasks-per-node={params.tasks_per_node} \
            --cpus-per-task={params.cpus_per_task} {input.sbatch} {params.cpus_per_task} {input.script} {input.mtx} {params.matrix_size} {output}"
