include: "doe.smk"

rule all:
  input:
    "data/all.csv"

rule merge_iterations:
  input:
    script="workflow/scripts/R/json_to_csv.R",
    data=expand("data/{{matrix}}/{{benchmark}}/{{lang}}/{{num_threads}}/{iter}.dat", iter=ITERATIONS)
  output:
    "data/grouped_iter/{matrix}_{benchmark}_{lang}_{num_threads}.csv"
  wildcard_constraints:
    matrix="[a-zA-Z0-9]+"
  shell:
    "Rscript {input.script} {input.data} {wildcards.benchmark} {wildcards.num_threads} {wildcards.lang} {wildcards.matrix} {output}"

rule merge_iteration_csv:
  input:
    script="workflow/scripts/R/merge_all.R",
    data=expand("data/grouped_iter/{matrix}_{benchmark}_{lang}_{num_threads}.csv",\
      matrix=MATRICES,\
      benchmark=SCRIPTS,\
      lang=LANGUAGES,\
      num_threads=NUM_THREADS) 
  output:
    "data/all.csv"
  wildcard_constraints:
    matrix="[a-zA-Z0-9]+"
  shell:
    "Rscript {input.script} {input.data} {output}"
