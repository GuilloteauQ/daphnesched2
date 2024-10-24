library(tidyverse)

read_csv("data/all.csv", col_names = T) %>%
  filter(script == "nbody") %>%
  ggplot(aes(x = lang, y = exec_time, color = factor(nb_threads), group=factor(nb_threads))) +
  geom_point(position = position_jitterdodge(jitter.width = 0.8)) +
  scale_color_grey("Number of threads", start = 0.2, end = 0.8) +
  scale_shape_discrete("Matrix") +
  ylim(0, NA) +
  xlab("Language") + ylab("Execution time [s]") +
  theme_bw() +
  theme(
    legend.position = "bottom",
    strip.background = element_blank()
  )
