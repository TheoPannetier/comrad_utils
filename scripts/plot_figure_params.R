# Param estimates
siga <- 0.1
sigk <- 1

mls_without_fossil <- comrad_params_retained() %>%
  pmap(function(siga, sigk) {
    cat(siga, sigk, "\n")
    readRDS(glue::glue("../fabrika/comrad_data/ml_results/ml_without_fossil_sigk_{sigk}_siga_{siga}_new.rds")) %>%
      filter_aic_best2()
  })

mls_with_fossil <- comrad_params_retained() %>%
  pmap(function(siga, sigk) {
    cat(siga, sigk, "\n")
    ml_with <- readRDS(glue::glue("../fabrika/comrad_data/ml_results/ml_with_fossil_sigk_{sigk}_siga_{siga}.rds"))
  })

hat_k_tbl <- readRDS("../fabrika/scripts/hat_k_estimates.rds") %>%
  dplyr::transmute(k_estimate, "sig_a" = round(siga, 1), "sig_k" = sigk)

gg_ls <- comrad_params_retained() %>%
  pmap(function(siga, sigk) {
  #if (!are_params_retained(siga, sigk)) return(NULL)
  cat(siga, sigk, "\n")

  ml <- readRDS(glue::glue("../fabrika/comrad_data/ml_results/ml_without_fossil_sigk_{sigk}_siga_{siga}_new.rds")) %>%
    filter_aic_best2()

  ml_with <- readRDS(glue::glue("../fabrika/comrad_data/ml_results/ml_with_fossil_sigk_{sigk}_siga_{siga}.rds"))

  # gg_aicw <- ml %>%
  #   dplyr::filter(!is.nan(aicw)) %>%
  #   ungroup(tree) %>%
  #   group_by(dd_model) %>%
  #   summarise("aicw" = mean(aicw)) %>%
  #   ggplot(aes(y = aicw, x  = 1, fill = dd_model)) +
  #   geom_col(show.legend = FALSE) +
  #   scale_fill_manual(values = dd_model_colours()) +
  #   theme_void() +
  #   labs(
  #     title = bquote(sigma[K] ~ "=" ~ .(sigk) ~ sigma[alpha] ~ "=" ~ .(siga))
  #   ) +
  #   coord_flip()

  gg_title <- cowplot::ggdraw() +
    cowplot::draw_label(
      label = bquote(sigma[K] ~ "=" ~ .(sigk) ~ sigma[alpha] ~ "=" ~ .(siga)),
      vjust = 0.5, hjust = 0.5
    ) +
    theme(panel.background = element_rect(fill = "grey80"))

  gg_lambda <- ml %>%
    ggplot(aes(y = ml_lambda_0, x = dd_model, fill = dd_model)) +
    geom_boxplot(outlier.size = 0.2, show.legend = FALSE) +
    geom_point(data = ml_with, size = 1, colour = "red", show.legend = FALSE) +
    geom_point(data = ml_with, size = 0.5, colour = "white", show.legend = FALSE) +
    theme_bw() +
    scale_y_log10() +
    scale_fill_manual(values = dd_model_colours()) +
    labs(
      y = bquote(lambda[0])
    ) +
    theme(
      axis.title.y = element_text(vjust = 0.5, angle = 0),
      axis.title.x = element_blank(),
      panel.background = element_rect(fill = "#d8eaf2"),
      panel.grid = element_line(colour = "#c2d3db")
    )

  gg_mu <- ml %>%
    dplyr::mutate(
      dd_model = dd_model %>% fct_relevel("lc", "pc", "xc", "ll", "pl", "xl", "lp", "pp", "xp", "lx", "px", "xx")
      ) %>%
    ggplot(aes(y = ml_mu_0, x = dd_model, fill = dd_model)) +
    geom_boxplot(outlier.size = 0.2, show.legend = FALSE) +
    geom_point(data = ml_with, size = 1, colour = "red", show.legend = FALSE) +
    geom_point(data = ml_with, size = 0.5, colour = "white", show.legend = FALSE) +
    theme_bw() +
    scale_y_log10() +
    scale_fill_manual(values = dd_model_colours()) +
    labs(
      y = bquote(mu[0])
    ) +
    theme(
      axis.title.y = element_text(vjust = 0.5, angle = 0),
      axis.title.x = element_blank(),
      panel.background = element_rect(fill = "#efd5d0"),
      panel.grid = element_line(colour = "#d3bbb7")
    )

  y_max <- min(max(ml$ml_k, na.rm = TRUE), max(ml_with$ml_k) * 4)
  y_min <- min(min(ml$ml_k, na.rm = TRUE) * 0.8, min(ml_with$ml_k) * 0.8)

  hat_k <- readRDS("../fabrika/scripts/hat_k_estimates.rds") %>%
    dplyr::transmute(k_estimate, "sig_a" = round(siga, 1), "sig_k" = sigk) %>%
    dplyr::filter(near(sig_a, siga) & sig_k == sigk) %>%
    pull(k_estimate)

  gg_k <- ml %>%
    ggplot(aes(y = ml_k, x = dd_model, fill = dd_model)) +
    geom_boxplot(outlier.size = 0.2, show.legend = FALSE) +
    geom_hline(yintercept = hat_k, colour = "forestgreen") +
    geom_point(data = ml_with, size = 1, colour = "red", show.legend = FALSE) +
    geom_point(data = ml_with, size = 0.5, colour = "white", show.legend = FALSE) +
    theme_bw() +
    #scale_y_log10() +
    scale_fill_manual(values = dd_model_colours()) +
    labs(
      y = bquote(K)
    ) +
    theme(
      axis.title.y = element_text(vjust = 0.5, angle = 0),
      axis.title.x = element_blank(),
      panel.background = element_rect(fill = "#d0efd3"),
      panel.grid = element_line(colour = "#c3ddc5")
    ) +
    coord_cartesian(ylim = c(y_min, y_max))

  #y_max <- max(max(ml$ml_alpha, na.rm = TRUE), max(ml_with$ml_alpha, na.rm = TRUE))
  #y_min <- min(min(ml$ml_alpha, na.rm = TRUE), min(ml_with$ml_alpha, na.rm = TRUE))

  gg_phi <- ml %>%
    ggplot(aes(y = ml_alpha, x = dd_model, fill = dd_model)) +
    geom_boxplot(outlier.size = 0.2, show.legend = FALSE) +
    geom_point(data = ml_with, size = 1, colour = "red", show.legend = FALSE) +
    geom_point(data = ml_with, size = 0.5, colour = "white", show.legend = FALSE) +
    theme_bw() +
    scale_fill_manual(values = dd_model_colours()) +
    labs(
      y = bquote(phi)
    ) +
    theme(
      axis.title.y = element_text(vjust = 0.5, angle = 0),
      axis.title.x = element_blank(),
      panel.background = element_rect(fill = "#e8dbf6"),
      panel.grid = element_line(colour = "#d0c3dd")
    ) +
    coord_cartesian(ylim = c(0, 1))

  return(list(
    "gg_title" = gg_title,
    #"gg_aicw" = gg_aicw,
    "gg_lambda" = gg_lambda,
    "gg_mu" = gg_mu,
    "gg_k" = gg_k,
    "gg_phi" = gg_phi
  ))
})

gg_ls[[1]]$gg_phi

gg_ls <- purrr::compact(gg_ls)

ggs <- gg_ls %>% map(function(gg) {
  cowplot::plot_grid(
    gg$gg_title,
    cowplot::plot_grid(
      gg$gg_lambda, gg$gg_mu, gg$gg_k, gg$gg_phi,
      ncol = 4, align = "h"
    ),
    nrow = 2, rel_heights = c(0.10, 0.90)
  )
})

ggs1 <- ggs[1:3]
ggs2 <- ggs[4:8]
ggs3 <- ggs[9:15]
ggs4 <- ggs[16:23]
ggs5 <- ggs[24:32]
ggs5[[1]]


ggrid <- cowplot::plot_grid(
  plotlist = ggs1, nrow = 3, ncol = 1
)

filename <- "fig_params_sigk1.png"
path_local <- paste0("~/Github/fabrika/figs/", filename)

ragg::agg_png(
  path_local,
  width = 20, # 20 per col
  height = 4 * 3, # 4 per row
  units = "cm",
  scaling = 0.75,
  res = 300
  )
ggrid
invisible(dev.off())
