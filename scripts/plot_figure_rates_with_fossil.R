siga <- 0.2
sigk <- 3

# Figure ML rates
gg <- comrad_params_grid()[1,] %>%
  pmap(function(siga, sigk) {
    cat(siga, sigk, "\n")
    ml_tbl <- readRDS(
      glue::glue(
        "../fabrika/comrad_data/ml_results/ml_with_fossil_sigk_{sigk}_siga_{siga}.rds"
      )
    ) %>%
      filter_aic_best() %>%
      dplyr::mutate(
        "speciation_func" = dd_model_to_speciation_func(dd_model),
        "extinction_func" = dd_model_to_extinction_func(dd_model)
      )

    ml_speciation <- ml_tbl %>% group_by(speciation_func) %>% slice_min(aic)
    ml_extinction <- ml_tbl %>% group_by(extinction_func) %>% slice_min(aic)

    phylos <- readRDS(
      glue::glue(
        "../fabrika/comrad_data/phylos/comrad_phylos_sigk_{sigk}_siga_{siga}.rds"
      )
    )

    wt <- phylos %>% map_dfr(waiting_times, .id = "tree")
    n_max <- max(wt$N)
    y_max <- ml_tbl %>%
      dplyr::filter(str_detect(dd_model, "^x")) %>%
      pull(ml_lambda_0) %>%
      max()
    visited_Ns <- wt %>%
      dplyr::distinct(N, next_event) %>%
      dplyr::rename("rate" = next_event)

    rates_no_model <- wt %>%
      rates_from_exp_dist()

    rates_speciation <- map_dfr(ml_speciation$dd_model, function(ddmod) {
      params <- ml_tbl %>%
        dplyr::filter(dd_model == ddmod) %>%
        select(starts_with("ml_")) %>%
        unlist()
      names(params) <- substr(names(params), 4, 1000)
      if (stringr::str_detect(ddmod, "c")) {
        params <- params[-4] # rm alpha
      }
      rates_from_dd_model(
        N_seq = 1:n_max,
        dd_model = dd_models()[[ddmod]],
        params = params
      )
    }) %>%
      dplyr::filter(rate == "speciation")

    rates_extinction <- map_dfr(ml_extinction$dd_model, function(ddmod) {
      params <- ml_tbl %>%
        dplyr::filter(dd_model == ddmod) %>%
        select(starts_with("ml_")) %>%
        unlist()
      names(params) <- substr(names(params), 4, 1000)
      if (stringr::str_detect(ddmod, "c")) {
        params <- params[-4] # rm alpha
      }
      rates_from_dd_model(
        N_seq = 1:n_max,
        dd_model = dd_models()[[ddmod]],
        params = params
      )
    }) %>%
      dplyr::filter(rate == "extinction")

    rates_tbl <- bind_rows(
      rates_no_model,
      rates_speciation,
      rates_extinction
    ) %>%
      right_join(visited_Ns) %>%
      dplyr::mutate(
        "dd_func" = ifelse(
          dd_model == "none", "none",
          ifelse(rate == "speciation",
                 dd_model_to_speciation_func(dd_model),
                 dd_model_to_extinction_func(dd_model)
          )
        ),
        "siga" = siga,
        "sigk" = sigk
      )

    best_spec <- ml_tbl %>% slice_max(aicw) %>% pull(speciation_func)
    best_ext <- ml_tbl %>% slice_max(aicw) %>% pull(extinction_func)

    rates_tbl %>%
      dplyr::mutate("rate" = forcats::as_factor(rate)) %>%
      ggplot(aes(x = N, y = value, linetype = rate, colour = dd_func)) +
      geom_line(
        show.legend = TRUE,
        data = rates_tbl %>%
          dplyr::filter(dd_func %in% c("none", best_spec, best_ext))%>%
          dplyr::mutate("rate" = forcats::as_factor(rate))
      ) +
      geom_line(
        show.legend = TRUE,
        alpha = 0.9,
        data = rates_tbl %>%
          dplyr::filter(!dd_func %in% c("none", best_spec, best_ext)) %>%
          dplyr::mutate("rate" = forcats::as_factor(rate))
        ) +
      geom_point(size = 1/3, show.legend = FALSE) +
      scale_colour_manual(values = c("none" = "black", dd_func_colours())) +
      scale_y_log10() +
      theme_bw() +
      labs(
        title = bquote(
          sigma[K] ~ "=" ~ .(sigk) ~~ sigma[alpha] ~ "=" ~ .(siga)
        ),
        y = "Per-capita rate",
        linetype = "",
        colour = "DD function"
      )
  })

#gg <- gg[[1]]
# ggs [1, ] but turn show.legend TRUE
legend <- cowplot::plot_grid(cowplot::get_legend(gg))
legend

ggs <- compact(ggs)
ggs2 <- ggs[1:16] %>% append(list(NULL, NULL,  legend, NULL))
ggs3 <- ggs[17:32]%>% append(list(NULL, NULL, legend, NULL))

# ggs2 <- ggs %>% prepend(list(legend), before = 5)

ggrid2 <- cowplot::plot_grid(
  plotlist = ggs2, ncol = 4, nrow = 5
)

ggrid3 <- cowplot::plot_grid(
  plotlist = ggs3, ncol = 4, nrow = 5
)

filename <- "fig_ml_rates_with_fossil_1.png"
path_local <- paste0("~/Github/fabrika/figs/", filename)

ragg::agg_png(
  path_local,
  width = 60,
  height = 60,
  units = "cm",
  scaling = 1.5,
  res = 300
  )
ggrid2
invisible(dev.off())

filename <- "fig_ml_rates_with_fossil_2.png"
path_local <- paste0("~/Github/fabrika/figs/", filename)

ragg::agg_png(
  path_local,
  width = 60,
  height = 60,
  units = "cm",
  scaling = 1.5,
  res = 300
)
ggrid3
invisible(dev.off())

save(plot_ml_rate_with_fossil, plot_ml_rate_without_fossil, file = "../fabrika/comrad_data/plots.RData")
