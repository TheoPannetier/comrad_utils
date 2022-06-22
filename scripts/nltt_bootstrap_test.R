phylos_empirical <- readRDS("../fabrika/comrad_data/phylos/comrad_phylos_sigk_1_siga_0.1_full.rds")
phylos_bootstrap <- readRDS("../fabrika/comrad_data/phylos/dd_phylos_lx_sigk_1_siga_0.1.rds")

ltts_empirical <- phylos_empirical %>% purrr::map(get_ltt_tbl)
ltts_bootstrap <- phylos_bootstrap %>% purrr::map(get_ltt_tbl)

t_seq <- seq(min(ltts_empirical[[1]]$time), 0, 100)

avg_ltt_empirical <- ltts_empirical %>%
  average_ltt(t_seq)
avg_ltt_bootstrap <- ltts_bootstrap %>%
  average_ltt(t_seq)

dnltts_bootstrap <- ltts_bootstrap %>% map_dbl(get_dnltt, avg_ltt_bootstrap)
dnltts_empirical <- ltts_empirical %>% map_dbl(get_dnltt, avg_ltt_bootstrap)
avg_dnltt_empirical <- get_dnltt(avg_ltt_empirical, avg_ltt_bootstrap)

# dnLTT distribution
gg <- tibble::tibble(
  "dnLTT" = dnltts_bootstrap
) %>%
  ggplot() +
  geom_density(aes(x = dnLTT), fill = "#7570B3") +
  geom_jitter(aes(x = dnLTT, y = 0)) +
  theme_bw()
gg

ragg::agg_png(
  "~/Github/comrad_manuscript/figs/dnltt_lx_3.png",
  width = 6,
  height = 3,
  units = "cm",
  scaling = 3/5,
  res = 150
)
tibble::tibble(
  "dnLTT" = c(dnltts_bootstrap, dnltts_empirical),
  "distrib" = c(rep("bootstrap", length(dnltts_bootstrap)), rep("\"empirical\"", length(dnltts_empirical)))
) %>%
  ggplot() +
  geom_density(aes(x = dnLTT, fill = distrib), alpha = 0.8) +
  scale_fill_manual(values = c("red", "#7570B3")) +
  theme_bw()
invisible(dev.off())


# with average empirical value

# dnLTT bootstrap vs empirical
tibble::tibble(
  "dnLTT" = c(dnltts_bootstrap, dnltts_empirical),
  "distrib" = c(rep("bootstrap", length(dnltts_bootstrap)), rep("\"empirical\"", length(dnltts_empirical)))
) %>%
  ggplot() +
  geom_density(aes(x = dnLTT, fill = distrib), alpha = 0.8) +
  scale_fill_manual(values = c("red", "#7570B3")) +
  theme_bw()
