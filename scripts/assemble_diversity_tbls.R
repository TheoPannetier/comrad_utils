args <- expand_grid(
  "siga" = siga_vec_comsie()[c(1, 2, 4, 7, 9)],
  "gamma" =  c(0, 1e-04, 5e-04, 1e-03, 1e-02)
)

logbook <- read_logbook(pkg = "comsie") %>%
  dplyr::filter(
    competition_sd %in% siga_vec_comsie()[c(1, 2, 4, 7, 9)],
    immigration_rate %in% c(0, 1e-05, 5e-04, 1e-04, 1e-03, 1e-02)
  )

siga <- 0.091
gamma <- 1e-02

args %>% pwalk(function(siga, gamma) {
  cat("siga = ", siga, "gamma =", gamma, "\n")
  job_ids <- logbook %>%
    dplyr::filter(
      near(competition_sd, siga),
      near(immigration_rate, gamma)
    ) %>% pull(job_id)

  diversity_tbl <- job_ids %>% map_dfr(function(job_id) {
    read_comsie_tbl(path_to_sim_hd(job_id, pkg = "comsie")) %>%
      split_founder_col() %>%
      group_by(t, mainland_sp, immig_nb) %>%
      summarise("N" = n_distinct(species)) %>%
      dplyr::mutate("job_id" = job_id, .before = t)
    # fs::as_fs_bytes(object.size(comsie_tbl))
  })
  saveRDS(
    diversity_tbl,
    file = glue::glue("/Volumes/morozilka/comsie_data/diversity/diversity_siga_{siga}_gamma_{gamma}.rds")
  )
  rm(diversity_tbl)
})
