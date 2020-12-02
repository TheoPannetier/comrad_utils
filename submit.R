logbook <- read_logbook()

b49422 <- logbook %>% dplyr::filter(
  batch_id == "b49422", carrying_cap_sd == 1
) %>%
  dplyr::arrange(
    carrying_cap_sd, competition_sd
  ) %>%
  select(
    job_id,
    competition_sd,
    carrying_cap_sd,
    runtime,
    nb_gens
  )

comrad_tbls <- b49422$job_id %>%
  purrr::map(function(job_id) {
    read_comrad_tbl(
      glue::glue("~/Github/fabrika/comrad_data/sims/comrad_sim_{job_id}.csv"),
      skip = 19
    )
  })
names(comrad_tbls) <- b49422$job_id

b49422 <- b49422 %>%
  mutate(
    "nb_gens_run" = map_dbl(job_id, function(id) {
      max(comrad_tbls[[id]]$t)
    }),
    "predicted_neq" = round(3.5 * carrying_cap_sd * exp(-competition_sd) /
                              competition_sd)
  )

ltt_tbl <- b49422 %>%
  pmap_dfr(function(...) {
    row <- tibble(...)
    comrad_tbls[[row$job_id]] %>%
      group_by(t, species) %>%
      dplyr::count() %>%
      group_by(t) %>%
      dplyr::count() %>%
      mutate(
        "competition_sd" = row$competition_sd,
        "carrying_cap_sd" = row$carrying_cap_sd
      )
  }) %>%
  bind_rows()

predict_tbl <- ltt_tbl %>%
  group_by(competition_sd) %>%
  nest() %>%
  mutate(
    "slope" = map(data, function (tbl) {
      tbl %>%
        lm(n ~ t, data = .) %>% coef() %>% .[[2]]
    })
  ) %>%
  unnest(cols = c(data, slope)) %>%
  select(-n, -t) %>%
  distinct() %>%
  mutate(
    "d_eq" = round(3.5 * carrying_cap_sd * exp(-competition_sd) / competition_sd),
    "gens_to_d_eq" = 2 * round(d_eq / slope)
  )

predict_tbl$gens_to_d_eq[10] <- predict_tbl$gens_to_d_eq[9]

b49422 <- b49422 %>%
  mutate(
    "gens_to_d_eq" = predict_tbl %>%
      pull(gens_to_d_eq)
  )

params_array <- fabrika::create_comrad_params(
  competition_sd = seq(0.1, 1, by = 0.1),
  carrying_cap_sd = 1
) %>%
  expand.grid()

nb_gens <- round(
  b49422$gens_to_d_eq,
  digits = -3
)
nb_gens

walltime <- b49422$runtime %>%
  fabrika::runtime_to_hms() %>%
  # Average time (in secs) per generation
  magrittr::divide_by(b49422$nb_gens_run) %>%
  # Predicted time given the new nb of generations
  magrittr::multiply_by(nb_gens) %>%
  round() %>%
  hms::as_hms() %>%
  as.character() %>%
  stringr::str_extract("[:graph:]+$")
walltime

fabrika::run_comrad_sim_hpc(
  nb_gens = nb_gens,
  params_array = params_array,
  nb_replicates = 100,
  sampling_frac = 0.05,
  sampling_freq = 200,
  walltime = walltime,
  brute_force_opt = "simd_omp"
)


