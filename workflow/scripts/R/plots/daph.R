library(tidyverse)

filename <- "data/all_mpi-daph.csv"

df <- read_csv(filename, col_names = T)


df_order <- df %>%
  filter(matrix_name == "ljournal-2008" & layout == "CENTRALIZED") %>%
  group_by(scheme) %>%
  summarize(min_scheme_time = min(exec_time))

df %>%
  left_join(df_order) %>%
  mutate(scheme = fct_reorder(scheme, min_scheme_time)) %>%
  mutate(matrix_name = factor(matrix_name, levels=c("amazon0601", "wikipedia-20070206", "ljournal-2008"))) %>%
  ggplot(aes(x = scheme, y = exec_time, color = layout, shape=layout)) +
  geom_point() +
  facet_wrap(~matrix_name, ncol=1, scale="free_y") +
  ylim(0, NA) +
  xlab("Scheduling schemes") + ylab("Execution time [s]") +
  ggtitle("CC MPI") +
  scale_color_discrete("Queue layout") +
  scale_shape_discrete("Queue layout") +
  theme_bw() +
  theme(
    legend.position = "bottom",
    strip.background = element_blank(),
    axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)
  )

p <- df %>%
  left_join(df_order) %>%
  mutate(scheme = fct_reorder(scheme, min_scheme_time)) %>%
  mutate(matrix_name = factor(matrix_name, levels=c("amazon0601", "wikipedia-20070206", "ljournal-2008"))) %>%
  mutate(layout = factor(layout, levels=c("CENTRALIZED", "PERGROUP", "PERCPU"))) %>%
  group_by(matrix_name, scheme, layout) %>%
  summarize(mean_exec_time = mean(exec_time), bar = 1.96 * sd(exec_time) / sqrt(n())) %>%
  ggplot(aes(x = scheme, y = mean_exec_time, color = layout, shape=layout, group=layout)) +
  geom_errorbar(aes(ymin = mean_exec_time - bar, ymax = mean_exec_time + bar), position = position_dodge(width = 0.9), width=0.5) +
  geom_point(position = position_dodge(width = 0.90)) +
  #geom_line(linetype="dashed")+
  facet_wrap(~matrix_name, ncol=1, scale="free_y") +
  ylim(0, NA) +
  xlab("Scheduling schemes") +
  ylab("Execution time [s]") +
  #ggtitle("") +
  #scale_color_discrete("Queue layout") +
  #scale_shape_discrete("Queue layout") +
  scale_color_discrete("") +
  scale_shape_discrete("") +
  theme_bw() +
  theme(
    legend.position = "bottom",
    strip.background = element_blank(),
    axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)
  )

ggsave(plot=p, "schemes.pdf", width=4, height=5)

df %>%
  left_join(df_order) %>%
  mutate(scheme = fct_reorder(scheme, min_scheme_time)) %>%
  group_by(matrix_name, scheme, layout) %>%
  summarize(mean_exec_time = mean(exec_time), bar = 1.96 * sd(exec_time) / sqrt(n())) %>%
  mutate(matrix_name = factor(matrix_name, levels=c("amazon0601", "wikipedia-20070206", "ljournal-2008"))) %>%
  ggplot(aes(x = scheme, y = mean_exec_time, fill = layout)) +
  geom_col(position = "dodge2") +
  geom_errorbar(aes(ymin = mean_exec_time - bar, ymax = mean_exec_time + bar), position = position_dodge(width = 0.9), width=0.5) +
  facet_wrap(~matrix_name, ncol=1, scale="free_y") +
  ylim(0, NA) +
  xlab("Scheduling schemes") + ylab("Execution time [s]") +
  ggtitle("CC MPI") +
  scale_fill_grey("Queue layout", start=0.2, end=0.8) +
  theme_bw() +
  theme(
    legend.position = "bottom",
    strip.background = element_blank(),
    axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)
  )
