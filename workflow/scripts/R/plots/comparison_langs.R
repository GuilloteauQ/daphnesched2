library(tidyverse)

read_csv("data/all.csv", col_names = T) %>%
  filter(matrix_name != "NA") %>%
  ggplot(aes(x = lang, y = exec_time, fill = factor(nb_threads), color = factor(nb_threads), group=factor(nb_threads))) +
  geom_col(position="dodge", data = . %>% group_by(lang, matrix_name, script, nb_threads) %>% summarize(exec_time = mean(exec_time))) +
  geom_point(position = position_jitterdodge(jitter.width = 0.8), alpha=0.5) +
  # facet_wrap(~script, nrow=1) +
  facet_grid(matrix_name~script, scales="free_y") +
  scale_color_grey("Number of threads", start = 0.2, end = 0.8) +
  scale_fill_grey("Number of threads", start = 0.2, end = 0.8) +
  scale_shape_discrete("Matrix") +
  ylim(0, NA) +
  xlab("Language") + ylab("Execution time [s]") +
  theme_bw() +
  theme(
    legend.position = "bottom",
    strip.background = element_blank()
  )
