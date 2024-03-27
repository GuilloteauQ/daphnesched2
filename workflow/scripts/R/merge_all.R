library(tidyverse)

args = commandArgs(trailingOnly=TRUE)
n = length(args)

files = args[1:(n-1)]
outfile = args[n]

files %>%
  map_df(read_csv) %>%
  write_csv(outfile)
