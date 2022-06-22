devtools::load_all("../comrad")

test_both_imbalance_tests <- function(phylos_empirical, phylos_bootstrap) {
  tests <- c("Sackin", "Colless")
  pval_tbl <- tests %>%
    map_dfr(function(test) {
      pvals <- test_dd_adequacy_imbalance(phylos_empirical, phylos_bootstrap, test)$pvals
      pval_tbl <- tibble("pval" = pvals, "test" = test)
      return(pval_tbl)
    })
  return(pval_tbl)
}
plot_pvals <- function(pval_tbl) {
  pval_tbl %>%
    ggplot() +
    geom_density(aes(x = pval, fill = dd_model)) +
    geom_vline(xintercept = 0.05, colour = "red") +
    theme_bw() +
    scale_fill_manual(values = dd_model_colours()[1:6]) +
    facet_grid(rows = vars(test), cols = vars(dd_model))
}

# 1. Null test
pval_tbl <- dd_model_names()[1:6] %>%
  map_dfr(function(dd_model) {
    cat("DD model =", dd_model, "\n")
    phylos_empirical <- readRDS(
      glue::glue("../fabrika/comrad_data/phylos/dd_phylos_{dd_model}_sigk_1_siga_0.1_1000_2.rds")
    )[1:100]
    phylos_bootstrap <- readRDS(
      glue::glue("../fabrika/comrad_data/phylos/dd_phylos_{dd_model}_sigk_1_siga_0.1_1000.rds")
    )[1:100]
    pval_tbl <- test_both_imbalance_tests(phylos_empirical, phylos_bootstrap) %>%
      mutate("dd_model" = dd_model)
    return(pval_tbl)
  })
saveRDS(pval_tbl, "../fabrika/comrad_data/tests/robustness_test/test_imbalance_dd_vs_same.rds")
pval_tbl <- readRDS("../fabrika/comrad_data/tests/robustness_test/test_imbalance_dd_vs_same.rds")

pval_tbl %>%
  group_by(test, dd_model) %>%
  dplyr::summarise(
    "prop(p> 0.05)" = sum(pval > 0.05) / n()
  ) %>% knitr::kable("pipe")

ragg::agg_png(
  "~/Github/comrad_manuscript/figs/adequacy_imbalance_same.png",
  width = 10,
  height = 5,
  units = "cm",
  scaling = 1/2,
  res = 150
)
pval_tbl %>% plot_pvals() +
  coord_cartesian(ylim = c(0, 10))
invisible(dev.off())

# 2. Power test
dd_models1 <- dd_model_names()[1:6]
dd_models2 <- dd_model_names()[c(4:6, 1:3)]

pval_tbl <- map2_dfr(dd_models1, dd_models2, function(dd_model1, dd_model2) {
  cat("DD model =", dd_model1, "vs", dd_model2, "\n")
  phylos_empirical <- readRDS(
    glue::glue("../fabrika/comrad_data/phylos/dd_phylos_{dd_model2}_sigk_1_siga_0.1_1000_2.rds")
  )[1:100]
  phylos_bootstrap <- readRDS(
    glue::glue("../fabrika/comrad_data/phylos/dd_phylos_{dd_model1}_sigk_1_siga_0.1_1000.rds")
  )[1:100]
  pval_tbl <- test_both_imbalance_tests(phylos_empirical, phylos_bootstrap) %>%
    mutate("dd_model" = dd_model1)
  return(pval_tbl)
})

saveRDS(pval_tbl, "../fabrika/comrad_data/tests/robustness_test/test_imbalance_dd_vs_other.rds")
pval_tbl <- readRDS("../fabrika/comrad_data/tests/robustness_test/test_imbalance_dd_vs_other.rds")

pval_tbl %>%
  group_by(test, dd_model) %>%
  dplyr::summarise(
    "prop(p> 0.05)" = sum(pval > 0.05) / n()
  ) %>% knitr::kable("pipe")

ragg::agg_png(
  "~/Github/fabrika/figs/adequacy_imbalance_other.png",
  width = 20,
  height = 10,
  units = "cm",
  scaling = 1,
  res = 300
)
pval_tbl %>% plot_pvals() +
  coord_cartesian(ylim = c(0, 10))
invisible(dev.off())

# 3. comrad test
phylos_empirical <- readRDS(
  glue::glue("../fabrika/comrad_data/phylos/comrad_phylos_sigk_1_siga_0.1_full.rds")
)

pval_tbl <- dd_model_names()[1:6] %>%
  map_dfr(function(dd_model) {
    cat("DD model =", dd_model, "\n")
    phylos_bootstrap <- readRDS(
      glue::glue("../fabrika/comrad_data/phylos/dd_phylos_{dd_model}_sigk_1_siga_0.1_1000.rds")
    )[1:100]
    pval_tbl <- test_both_imbalance_tests(phylos_empirical, phylos_bootstrap) %>%
      mutate("dd_model" = dd_model)
    return(pval_tbl)
  })

saveRDS(pval_tbl, "../fabrika/comrad_data/tests/robustness_test/test_imbalance_dd_vs_comrad.rds")
pval_tbl <- readRDS("../fabrika/comrad_data/tests/robustness_test/test_imbalance_dd_vs_comrad.rds")

pval_tbl %>%
  group_by(test, dd_model) %>%
  dplyr::summarise(
    "prop(p> 0.05)" = sum(pval > 0.05) / n()
  ) %>% knitr::kable("pipe")

ragg::agg_png(
  "~/Github/fabrika/figs/adequacy_imbalance_comrad.png",
  width = 20,
  height = 10,
  units = "cm",
  scaling = 1,
  res = 300
)
pval_tbl %>% plot_pvals() +
  coord_cartesian(ylim = c(0, 10))
invisible(dev.off())


# indices distributions
get_imbl_dists <- function(phylos_empirical, phylos_bootstrap, test) {
  results <- test_dd_adequacy_imbalance(phylos_empirical, phylos_bootstrap, test)
  imbl_tbl <- tibble(
    "imbalance" = c(results$imbalance_empirical, results$imbalance_bootstrap),
    "distrib" = c(rep("empirical", length(phylos_empirical)), rep("bootstrap", length(phylos_bootstrap))),
    "index" = test
  )
  return(imbl_tbl)
}

imbl_tbl <- dd_model_names()[1:6] %>%
  map_dfr(function(dd_model) {
    cat("DD model =", dd_model, "\n")
    phylos_bootstrap <- readRDS(
      glue::glue("../fabrika/comrad_data/phylos/dd_phylos_{dd_model}_sigk_1_siga_0.1_1000.rds")
    )[1:100]
    imbl_tbl <- get_imbl_dists(phylos_empirical = phylos_empirical, phylos_bootstrap = phylos_bootstrap, test = "Sackin") %>%
      mutate("dd_model" = dd_model)
    return(imbl_tbl)
  })

imbl_tbl %>%
  ggplot() +
  geom_density(aes(x = imbalance, fill = distrib), alpha = 0.8) +
  facet_wrap(vars(dd_model), nrow = 1, ncol = 6 ) +
 theme_bw()

ragg::agg_png(
  "~/Github/comrad_manuscript/figs/imbl_comrad_vs_dd.png",
  width = 10,
  height = 2.5,
  units = "cm",
  scaling = 1/2,
  res = 150
)
imbl_tbl %>%
  ggplot() +
  geom_density(aes(x = imbalance, fill = distrib), alpha = 0.8) +
  facet_wrap(vars(dd_model), nrow = 1, ncol = 6 ) +
  theme_bw()
invisible(dev.off())


