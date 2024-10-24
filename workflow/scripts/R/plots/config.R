library(tidyverse)

filename <- "data/all_mpi-config.csv"

read_csv(filename, col_names = T) %>%
  group_by(nb_threads, lang, matrix_name) %>%
  summarize(
      sd = sd(exec_time),
      n = n(),
      exec_time = mean(exec_time),
      bar = 1.96 * sd / sqrt(n)
  ) %>%
  ggplot(aes(x = nb_threads, y = exec_time, color = lang, group = lang)) +
  geom_point() +
  geom_line() +
  geom_errorbar(aes(ymin = exec_time - bar, ymax = exec_time + bar)) +
  facet_wrap(~matrix_name, ncol=1, scale="free_y") +
  ylim(0, NA) +
  xlab("Number of MPI processes over 4 nodes") + ylab("Execution time [s]") +
 ggtitle("CC MPI") +
  theme_bw() +
  theme(
    legend.position = "bottom",
    strip.background = element_blank()
  )
