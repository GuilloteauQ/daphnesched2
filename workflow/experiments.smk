include: "doe.smk"
include: "matrices.smk"

rule all:
  input:
    expand("data/{matrix}/{benchmark}/{lang}/{num_threads}/{iter}.dat",\
      matrix=MATRICES,\
      benchmark=SCRIPTS_WITH_MATRICES,\
      lang=LANGUAGES,\
      num_threads=NUM_THREADS,\
      iter=ITERATIONS),
    #expand("data/NA/{benchmark}/{lang}/{num_threads}/{iter}.dat",\
    #  benchmark=SCRIPTS_WITHOUT_MATRICES,\
    #  lang=LANGUAGES,\
    #  num_threads=NUM_THREADS,\
    #  iter=ITERATIONS)

rule run_expe_with_matrix:
  input:
    sbatch="sbatch_scripts/run_xeon_{lang}.sh",
    script="benchmark_scripts/{benchmark}/{lang}/{benchmark}.{lang}",
    mtx="matrices/{matrix}/{matrix}_ones.mtx",
    meta="matrices/{matrix}/{matrix}_ones.mtx.meta"
  output:
    "data/{matrix}/{benchmark}/{lang}/{num_threads}/{iter}.dat"  
  wildcard_constraints:
    matrix="|".join(matrices.keys())
  params:
    matrix_size = lambda w: matrices[w.matrix]["meta"]["numRows"]
  shell:
    "sbatch {input.sbatch} {wildcards.num_threads} {input.script} {input.mtx} {params.matrix_size} {output}"

rule run_expe_without_matrix:
  input:
    sbatch="sbatch_scripts/run_xeon_{lang}.sh",
    script="benchmark_scripts/{benchmark}/{lang}/{benchmark}.{lang}"
  output:
    "data/NA/{benchmark}/{lang}/{num_threads}/{iter}.dat"  
  shell:
    "sbatch --time=0-05:00:00 {input.sbatch} {wildcards.num_threads} {input.script} NA -1 {output}"

