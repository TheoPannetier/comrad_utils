devtools::load_all("../comrad")

# 1. Null test
type <- "Sackin"
imbl_res_ls <- dd_model_names()[1:6] %>%
  map(function(dd_model) {
    cat("DD model =", dd_model, "\n")
    phylos_empirical <- readRDS(
      glue::glue("../fabrika/comrad_data/phylos/dd_phylos_{dd_model}_sigk_1_siga_0.1_1000_2.rds")
    )[1:100]
    phylos_bootstrap <- readRDS(
      glue::glue("../fabrika/comrad_data/phylos/dd_phylos_{dd_model}_sigk_1_siga_0.1_1000.rds")
    )[1:100]
    res_ls <- test_dd_adequacy_imbalance(phylos_empirical, phylos_bootstrap, type = type)
    return(res_ls)
  })

names(imbl_res_ls) <- dd_model_names()[1:6]
imbl_tbl <- imbl_res_ls %>%
  map_dfr(function(x) {
    bind_rows(
      tibble::tibble("imbl" = x$imbalance_empirical, "set" = "empirical"),
      tibble::tibble("imbl" = x$imbalance_bootstrap, "set" = "bootstrap")
    )
  }, .id = "dd_model")

gg <- imbl_tbl %>%
  ggplot(aes(x = imbl, fill = set)) +
  geom_density(alpha = 0.8) +
  theme_bw() +
  facet_wrap(vars(dd_model), ncol = 3, nrow = 2) +
  labs(title = glue::glue("DD vs same DD, {type} index"))

# 2. DD vs opposite speciation DD
type <- "Colless"
dd_models1 <- dd_model_names()
dd_models2 <- dd_model_names()[c(4:6, 1:3, 1, 10, 2, 8)]

imbl_res_ls <- map2(dd_models1, dd_models2, function(dd_model1, dd_model2) {
  cat("DD model =", dd_model1, "vs", dd_model2, "\n")
  phylos_empirical <- readRDS(
    glue::glue("../fabrika/comrad_data/phylos/dd_phylos_{dd_model2}_sigk_1_siga_0.1.rds")
  )
  phylos_bootstrap <- readRDS(
    glue::glue("../fabrika/comrad_data/phylos/dd_phylos_{dd_model1}_sigk_1_siga_0.1.rds")
  )
  res_ls <- test_dd_adequacy_imbalance(phylos_empirical, phylos_bootstrap, type = type)
  return(res_ls)
})

names(imbl_res_ls) <- dd_model_names()
imbl_tbl <- imbl_res_ls %>%
  map_dfr(function(x) {
    bind_rows(
      tibble::tibble("imbl" = x$imbalance_empirical, "set" = "empirical"),
      tibble::tibble("imbl" = x$imbalance_bootstrap, "set" = "bootstrap")
    )
  }, .id = "dd_model")

gg <- imbl_tbl %>%
  ggplot(aes(x = imbl, fill = set)) +
  geom_density(alpha = 0.8) +
  theme_bw() +
  facet_wrap(vars(dd_model), ncol = 5, nrow = 2) +
  labs(title = glue::glue("DD vs opposite DD, {type} index"))
gg

# 3. comrad test
type <- "Colless"
phylos_empirical <- readRDS(
  glue::glue("../fabrika/comrad_data/phylos/comrad_phylos_sigk_1_siga_0.1_full.rds")
)
imbl_res_ls <- dd_model_names() %>%
  map(function(dd_model) {
    cat("DD model =", dd_model, "\n")
    phylos_bootstrap <- readRDS(
      glue::glue("../fabrika/comrad_data/phylos/dd_phylos_{dd_model}_sigk_1_siga_0.1.rds")
    )
    res_ls <- test_dd_adequacy_imbalance(phylos_empirical, phylos_bootstrap, type = type)
    return(res_ls)
})

names(imbl_res_ls) <- dd_model_names()
imbl_tbl <- imbl_res_ls %>%
  map_dfr(function(x) {
    bind_rows(
      tibble::tibble("imbl" = x$imbalance_empirical, "set" = "empirical"),
      tibble::tibble("imbl" = x$imbalance_bootstrap, "set" = "bootstrap")
    )
  }, .id = "dd_model")

gg <- imbl_tbl %>%
  ggplot(aes(x = imbl, fill = set)) +
  geom_density(alpha = 0.8) +
  theme_bw() +
  facet_wrap(vars(dd_model), ncol = 5, nrow = 2) +
  labs(title = glue::glue("comrad vs DD, {type} index"))
gg

ragg::agg_png(
  "~/Github/fabrika/figs/imbl_colless_comrad_vs_dd.png",
  width = 20,
  height = 10,
  units = "cm",
  scaling = 1,
  res = 300
)
gg
invisible(dev.off())

imbl_diff_tbl <- imbl_res_ls %>%
  map_dfr(function(x) {
    bind_rows(
      tibble::tibble("delta" = x$delta_imbalance_empirical, "set" = "empirical"),
      tibble::tibble("delta" = x$delta_imbalance_bootstrap, "set" = "bootstrap")
    )
  }, .id = "dd_model")

qt95_tbl <- imbl_diff_tbl %>%
  dplyr::filter(set == "bootstrap") %>%
  group_by(dd_model) %>%
  summarise(
    "qt_95" = quantile(delta, probs = 0.95)
  )

gg <- imbl_diff_tbl %>%
  ggplot(aes(x = delta, fill = set)) +
  geom_density(alpha = 0.8) +
  theme_bw() +
  facet_wrap(vars(dd_model), ncol = 5, nrow = 2) +
  geom_vline(aes(xintercept = qt_95), data = qt95_tbl, colour = "#FCA49B") +
  labs(title = glue::glue("comrad vs DD, {type} index"), x = "absolute difference")

ragg::agg_png(
  "~/Github/fabrika/figs/imbl_diff_colless_comrad_vs_dd.png",
  width = 20,
  height = 10,
  units = "cm",
  scaling = 1,
  res = 300
)
gg
invisible(dev.off())

