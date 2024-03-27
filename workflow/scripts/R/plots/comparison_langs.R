library(tidyverse)

read_csv("data/all.csv", col_names = T) %>%
  ggplot(aes(x = lang, y = exec_time, color = factor(nb_threads))) +
  # geom_boxplot() +
  geom_jitter() +
  scale_color_grey("Number of threads", start = 0.2, end = 0.8) +
  xlab("Language") + ylab("Execution time [s]") +
  theme_bw() +
  theme(legend.position = "bottom")
