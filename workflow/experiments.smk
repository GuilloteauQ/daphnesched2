include: "doe.smk"
include: "matrices.smk"

rule all:
  input:
    expand("data/{matrix}/{benchmark}/{lang}/{num_threads}/{iter}.dat",\
      matrix=MATRICES,\
      benchmark=SCRIPTS,\
      lang=LANGUAGES,\
      num_threads=NUM_THREADS,\
      iter=ITERATIONS)

rule run_expe:
  input:
    sbatch="sbatch_scripts/run_xeon_{lang}.sh",
    script="benchmark_scripts/{benchmark}/{lang}/{benchmark}.{lang}",
    mtx="matrices/{matrix}/{matrix}_ones.mtx",
    meta="matrices/{matrix}/{matrix}_ones.mtx.meta"
  output:
    "data/{matrix}/{benchmark}/{lang}/{num_threads}/{iter}.dat"  
  wildcard_constraints:
    matrix="[a-zA-Z0-9-]+"
  params:
    matrix_size = lambda w: matrices[w.matrix]["meta"]["numRows"]
  shell:
    "sbatch {input.sbatch} {wildcards.num_threads} {input.script} {input.mtx} {params.matrix_size} {output}"


