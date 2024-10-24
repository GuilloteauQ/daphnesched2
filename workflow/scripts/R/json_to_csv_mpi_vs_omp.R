library(tidyverse)

args = commandArgs(trailingOnly=TRUE)
n = length(args)

files = args[1:(n-6)]

type = args[n-5]
script = args[n-4]
nb_threads = args[n-3]
lang = args[n-2]
matrix_name = args[n-1]
outfile = args[n]

files %>%
  map_df(function(x) read_csv(x, col_names=c("exec_time"))) %>%
  mutate(
    type = type,
    script = script,
    nb_threads = nb_threads,
    lang = lang,
    matrix_name = matrix_name
  ) %>%
  write_csv(outfile)
