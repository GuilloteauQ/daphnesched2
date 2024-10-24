library(tidyverse)

args = commandArgs(trailingOnly=TRUE)
n = length(args)

files = args[1:(n-5)]

script = args[n-4]
scheme = args[n-3]
layout = args[n-2]
matrix_name = args[n-1]
outfile = args[n]

files %>%
  map_df(function(x) read_csv(x, col_names=c("exec_time"))) %>%
  mutate(
    script = script,
    scheme = scheme,
    layout = layout,
    matrix_name = matrix_name
  ) %>%
  write_csv(outfile)
