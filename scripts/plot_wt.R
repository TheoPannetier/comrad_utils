siga <- 0.1
sigk <- 1
sampling_on_event <- TRUE
suffix <- ifelse(sampling_on_event, "full", "freq")

phylos <- readRDS(
  glue::glue(path_to_fabrika_local(), "comrad_data/phylos/comrad_phylos_sigk_{sigk}_siga_{siga}_{suffix}.rds")
)
waiting_times_tbl <- phylos %>% map_dfr(waiting_times)
waiting_times_tbl <- waiting_times_tbl %>%
  mutate(
    "pc_rate" = 1 / (N * waiting_time),
    "next_event" = fct_rev(next_event)
  )

N_max <- max(waiting_times_tbl$N)

aic_tbl <- read_mle_tbl(siga = siga, sigk = sigk) %>%
  filter_aic_best()

rates_tbl <- aic_tbl %>%
  get_ml_rates() %>%
  dplyr::mutate("dd_model" = factor(dd_model, levels = c("lc", "ll", "lx", "xc", "xl", "xx", "mean_data")))

waiting_times_tbl %>%
  ggplot(aes(x = N, y = waiting_time, group = N)) +
  geom_boxplot() +
  theme_bw() +
  facet_grid(cols = vars(next_event))

estimates <- estimate_dd_rates(phylos)
estimates <- estimates %>% dplyr::rename("next_event" = rate, "pc_rate" = value)

waiting_times_tbl %>%
  group_by(N, next_event) %>%
  dplyr::filter(is.finite(pc_rate)) %>%
  mutate(
    "mean_pc_rate" = 1 / (mean(waiting_time, na.rm = TRUE)*N)
  ) %>%
  ggplot(aes(x = N, y = pc_rate, group = N)) +
  geom_boxplot(aes(fill = next_event)) +
  geom_point(aes(y = mean_pc_rate), colour = "blue") +
  geom_line(aes(y = mean_pc_rate, group = next_event), colour = "blue", size = 1) +
  geom_line(aes(group = NULL), data = estimates, colour = "#a6761d") +
  theme_bw() +
  scale_y_log10() +
  facet_grid(cols = vars(next_event))

