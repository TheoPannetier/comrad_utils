wt_comrad <- readRDS("../fabrika/comrad_data/phylos/comrad_phylos_sigk_1_siga_0.1_on_event.rds") %>%
  map_dfr(waiting_times, .id = "replicate") %>%
  mutate(sim = "comrad", event = factor(next_event, levels = c("speciation", "extinction")))

wt_dd_xx <- readRDS("../fabrika/comrad_data/phylos/dd_phylos_xx_sigk_1_siga_0.1.rds") %>%
  map_dfr(waiting_times, .id = "replicate") %>%
  mutate(sim = "dd_xx", event = factor(next_event, levels = c("speciation", "extinction")))

bind_rows(wt_comrad, wt_dd_xx) %>%
  dplyr::filter(N == 30) %>%
  ggplot(aes(x = waiting_time, fill = sim)) +
  # geom_bar(stat = "density", width = 1000)
  geom_histogram(alpha = 0.5, binwidth = 100, position = "identity") +
  theme_bw() +
  facet_grid(rows = vars(event), labeller = "label_both") +
  labs(title = "N = 30")

#####

wt_comrad_on_event <- readRDS("../fabrika/comrad_data/phylos/comrad_phylos_sigk_1_siga_0.1_on_event.rds") %>%
  map_dfr(waiting_times, .id = "replicate") %>%
  mutate(sampling_on_event = TRUE, event = factor(next_event, levels = c("speciation", "extinction")))

wt_comrad_freq <- readRDS("../fabrika/comrad_data/phylos/comrad_phylos_sigk_1_siga_0.1.rds") %>%
  map_dfr(waiting_times, .id = "replicate") %>%
  mutate(sampling_on_event = FALSE, event = factor(next_event, levels = c("speciation", "extinction")))

wt <- bind_rows(wt_comrad_on_event, wt_comrad_freq)

wt %>%
  dplyr::filter(N == 30) %>%
  ggplot(aes(x = waiting_time, fill = sampling_on_event)) +
  # geom_bar(stat = "density", width = 1000)
  geom_histogram(alpha = 0.5, binwidth = 100, position = "identity") +
  theme_bw() +
  facet_grid(rows = vars(event), labeller = "label_both") +
  labs(title = "N = 30")

N_seq <- unique(wt_comrad$N)
ggs <- map(N_seq, function(that_N) {
   wt %>%
    dplyr::filter(N == that_N) %>%
    ggplot(aes(x = waiting_time, fill = sampling_on_event)) +
    # geom_bar(stat = "density", width = 1000)
    geom_histogram(binwidth = 100, position = "identity", alpha = 0.6) +
    theme_bw() +
    facet_grid(rows = vars(event), labeller = "label_both") +
    scale_fill_manual(values = c("#f1a340", "#998ec3")) +
    labs(title = glue::glue("N = {that_N}"))
})
legend <- cowplot::ggdraw(cowplot::get_legend(ggs[[1]]))
ggs <- map(ggs, function(gg) gg + theme(legend.position = "none"))
ggs[[length(ggs) + 1]] <- legend
ggs[[38]]
ggrid <- cowplot::plot_grid(plotlist = ggs, ncol = 8, nrow = 5)
ragg::agg_png(
  "~/Github/fabrika/figs/wt_sampling_on_off.png",
  width = 40,
  height = 20,
  units = "cm",
  scaling = 1,
  res = 300
)
ggrid
invisible(dev.off())

comrad_tbl <- read_comrad_tbl("../fabrika/comrad_data/sims/comrad_sim_17929840.csv")

times <- wt_comrad_on_event %>%
  dplyr::filter(replicate == "17929840", waiting_time == 0) %>%
  pull(time)

wt_17929840 <- comrad_tbl %>% sim_to_phylo() %>% waiting_times()

ltt_tbl <- comrad_tbl %>% sim_to_phylo() %>% get_ltt_tbl() %>%
  dplyr::mutate("time" = time - min(time))

comrad_tbl %>%
  exclude_ephemeral_spp() %>%
  plot_comm_trait_evolution(xgrain = 100) + theme_bw() +
  geom_vline(xintercept = 5167, size = 0.2, alpha = 0.5)

ltt_tbl[16:25, ] # around t = 5167

unique(comrad_tbl$species[comrad_tbl$t == 6036]) %>% length()

