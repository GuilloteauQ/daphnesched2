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
    matrix="[a-zA-Z0-9-]+"
  shell:
    "Rscript {input.script} {input.data} {wildcards.benchmark} {wildcards.num_threads} {wildcards.lang} {wildcards.matrix} {output}"

rule merge_iteration_csv:
  input:
    script="workflow/scripts/R/merge_all.R",
    data_with_matrices=expand("data/grouped_iter/{matrix}_{benchmark}_{lang}_{num_threads}.csv",\
      matrix=MATRICES,\
      benchmark=SCRIPTS_WITH_MATRICES,\
      lang=LANGUAGES,\
      num_threads=NUM_THREADS),
    data_without_matrices=expand("data/grouped_iter/{matrix}_{benchmark}_{lang}_{num_threads}.csv",\
      matrix=["NA"],\
      benchmark=SCRIPTS_WITHOUT_MATRICES,\
      lang=LANGUAGES,\
      num_threads=NUM_THREADS) 
  output:
    "data/all.csv"
  wildcard_constraints:
    matrix="[a-zA-Z0-9-]+"
  shell:
    "Rscript {input.script} {input.data_with_matrices} {input.data_without_matrices} {output}"
