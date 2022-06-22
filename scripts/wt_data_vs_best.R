siga <- 0.1
sigk <- 1

wt_data <- readRDS(
  glue::glue("../fabrika/comrad_data/phylos/comrad_phylos_sigk_{sigk}_siga_{siga}_full.rds")
) %>%
  map_dfr(waiting_times, .id = "replicate") %>%
  mutate(
    event = factor(next_event, levels = c("speciation", "extinction")),
    model = "data"
  )

best_model <- "xx"

wt_best <- readRDS(
  glue::glue("../fabrika/comrad_data/phylos/dd_phylos_{best_model}_sigk_{sigk}_siga_{siga}.rds")
) %>%
  map_dfr(waiting_times, .id = "replicate") %>%
  mutate(
    event = factor(next_event, levels = c("speciation", "extinction")),
    model = best_model
  )

wt <- bind_rows(wt_data, wt_best)
N_seq <- unique(wt$N)

RColorBrewer::brewer.pal(7, "Dark2")

ggs <- map(N_seq, function(that_N) {
  wt %>%
    dplyr::filter(N == that_N) %>%
    ggplot(aes(x = waiting_time, fill = model)) +
    geom_histogram(binwidth = 20, position = "identity", alpha = 0.6) +
    theme_bw() +
    facet_grid(cols = vars(event), labeller = "label_value") +
    #scale_fill_manual(values = c("#A6761D", "#E6AB02")) +
    labs(title = glue::glue("N = {that_N}"))
})
ggs[[35]]
legend <- cowplot::ggdraw(cowplot::get_legend(ggs[[1]]))
ggs <- map(ggs, function(gg) gg + theme(legend.position = "none"))
ggs[[length(ggs) + 1]] <- legend

ggrid <- cowplot::plot_grid(plotlist = ggs, ncol = 5, nrow = 8)

ragg::agg_png(
  glue::glue("~/Github/fabrika/figs/wt_data_vs_best_sigk_{sigk}_siga_{siga}.png"),
  width = 40,
  height = 50,
  units = "cm",
  scaling = 1,
  res = 300
)
ggrid
invisible(dev.off())
