library(tidyverse)

filename <- "data/all_mpi-full-scale.csv"

filename_best <- "data/all_mpi-daph-best.csv"

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
  geom_errorbar(aes(ymin = exec_time - bar, ymax = exec_time + bar), width=0.2) +
  facet_wrap(~matrix_name, ncol=1, scale="free_y") +
  ylim(0, NA) +
  xlab("Number of nodes") + ylab("Execution time [s]") +
 #ggtitle("CC MPI") +
  theme_bw() +
  theme(
    legend.position = "bottom",
    strip.background = element_blank()
  )

df_auto <- read_csv(filename_best, col_names = T) %>%
  mutate(matrix_name = factor(matrix_name, levels=c("amazon0601", "wikipedia-20070206", "ljournal-2008"))) %>%
  mutate(lang = "daph", def="No")

p <- read_csv(filename, col_names = T) %>%
  group_by(nb_threads, lang, matrix_name) %>%
  summarize(
      sd = sd(exec_time),
      n = n(),
      exec_time = mean(exec_time),
      bar = 1.96 * sd / sqrt(n)
  ) %>%
  mutate(matrix_name = factor(matrix_name, levels=c("amazon0601", "wikipedia-20070206", "ljournal-2008"))) %>%
  ggplot(aes(x = nb_threads, y = exec_time, color = lang, shape=lang)) +
  geom_point() +
  geom_line() +
  geom_point(data=df_auto) +
  geom_line(data=df_auto, linetype="dashed") +
  geom_errorbar(aes(ymin = exec_time - bar, ymax = exec_time + bar), width=0.2) +
  facet_wrap(~matrix_name, ncol=1, scale="free_y") +
  ylim(0, NA) +
  xlab("Number of nodes") + ylab("Execution time [s]") +
  scale_shape_discrete("Languages") +
  scale_color_discrete("Languages") +
  theme_bw() +
  theme(
    legend.position = "bottom",
    legend.box="vertical",
    strip.background = element_blank()
  )
ggsave(plot=p, "scale.pdf", width=4, height=4.5)
