# 0. declare plotting functions
get_qt_95 <- function(dnltt_tbl) {
  dnltt_tbl %>%
    dplyr::filter(set == "bootstrap") %>%
    group_by(dd_model) %>%
    summarise(
      "qt95" = quantile(dnltt, probs = 0.95)
    )
}
plot_dnltts <- function(dnltt_tbl) {
  qt_95_tbl <- get_qt_95(dnltt_tbl)
  gg <- dnltt_tbl %>%
    ggplot() +
    geom_density(aes(x = dnltt, group = set, fill = set), alpha = 0.8) +
    geom_vline(aes(xintercept = qt95), data = qt_95_tbl, colour = "#FCA49B") +
    theme_bw() +
    facet_wrap(vars(dd_model), nrow = 2, ncol = 5) +
    labs(x = bquote(Delta ~ "nLTT"))
  gg
}

# 1. Test each DD model - the 2nd bootstrap set on itself
dnltt_identity <- dd_model_names() %>% map_dfr(function(dd_model) {
  cat("DD model", dd_model, "\n")
  stop("second bootstrap set for dd_model[7:10] do not exist")
  cat("Computing empirical LTT set\n")
  ltts_empirical <- readRDS(
    glue::glue("../fabrika/comrad_data/phylos/dd_phylos_{dd_model}_sigk_1_siga_0.1_1000_2.rds")[1:100]
  ) %>% map(get_ltt_tbl)

  cat("Computing bootstrap LTT set\n")
  ltts_bootstrap <- readRDS(
    glue::glue("../fabrika/comrad_data/phylos/dd_phylos_{dd_model}_sigk_1_siga_0.1_1000.rds")[1:100]
  ) %>% map(get_ltt_tbl)

  cat("Running dnLTT\n")
  dnltt_tbl <- test_dd_adequacy_dnltt(ltts_empirical, ltts_bootstrap)$dnltt_tbl %>%
    dplyr::mutate("dd_model" = dd_model)
  return(dnltt_tbl)
})
saveRDS(dnltt_identity, "../fabrika/comrad_data/tests/robustness_test/dnltt_dd_vs_same.rds")

# 2. Test each DD model - model from the other family, e.g. XL vs LL
dd_models1 <- dd_model_names()
dd_models2 <- dd_model_names()[c(4:6, 1:3, 1, 10, 2, 8)]

dnltt_other <- map2_dfr(dd_models1, dd_models2, function(dd_model1, dd_model2) {
  cat("DD model", dd_model1, "vs", dd_model2, "\n")
  cat("Computing empirical LTT set\n")
  ltts_empirical <- readRDS(
    glue::glue("../fabrika/comrad_data/phylos/dd_phylos_{dd_model2}_sigk_1_siga_0.1.rds")
  )[1:100] %>% map(get_ltt_tbl)

  cat("Computing bootstrap LTT set\n")
  ltts_bootstrap <- readRDS(
    glue::glue("../fabrika/comrad_data/phylos/dd_phylos_{dd_model1}_sigk_1_siga_0.1.rds")
  )[1:100] %>% map(get_ltt_tbl)

  cat("Running dnLTT\n")
  dnltt_tbl <- test_dd_adequacy_dnltt(ltts_empirical, ltts_bootstrap)$dnltt_tbl %>%
    dplyr::mutate("dd_model" = dd_model1)
  return(dnltt_tbl)
})
saveRDS(dnltt_other, "../fabrika/comrad_data/tests/robustness_test/dnltt_dd_vs_other.rds")
dnltt_other <- readRDS("../fabrika/comrad_data/tests/robustness_test/dnltt_dd_vs_other.rds")
gg <- dnltt_other %>% plot_dnltts()
gg

ragg::agg_png(
  "~/Github/fabrika/figs/dnltt_dd_vs_other.png",
  width = 20,
  height = 10,
  units = "cm",
  scaling = 1,
  res = 300
)
gg
invisible(dev.off())

# 3. Test comrad trees vs each model
ltts_empirical <- readRDS(
  glue::glue("../fabrika/comrad_data/phylos/comrad_phylos_sigk_1_siga_0.1_full.rds")
) %>% map(get_ltt_tbl)

dnltt_comrad <- dd_model_names() %>% map_dfr(function(dd_model) {
  cat("DD model", dd_model, "\n")
  cat("Computing bootstrap LTT set\n")
  ltts_bootstrap <- readRDS(
    glue::glue("../fabrika/comrad_data/phylos/dd_phylos_{dd_model}_sigk_1_siga_0.1.rds")
  )[1:100] %>% map(get_ltt_tbl)

  cat("Running dnLTT\n")
  dnltt_tbl <- test_dd_adequacy_dnltt(ltts_empirical, ltts_bootstrap)$dnltt_tbl %>%
    dplyr::mutate("dd_model" = dd_model)
  return(dnltt_tbl)
})
saveRDS(dnltt_comrad, "../fabrika/comrad_data/tests/robustness_test/dnltt_dd_vs_comrad.rds")
dnltt_comrad <- readRDS("../fabrika/comrad_data/tests/robustness_test/dnltt_dd_vs_comrad.rds")
gg <- dnltt_comrad %>% plot_dnltts()
gg
