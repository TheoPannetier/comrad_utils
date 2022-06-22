devtools::load_all("../comrad/")

get_pval_tbl <- function(rob_results){
  rob_results %>% map_dfr(function(ls) {
    dnltts_empirical <- ls$dnltts_empirical
    dnltts_bootstrap <- ls$dnltts_bootstrap
    pvals <- dnltts_empirical %>% purrr::map_dbl(function(dnltt_empirical) {
      sum(dnltts_bootstrap > dnltt_empirical) / length(dnltts_bootstrap)
    })
    pval_tbl <- tibble("pval" = pvals)
  }, .id = "dd_model")
}

plot_pvals <- function(pval_tbl) {
  pval_tbl %>%
    ggplot() +
    geom_density(aes(x = pval, fill = dd_model)) +
    geom_vline(xintercept = 0.05, colour = "red") +
    theme_bw() +
    scale_fill_manual(values = dd_model_colours()[1:6]) +
    facet_grid(cols = vars(dd_model))
}

# 1. Test each DD model - the 2nd bootstrap set on itself
robustness_identity <- dd_model_names()[1:6] %>% map(function(dd_model) {
  cat("DD model", dd_model, "\n")

  cat("Computing empirical LTT set\n")
  ltts_empirical <- readRDS(
    glue::glue("../fabrika/comrad_data/phylos/dd_phylos_{dd_model}_sigk_1_siga_0.1_1000_2.rds")
  ) %>% map(get_ltt_tbl)
  testthat::expect_length(ltts_empirical, 1000)

  cat("Computing bootstrap LTT set\n")
  ltts_bootstrap <- readRDS(
    glue::glue("../fabrika/comrad_data/phylos/dd_phylos_{dd_model}_sigk_1_siga_0.1_1000.rds")
  ) %>% map(get_ltt_tbl)
  testthat::expect_length(ltts_bootstrap, 1000)

  cat("Running robustness tests\n")
  robustness_ls <- robustness_test(ltts_empirical, ltts_bootstrap)
  return(robustness_ls)
})
names(robustness_identity) <- dd_model_names()[1:6]
saveRDS(robustness_identity, "../fabrika/comrad_data/tests/robustness_test/bootstrap_vs_same_bootstrap.rds")
robustness_identity <- readRDS("../fabrika/comrad_data/tests/robustness_test/bootstrap_vs_same_bootstrap.rds")

pval_tbl <- get_pval_tbl(robustness_identity)
pval_tbl %>% plot_pvals() +
  coord_cartesian(ylim = c(0, 5))

ragg::agg_png(
  "~/Github/comrad_manuscript/figs/adequacy_dnltt_same.png",
  width = 10,
  height = 2.5,
  units = "cm",
  scaling = 1/2,
  res = 150
)
pval_tbl %>% plot_pvals() +
  coord_cartesian(ylim = c(0, 5))
invisible(dev.off())

# Extract delta nltt distributions
delta_nltt_tbl <- dd_model_names()[1:6] %>% map_dfr(function(dd_model) {
  rob_ls <- robustness_identity[[dd_model]]
  tbl <- bind_rows(
    tibble("dnltt" = rob_ls$dnltts_empirical, "set" = "empirical", "dd_model" = dd_model),
    tibble("dnltt" = rob_ls$dnltts_bootstrap, "set" = "bootstrap", "dd_model" = dd_model)
  )
})

# Plot dnLTT distribs
gg <- delta_nltt_tbl %>%
  ggplot() +
  geom_density(aes(x = dnltt, group = set, fill = set), alpha = 0.8) +
  theme_bw() +
  #scale_x_log10() +
  facet_wrap(vars(dd_model), nrow = 2, ncol = 3) +
  labs(x = bquote(Delta ~ "nLTT"))
gg

ragg::agg_png(
  "~/Github/fabrika/figs/rob_dnltt_dd_vs_same.png",
  width = 15,
  height = 10,
  units = "cm",
  scaling = 1,
  res = 300
)
gg
invisible(dev.off())

robustness_identity %>% map_dbl(function(x) x$p_95)
robustness_identity %>% map_dbl(function(x) x$ks$p.value)
# haha nonsense

dd_model_names() %>% map_dbl(function(dd_model) {
  rob_ls <- robustness_identity[[dd_model]]
  dnltts_empirical <- rob_ls$dnltts_empirical
  dnltts_bootstrap <- rob_ls$dnltts_bootstrap
  test <- stats::ks.test(x = dnltts_empirical, y = dnltts_bootstrap, alternative = "two.sided")
  #test <- stats::wilcox.test(x = dnltts_empirical, y = dnltts_bootstrap, alternative = "two.sided")
  return(test$p.value)
})

# same results with Wilcoxon test

# If I log the dnltt, is is normally distributed?
dd_model_names() %>% map_dbl(function(dd_model) {
  rob_ls <- robustness_identity[[dd_model]]
  dnltts_empirical <- rob_ls$dnltts_empirical
  dnltts_bootstrap <- rob_ls$dnltts_bootstrap
  #test <- stats::ks.test(x = log(dnltts_empirical), y = "pnorm", alternative = "two.sided")
  #test <- stats::wilcox.test(x = dnltts_empirical, y = dnltts_bootstrap, alternative = "two.sided")
  test <- shapiro.test(log(dnltts_empirical))
  return(test$p.value)
}) # not at all

# 2. Test each DD model - model from the other family, e.g. XL vs LL
dd_models1 <- dd_model_names()
dd_models2 <- dd_model_names()[c(4:6, 1:3)]

robustness_other <- map2(dd_models1, dd_models2, function(dd_model1, dd_model2) {
  cat("DD model", dd_model1, "vs", dd_model2, "\n")
  cat("Computing empirical LTT set\n")
  ltts_empirical <- readRDS(
    glue::glue("../fabrika/comrad_data/phylos/dd_phylos_{dd_model2}_sigk_1_siga_0.1_1000.rds")
  ) %>% map(get_ltt_tbl)
  testthat::expect_length(ltts_empirical, 1000)

  cat("Computing bootstrap LTT set\n")
  ltts_bootstrap <- readRDS(
    glue::glue("../fabrika/comrad_data/phylos/dd_phylos_{dd_model1}_sigk_1_siga_0.1_1000.rds")
  ) %>% map(get_ltt_tbl)
  testthat::expect_length(ltts_bootstrap, 1000)

  cat("Running robustness tests\n")
  robustness_ls <- robustness_test(ltts_empirical, ltts_bootstrap)
  return(robustness_ls)
})
names(robustness_other) <- dd_model_names()
saveRDS(robustness_other, "../fabrika/comrad_data/tests/robustness_test/bootstrap_vs_other_bootstrap.rds")
robustness_other <- readRDS("../fabrika/comrad_data/tests/robustness_test/bootstrap_vs_other_bootstrap.rds")

pval_tbl <- get_pval_tbl(robustness_other)
pval_tbl %>% plot_pvals() +
  coord_cartesian(ylim = c(0, 10))

ragg::agg_png(
  "~/Github/comrad_manuscript/figs/adequacy_dnltt_other.png",
  width = 10,
  height = 2.5,
  units = "cm",
  scaling = 1/2,
  res = 150
)
pval_tbl %>% plot_pvals() +
  coord_cartesian(ylim = c(0, 10))
invisible(dev.off())

pval_tbl %>%
  group_by(dd_model) %>%
  dplyr::summarise(
    "prop(p> 0.05)" = sum(pval > 0.05) / n()
  ) %>% knitr::kable("pipe")

delta_nltt_tbl <- dd_model_names()[1:6] %>%
  map_dfr(function(dd_model) {
  rob_ls <- robustness_other[[dd_model]]
  tbl <- bind_rows(
    tibble("dnltt" = rob_ls$dnltts_empirical, "set" = "empirical", "dd_model" = dd_model),
    tibble("dnltt" = rob_ls$dnltts_bootstrap, "set" = "bootstrap", "dd_model" = dd_model)
  )
})

qt95_tbl <- delta_nltt_tbl %>%
  dplyr::filter(set == "bootstrap") %>%
  group_by(dd_model) %>%
  summarise(
    "qt95" = quantile(dnltt, probs = 0.95)
  )
qt95_tbl$qt95

# Plot dNLTT distribs
gg <- delta_nltt_tbl %>%
  ggplot() +
  geom_density(aes(x = dnltt, group = set, fill = set), alpha = 0.8) +
  theme_bw() +
  geom_vline(aes(xintercept = qt95), data = qt95_tbl, colour = "#FCA49B") +
  #scale_x_log10() +
  facet_wrap(vars(dd_model), nrow = 2, ncol = 3) +
  labs(x = bquote(Delta ~ "nLTT"))
gg
ragg::agg_png(
  "~/Github/fabrika/figs/rob_dnltt_dd_vs_other.png",
  width = 15,
  height = 10,
  units = "cm",
  scaling = 1,
  res = 300
)
gg
invisible(dev.off())

robustness_other %>% map_dbl(function(x) x$p_95)
robustness_other %>% map_dbl(function(x) x$ks$p.value)

# 3. Test comrad trees vs each model
ltts_empirical <- readRDS(
  glue::glue("../fabrika/comrad_data/phylos/comrad_phylos_sigk_1_siga_0.1_full_1000.rds")
) %>% map(get_ltt_tbl)

robustness_comrad <- dd_model_names() %>% map(function(dd_model) {
  cat("Computing bootstrap LTT set\n")
  ltts_bootstrap <- readRDS(
    glue::glue("../fabrika/comrad_data/phylos/dd_phylos_{dd_model}_sigk_1_siga_0.1_1000.rds")
  ) %>% map(get_ltt_tbl)
  testthat::expect_length(ltts_bootstrap, 1000)

  cat("Running robustness tests\n")
  robustness_ls <- robustness_test(ltts_empirical, ltts_bootstrap)
  return(robustness_ls)
})
names(robustness_comrad) <- dd_model_names()
saveRDS(robustness_comrad, "../fabrika/comrad_data/tests/robustness_test/bootstrap_vs_comrad.rds")
robustness_comrad <- readRDS("../fabrika/comrad_data/tests/robustness_test/bootstrap_vs_comrad.rds")

pval_tbl <- get_pval_tbl(robustness_comrad)
pval_tbl %>% plot_pvals() +
  coord_cartesian(ylim = c(0, 15))

pval_tbl %>%
  group_by(dd_model) %>%
  dplyr::summarise(
    "prop(p> 0.05)" = sum(pval > 0.05) / n()
  ) %>% knitr::kable("pipe")


ragg::agg_png(
  "~/Github/fabrika/figs/adequacy_dnltt_comrad.png",
  width = 20,
  height = 5,
  units = "cm",
  scaling = 1,
  res = 300
)
pval_tbl %>% plot_pvals() +
  coord_cartesian(ylim = c(0, 15))
invisible(dev.off())

delta_nltt_tbl <- dd_model_names()[1:6] %>% map_dfr(function(dd_model) {
  rob_ls <- robustness_comrad[[dd_model]]
  tbl <- bind_rows(
    tibble("dnltt" = rob_ls$dnltts_empirical, "set" = "empirical", "dd_model" = dd_model),
    tibble("dnltt" = rob_ls$dnltts_bootstrap, "set" = "bootstrap", "dd_model" = dd_model)
  )
})

qt95_tbl <- delta_nltt_tbl %>%
  dplyr::filter(set == "bootstrap") %>%
  group_by(dd_model) %>%
  summarise(
    "qt95" = quantile(dnltt, probs = 0.95)
  )
qt95_tbl$qt95

# Plot dNLTT distribs
gg <- delta_nltt_tbl %>%
  ggplot() +
  geom_density(aes(x = dnltt, group = set, fill = set), alpha = 0.8) +
  theme_bw() +
  #scale_x_log10() +
  geom_vline(aes(xintercept = qt95), data = qt95_tbl, colour = "#FCA49B") +
  facet_wrap(vars(dd_model), nrow = 2, ncol = 3) +
  labs(x = bquote(Delta ~ "nLTT"))
gg

ragg::agg_png(
  "~/Github/fabrika/figs/rob_dnltt_dd_vs_comrad.png",
  width = 15,
  height = 10,
  units = "cm",
  scaling = 1,
  res = 300
)
gg
invisible(dev.off())

robustness_comrad %>% map_dbl(function(x) x$p_95)
robustness_comrad %>% map_dbl(function(x) x$ks$p.value)
