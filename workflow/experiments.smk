include: "doe.smk"

rule all:
  input:
    expand("data/{matrix}/{benchmark}/{lang}/{num_threads}/{iter}",\
      matrix=MATRICES,\
      benchmark=SCRIPTS,\
      lang=LANGS,\
      num_threads=NUM_THREADS,\
      iter=ITERATIONS)

rule run_expe:
  input:
    sbatch="sbatch_scripts/run_xeon_{lang}.sh",
    script="benchmark_scripts/{benchmark}/{lang}/{benchmark}.{params.ext}",
    matrix="matrices/{matrix}"
  output:
    "data/{matrix}/{benchmark}/{lang}/{num_threads}/{iter}"
  params:
    matrix_size = 100000, # TODO
    ext = "py"
  shell:
    "{input.sbatch} {wildcards.num_threads} {input.script} {input.matrix} {params.matrix_size} {output}"
