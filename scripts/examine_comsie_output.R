logbook <- read_logbook(pkg = "comsie") %>%
  dplyr::filter(batch_id %in% c("b35244"), status != "FAILED") %>%
  dplyr::arrange(desc(immigration_rate), competition_sd)

#row <- logbook[1,]

ggs <- logbook %>% pmap(function(...) {
  row <- tibble(...)
  job_id <- row$job_id
  siga <- row$competition_sd
  gamma <- row$immigration_rate
  nb_gens <- row$nb_gens
  cat("siga =", siga, "gamma =", gamma, "\n")
  predicted_k <- predict_k(siga, 4)
  comsie_tbl <- read_comsie_tbl(path_to_sim_hd(job_id, "comsie"))

  t_max <- max(comsie_tbl$t)

  nb_species <- comsie_tbl %>% dplyr::filter(t == t_max) %>%
    distinct(species) %>% nrow()

  gg <- comsie_tbl %>%
    plot_zt(
      fill_by = "clade",
      xlim = c(0, t_max),
      ylim = c(-10, 10),
      binwidths = c(200, 0.01),
      alpha = 1
    ) +
    labs(title = glue::glue(
      "siga = {siga}\t",
      "gamma = {gamma}\t",
      "t = {t_max} / {nb_gens}\t",
      " N = {nb_species}"
    ))
  #ggsave(filename = glue::glue("../comsie_ms/figs/zt_test_siga_{siga}_gamma_{gamma}_clade.png"), plot = gg, width = 20, height = 10)
  return(gg)
})

ggrid <- cowplot::plot_grid(
  plotlist = ggs, nrow = 6, ncol = 9
)

filename <- "zt_test_all.png"
path_local <- paste0("~/Github/comsie_ms/figs/", filename)

ragg::agg_png(
  path_local,
  width = 90,
  height = 30,
  units = "cm",
  scaling = 0.5,
  res = 300
)
ggrid
invisible(dev.off())

###########

ggs <- logbook %>% pmap(function(...) {
  row <- tibble(...)
  job_id <- row$job_id
  siga <- row$competition_sd
  gamma <- row$immigration_rate
  nb_gens <- row$nb_gens
  cat("siga =", siga, "gamma =", gamma, "\n")
  predicted_k <- predict_k(siga, 4)
  comsie_tbl <- read_comsie_tbl(path_to_sim_hd(job_id, "comsie"))

  t_max <- max(comsie_tbl$t)

  nb_species <- comsie_tbl %>% dplyr::filter(t == t_max) %>%
    distinct(species) %>% nrow()

  comsie_tbl %>%
    comrad::plot_comm_size()

  species_names <- unique(comsie_tbl$species)
  names(species_names) <- species_names
  comsie_tbl$species <- factor(comsie_tbl$species, levels = species_names)

  comsie_tbl %>%
    dplyr::group_by(t, species) %>%
    dplyr::count() %>%
    ggplot2::ggplot(ggplot2::aes(x = t, y = n)) +
    ggplot2::labs(x = "Generation", y = "Nb of individuals") +
    ggplot2::geom_area(ggplot2::aes(fill = species), show.legend = FALSE) +
    ggplot2::scale_colour_manual(
      values = species_names, aesthetics = "fill"
    )


  labs(title = glue::glue(
    "siga = {siga}\t",
    "gamma = {gamma}\t",
    "t = {t_max} / {nb_gens}\t",
    " N = {nb_species}"
  ))
  #ggsave(filename = glue::glue("../comsie_ms/figs/zt_test_siga_{siga}_gamma_{gamma}_clade.png"), plot = gg, width = 20, height = 10)
  return(gg)
})


summary_tbl1 <- logbook %>%
  dplyr::select(job_id, competition_sd, immigration_rate, nb_gens) %>%
  mutate("predicted_k" = round(predict_k(competition_sd, 3)))

summary_tbl2 <- logbook$job_id %>% map_dfr(function(job_id) {
  cat(job_id, "\n")
  comsie_tbl <- read_comsie_tbl(path_to_sim_hd(job_id, "comsie"))
  t_max <- max(comsie_tbl$t)
  last_gen <- comsie_tbl %>% dplyr::filter(
    t == t_max
  )
  nb_inds <- nrow(last_gen) * 20
  nb_species <- last_gen %>% distinct(species) %>% nrow()
  return(tibble::tibble(
    "t_max" = t_max,
    "nb_inds" = nb_inds,
    "nb_species" = nb_species
  ))
})

summary_tbl <- bind_cols(summary_tbl1, summary_tbl2) %>%
  relocate(t_max, .before = nb_gens) %>%
  relocate(predicted_k, .after = nb_species) %>%
  mutate("completion" = round(t_max / nb_gens, 2), .after = nb_gens)

# saveRDS(summary_tbl, file = "comsie_data/summary_b35244.rds")
job_id <- 22748966
comsie_tbl <- read_comsie_tbl(path_to_sim_hd(job_id, pkg = "comsie"))

comsie_tbl %>%
  group_by(t, species) %>%
  distinct(species) %>%
  ungroup(species) %>%
  count() %>%
  ggplot(aes(x = t, y = n)) +
  geom_line() +
  theme_bw()

tibble(
  z = seq(-10, 10, 0.01),
  k_z = 1000 * exp(-(z^2) / (2 * 3 ^ 2)),
  sigk = "3"
) %>%
  bind_rows(
    tibble(
      z = seq(-10, 10, 0.01),
      k_z = 1000 * exp(-(z^2) / (2 * 4 ^ 2)),
      sigk = "4"
    )
  ) %>%
  ggplot(aes(x = z, y = k_z, group = sigk, fill = sigk)) +
  geom_area(position = "identity", alpha = 0.5) +
  theme_bw()

summary_tbl %>%
  slice(c(-46,-37)) %>%
  dplyr::group_by(competition_sd) %>%
  summarise("completion" = min(completion)) %>%
  arrange(desc(competition_sd)) %>%
  mutate(
    "extend_by" = 1 / completion,
    "walltime" = walltime_vec_comsie(),
    "extended_walltime" = hms::as_hms(round(runtime_to_hms(walltime) * extend_by))
  ) %>%
  pull(extended_walltime) %>%
  as.character()

a <- runtime_to_hms(walltime_vec_comsie()) * 1.2
hms::as_hms(a)

walltime_vec_comsie() %>% map(hms::as_hms)
