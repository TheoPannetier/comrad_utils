ggrids <- list(1:16, 17:32) %>% map(function(i) {
  cowplot::plot_grid(
    plotlist = ggs[i],
    align = "hv", nrow = 4, ncol = 4
  ) %>%
    cowplot::plot_grid(
      legend,
      ncol = 2, rel_widths = c(0.9, 0.1)
    )
})

i <- 2
filename <- glue::glue("{title}_{i}.png")
path_local <- paste0("~/Github/fabrika/figs/", filename)
cat(path_local, '\n')

ragg::agg_png(
  path_local,
  width = 40,
  height = 20,
  units = "cm",
  scaling = 1,
  res = 300
)
ggrids[[i]]
invisible(dev.off())

