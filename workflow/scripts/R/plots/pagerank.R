library(tidyverse)
library(patchwork)
library(geomtextpath)

desired_script="connected_components"

#df_single_node <- read_csv("data/all.csv", col_names = T) %>%
#  filter(matrix_name != "NA") %>%
#  filter(script == desired_script)
#
#plot_single_node <- df_single_node %>%
#  ggplot(aes(x = lang, y = exec_time, fill = factor(nb_threads), color = factor(nb_threads), group=factor(nb_threads))) +
# geom_col(position="dodge", data = . %>% group_by(lang, matrix_name, script, nb_threads) %>% summarize(exec_time = mean(exec_time))) +
# geom_point(position = position_jitterdodge(jitter.width = 0.8), alpha=0.5) +
# facet_wrap(~matrix_name, ncol=1) +
# scale_color_grey("Number of threads", start = 0.2, end = 0.8) +
# scale_fill_grey("Number of threads", start = 0.2, end = 0.8) +
# scale_shape_discrete("Matrix") +
# ylim(0, NA) +
# xlab("Language") + ylab("Execution time [s]") +
# ggtitle(paste(desired_script, "single node", sep=" ")) +
# theme_bw() +
# theme(
#   legend.position = "bottom",
#   strip.background = element_blank()
# )
#
#y_range = ggplot_build(plot_single_node)$layout$panel_params[[1]]$y.range
#ymax = y_range[2]

df_mpi <- read_csv("data/all_mpi.csv", col_names=T) %>%
  filter(exec_time > 0) %>%
  filter(script == desired_script)

plot_mpi <- df_mpi %>%
  group_by(nb_threads, lang, matrix_name) %>%
  summarize(exec_time = mean(exec_time)) %>%
  ggplot(aes(x = nb_threads, y = exec_time, color = lang, group = lang)) +
  geom_point() +
  geom_line() +
  facet_wrap(~matrix_name, ncol=1, scale="free_y") +
  ylim(0, NA) +
  xlab("Number of MPI processes over 4 nodes") + ylab("Execution time [s]") +
 ggtitle(paste(desired_script, "MPI", sep=" ")) +
  theme_bw() +
  theme(
    legend.position = "bottom",
    strip.background = element_blank()
  )

plot_mpi
#plot_single_node + plot_mpi
#
#df_mean_times_single_node <- df_single_node %>%
#  group_by(matrix_name, lang, nb_threads) %>%
#  summarize(mean_exec_time = mean(exec_time)) %>%
#  rename(single_node_nb_threads = nb_threads)
#
#df_mpi %>%
#  group_by(nb_threads, lang, matrix_name) %>%
#  summarize(exec_time = mean(exec_time)) %>%
#  left_join(df_mean_times_single_node) %>%
#  ggplot(aes(x = nb_threads, y = exec_time, color = lang, group = lang)) +
#  geom_point() +
#  geom_line() +
#  geom_hline(aes(yintercept = mean_exec_time, color = lang, linetype = factor(single_node_nb_threads))) +
#  facet_wrap(~matrix_name, ncol=1) +
#  ylim(0, NA) +
#  xlab("Number of MPI processes over 4 nodes") + ylab("Execution time [s]") +
# ggtitle(paste(desired_script, "MPI", sep=" ")) +
#  theme_bw() +
#  theme(
#    legend.position = "bottom",
#    strip.background = element_blank()
#  )
