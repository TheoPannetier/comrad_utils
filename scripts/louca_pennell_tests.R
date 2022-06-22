data_types <- c("edge_length", "node_age")
root_age <- 60000

get_ltt_tbl(phylos_empirical[[1]])$time[1]

devtools::load_all("../comrad")

# Shortcut function
test_both_datatypes <- function(phylos_empirical, phylos_bootstrap) {
  data_types <- c("edge_length", "node_age")
  pval_tbl <- data_types %>%
    map_dfr(function(data_type) {
      pvals <- test_dd_adequacy_castor(phylos_empirical, phylos_bootstrap, data_type)
      pval_tbl <- tibble("pval" = pvals, "data_type" = data_type)
      cat("So far so good! \n")
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
    facet_grid(rows = vars(data_type), cols = vars(dd_model))
}

# 1. Test each DD model - the 2nd bootstrap set on itself
pval_tbl <- dd_model_names()[1:6] %>%
  map_dfr(function(dd_model) {
    cat("DD model =", dd_model, "\n")
    phylos_empirical <- readRDS(
      glue::glue("../fabrika/comrad_data/phylos/dd_phylos_{dd_model}_sigk_1_siga_0.1_1000_2.rds")
    )[1:100]
    phylos_bootstrap <- readRDS(
      glue::glue("../fabrika/comrad_data/phylos/dd_phylos_{dd_model}_sigk_1_siga_0.1_1000.rds")
    )[1:100]
    pval_tbl <- test_both_datatypes(phylos_empirical, phylos_bootstrap) %>%
      mutate("dd_model" = dd_model)
    return(pval_tbl)
  })

saveRDS(pval_tbl, "../fabrika/comrad_data/tests/robustness_test/test_castor_dd_vs_same.rds")
pval_tbl <- readRDS("../fabrika/comrad_data/tests/robustness_test/test_castor_dd_vs_same.rds")
pval_tbl %>%
  group_by(data_type, dd_model) %>%
  dplyr::summarise(
    "prop(p> 0.05)" = sum(pval > 0.05) / n()
  ) %>% knitr::kable("pipe")

pval_tbl %>% plot_pvals() +
  #scale_x_sqrt() +
  coord_cartesian(ylim = c(0, 10))

# 2. Test each DD model - model from the other family, e.g. XL vs LL
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
    pval_tbl <- test_both_datatypes(phylos_empirical, phylos_bootstrap) %>%
      mutate("dd_model" = dd_model1)
    return(pval_tbl)
  })

saveRDS(pval_tbl, "../fabrika/comrad_data/tests/robustness_test/test_castor_dd_vs_other.rds")
pval_tbl <- readRDS("../fabrika/comrad_data/tests/robustness_test/test_castor_dd_vs_other.rds")

pval_tbl %>%
  group_by(data_type, dd_model) %>%
  dplyr::summarise(
    "prop(p> 0.05)" = sum(pval > 0.05) / n()
  ) %>% knitr::kable("pipe")


ragg::agg_png(
  "~/Github/fabrika/figs/adequacy_lp_other.png",
  width = 20,
  height = 10,
  units = "cm",
  scaling = 1,
  res = 300
)
pval_tbl %>% plot_pvals() +
  #scale_x_sqrt() +
  coord_cartesian(ylim = c(0, 10))
invisible(dev.off())

# 3. Test comrad trees vs each model
phylos_empirical <- readRDS(
  glue::glue("../fabrika/comrad_data/phylos/comrad_phylos_sigk_1_siga_0.1_full.rds")
)

pval_tbl <- dd_model_names()[1:6] %>%
  map_dfr(function(dd_model) {
    cat("DD model =", dd_model, "\n")
    phylos_bootstrap <- readRDS(
      glue::glue("../fabrika/comrad_data/phylos/dd_phylos_{dd_model}_sigk_1_siga_0.1_1000.rds")
    )[1:100]
    pval_tbl <- test_both_datatypes(phylos_empirical, phylos_bootstrap) %>%
      mutate("dd_model" = dd_model)
    return(pval_tbl)
  })

saveRDS(pval_tbl, "../fabrika/comrad_data/tests/robustness_test/test_castor_comrad_vs_dd.rds")
pval_tbl <- readRDS("../fabrika/comrad_data/tests/robustness_test/test_castor_comrad_vs_dd.rds")

ragg::agg_png(
  "~/Github/fabrika/figs/adequacy_lp_comrad.png",
  width = 20,
  height = 10,
  units = "cm",
  scaling = 1,
  res = 300
)
pval_tbl %>% plot_pvals() +
  #scale_x_sqrt() +
  coord_cartesian(ylim = c(0, 10))
invisible(dev.off())

pval_tbl %>%
  group_by(data_type, dd_model) %>%
  dplyr::summarise(
    "prop(p> 0.05)" = sum(pval > 0.05) / n()
  ) %>% knitr::kable("pipe")


