#######################################
# 1 -- Figure AICW pies with fossil

empty_half <- tibble(
  "dd_model" = "0_not_a_model",
  "aicw" = 1,
  "speciation_func" = "0_not_a_model",
  "extinction_func" = "0_not_a_model"
)

bar <- tibble("x" = c(-1, 1), "y" = 0) %>%
  ggplot(aes(x = x, y = y)) +
  geom_line() +
  theme_bw() +
  cowplot::draw_label("Speciation", x = -1, y = 0.05 / 8, hjust = 0, angle = 90, size = 8) +
  cowplot::draw_label("Extinction", x = -1, y = -0.05 / 8, hjust = 1, angle = 90, size = 8) +
  theme_void()

siga <- 0.1
sigk <- 4

ggs <- comrad_params_grid() %>% pmap(function(sigk, siga) {
  if(!are_params_retained(siga, sigk)) return(patchwork::plot_spacer())
  cat(siga, sigk, "\n")

  ml <- readRDS(glue::glue("../fabrika/comrad_data/ml_results/ml_with_fossil_sigk_{sigk}_siga_{siga}.rds")) %>%
    dplyr::mutate(
      "speciation_func" = dd_model_to_speciation_func(dd_model),
      "extinction_func" = dd_model_to_extinction_func(dd_model)
    )

  gg1 <- ml %>%
    bind_rows(empty_half) %>%
    dplyr::group_by(speciation_func) %>%
    summarise("aicw" = sum(aicw)) %>%
    ggplot(aes(x = "", y = aicw, fill = speciation_func)) +
    geom_bar(stat = "identity", width = 1,
             show.legend = FALSE) +
    coord_polar("y", start = 270 / 180 * pi) +
    theme_void() +
    scale_fill_manual(values = c("0_not_a_model" = "transparent", dd_func_colours()))

  gg2 <- ml %>%
    bind_rows(empty_half) %>%
    dplyr::group_by(extinction_func) %>%
    summarise("aicw" = sum(aicw)) %>%
    ggplot(aes(x = "", y = aicw, fill = extinction_func)) +
    geom_bar(stat = "identity", width = 1,
             show.legend = FALSE) +
    coord_polar("y", start = 90 / 180 * pi) +
    theme_void() +
    scale_fill_manual(values = c("0_not_a_model" = "transparent", dd_func_colours()))

  gg <- gg1 + gg2 + bar +
    plot_layout(design = c(
      area(t = 1, l = 1, b = 1, r = 1),
      area(t = 1, l = 1, b = 1, r = 1),
      area(t = 1, l = 1, b = 1, r = 1)
    )) +
    labs(title = bquote(sigma[K] ~ "=" ~ .(sigk) ~~ sigma[alpha] ~ "=" ~ .(siga)))
  return(gg)
})

{
  gg_legend <- tibble::tibble(
    "y" = 1,
    "Function" = dd_func_names()
  ) %>%
    ggplot(aes(x = Function, y = y, fill = Function)) +
    geom_col() +
    scale_fill_manual(values = dd_func_colours())

  legend <- cowplot::get_legend(gg_legend)
  ggs[[4]] <- legend
  ggs[[16]] <- legend
  ggs[[28]] <- legend
  ggs[[39]] <- legend
  ggs[[50]] <- legend
}

ggrid <- patchwork::wrap_plots(
  ggs, ncol = 10, nrow = 5
)

filename <- "pies_ml_with_fossil_funcs.png"
path_local <- paste0("~/Github/fabrika/figs/", filename)
path_drive <- paste0("comrad/figs/", filename)

ragg::agg_png(
  path_local,
  width = 60,
  height = 20,
  units = "cm",
  scaling = 1,
  res = 300
  )
ggrid
invisible(dev.off())

googledrive::drive_upload(path_local, path_drive, overwrite = TRUE)
fig_dribble <- googledrive::drive_share_anyone(path_drive)
fig_dribble$drive_resource[[1]]$webContentLink

#######################################
# 2 -- Figure AICW pies without fossil

empty_half <- tibble(
  "dd_model" = "0_not_a_model",
  "aicw" = 1,
  "speciation_func" = "0_not_a_model",
  "extinction_func" = "0_not_a_model"
)

bar <- tibble("x" = c(-1, 1), "y" = 0) %>%
  ggplot(aes(x = x, y = y)) +
  geom_line() +
  theme_bw() +
  cowplot::draw_label("Speciation", x = -1, y = 0.05 / 8, hjust = 0, angle = 90, size = 8) +
  cowplot::draw_label("Extinction", x = -1, y = -0.05 / 8, hjust = 1, angle = 90, size = 8) +
  theme_void()

ggs <- comrad_params_grid() %>% pmap(function(sigk, siga) {
  if(!are_params_retained(siga, sigk)) return(patchwork::plot_spacer())
  cat(siga, sigk, "\n")

  ml <- readRDS(glue::glue("../fabrika/comrad_data/ml_results/ml_without_fossil_sigk_{sigk}_siga_{siga}.rds")) %>%
    filter_aic_best2() %>%
    ungroup() %>%
    dplyr::filter(!is.nan(aicw)) %>%
    dplyr::group_by(dd_model) %>%
    summarise(aicw = mean(aicw)) %>%
    dplyr::mutate(
      "speciation_func" = dd_model_to_speciation_func(dd_model),
      "extinction_func" = dd_model_to_extinction_func(dd_model)
    )

  gg1 <- ml %>%
    bind_rows(empty_half) %>%
    dplyr::group_by(speciation_func) %>%
    summarise("aicw" = sum(aicw)) %>%
    ggplot(aes(x = "", y = aicw, fill = speciation_func)) +
    geom_bar(stat = "identity", width = 1,
             show.legend = FALSE) +
    coord_polar("y", start = 270 / 180 * pi) +
    theme_void() +
    scale_fill_manual(values = c("0_not_a_model" = "transparent", dd_func_colours()))

  gg2 <- ml %>%
    bind_rows(empty_half) %>%
    dplyr::group_by(extinction_func) %>%
    summarise("aicw" = sum(aicw)) %>%
    ggplot(aes(x = "", y = aicw, fill = extinction_func)) +
    geom_bar(stat = "identity", width = 1,
             show.legend = FALSE) +
    coord_polar("y", start = 90 / 180 * pi) +
    theme_void() +
    scale_fill_manual(values = c("0_not_a_model" = "transparent", dd_func_colours()))

  gg <- gg1 + gg2 + bar +
    plot_layout(design = c(
      area(t = 1, l = 1, b = 1, r = 1),
      area(t = 1, l = 1, b = 1, r = 1),
      area(t = 1, l = 1, b = 1, r = 1)
    )) +
    labs(title = bquote(sigma[K] ~ "=" ~ .(sigk) ~~ sigma[alpha] ~ "=" ~ .(siga)))
  return(gg)
})

{
  gg_legend <- tibble::tibble(
    "y" = 1,
    "Function" = dd_func_names()
  ) %>%
    ggplot(aes(x = Function, y = y, fill = Function)) +
    geom_col() +
    scale_fill_manual(values = dd_func_colours())

  legend <- cowplot::get_legend(gg_legend)
  ggs[[4]] <- legend
  ggs[[16]] <- legend
  ggs[[28]] <- legend
  ggs[[39]] <- legend
  ggs[[50]] <- legend
}

ggrid <- patchwork::wrap_plots(
  ggs, ncol = 10, nrow = 5
)

filename <- "pies_ml_without_fossil_funcs.png"
path_local <- paste0("~/Github/fabrika/figs/", filename)
path_drive <- paste0("comrad/figs/", filename)

ragg::agg_png(
  path_local,
  width = 60,
  height = 20,
  units = "cm",
  scaling = 1,
  res = 300
)
ggrid
invisible(dev.off())

googledrive::drive_upload(path_local, path_drive, overwrite = TRUE)
fig_dribble <- googledrive::drive_share_anyone(path_drive)
fig_dribble$drive_resource[[1]]$webContentLink
