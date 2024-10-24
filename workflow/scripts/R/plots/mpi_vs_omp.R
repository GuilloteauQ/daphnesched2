library(tidyverse)

df <- read_csv("data/all_mpi-vs-omp.csv", col_names=T)

type.labs <- c("MPI Processes", "Threads")
names(type.labs) <- c("mpi", "omp")

p <- df %>%
  select(-matrix_name, -script) %>% # because we only have cc and wikipedia matrix for now
  filter(exec_time > 0) %>%
  group_by(type, lang, nb_threads) %>%
  summarize(
    mean_exec_time = mean(exec_time),
    bar = 1.96 * sd(exec_time) / sqrt(n())
  ) %>%
  ggplot(aes(x = nb_threads, y = mean_exec_time, shape = lang, color = lang, group=lang)) +
  geom_line() +
  geom_point() +
  geom_errorbar(aes(ymin = mean_exec_time - bar, ymax = mean_exec_time + bar)) +
  facet_wrap(~type, nrow=1, labeller=labeller(type=type.labs)) +
  ylim(0, NA) +
  xlab("Number of MPI processes or threads") +
  ylab("Execution time [s]") +
  scale_shape_discrete("") + scale_color_discrete("") +
  theme_bw() +
  theme(
    legend.position = c(0.9, 0.8),
    legend.box = "horizontal",
    legend.background=element_blank(),
    legend.key=element_blank(),
    strip.background =element_blank()
  )

ggsave(plot=p, "mpi_vs_omp.pdf", width=4, height=2.5)

p <- df %>%
  select(-matrix_name, -script) %>% # because we only have cc and wikipedia matrix for now
  filter(exec_time > 0) %>%
  filter(lang %in% c("jl", "cpp")) %>%
  group_by(type, lang, nb_threads) %>%
  summarize(
    mean_exec_time = mean(exec_time),
    bar = 1.96 * sd(exec_time) / sqrt(n())
  ) %>%
  ggplot(aes(x = nb_threads, y = mean_exec_time, shape = lang, color = lang, group=lang)) +
  geom_line() +
  geom_point() +
  geom_errorbar(aes(ymin = mean_exec_time - bar, ymax = mean_exec_time + bar)) +
  facet_wrap(~type, nrow=1, labeller=labeller(type=type.labs)) +
  ylim(0, NA) +
  xlab("Number of MPI processes or threads") +
  ylab("Execution time [s]") +
  scale_shape_discrete("") + scale_color_discrete("") +
  theme_bw() +
  theme(
    legend.position = c(0.9, 0.25),
    legend.box = "horizontal",
    legend.background=element_blank(),
    legend.key=element_blank(),
    strip.background =element_blank()
  )

ggsave(plot=p, "mpi_vs_omp_zoom.pdf", width=4, height=2.5)
