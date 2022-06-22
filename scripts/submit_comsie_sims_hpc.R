upload_bash_hpc("bash/install_comsie.bash")
upload_bash_hpc("bash/run_comsie_sim.bash")

install_comrad_hpc()

devtools::install("../comsie/")

comrad::get_n_eff(rnorm(100, 0, 1), 0.1, "none")

upload_bash_hpc("bash/run_comsie_sim.bash")
upload_rscript_hpc("R/run_comsie_sim_hpc.R")

{
  nb_gens = 1000
  params_array <- create_comsie_params() %>% expand.grid()
  nb_replicates = 1
  sampling_on_event = FALSE
  sampling_freq = ifelse(
    sampling_on_event, NA, 200
  )
  sampling_frac = comrad::default_sampling_frac()
  seeds = sample(1:50000, nb_replicates * nrow(params_array))
  walltime = "00:57:00"
  check_pkgs_version = FALSE
  brute_force_opt = "simd_omp"
}

logbook <- read_logbook(pkg = "comsie")

logbook %>% group_by(status) %>%
  count()

ns <- logbook %>%
  group_by(immigration_rate, competition_sd) %>%
  count() %>%
  arrange(desc(competition_sd), desc(immigration_rate)) %>%
  dplyr::mutate("nb_replicates" = 100 - n)

sum(ns$nb_replicates)

ns %>% pwalk(function(...) {
  row <- tibble(...)
  competition_sd <- row$competition_sd
  immigration_rate <- row$immigration_rate
  nb_replicates <- row$nb_replicates
  if (nb_replicates <= 0) return()
  cat(immigration_rate, competition_sd, nb_replicates, "\n")

  params_array <- create_comsie_params(
    #immigration_rate = c(1, 0.1, 0.01, 0.001, 0.0005, 0.0001, 0),
    immigration_rate = immigration_rate,
    competition_sd = competition_sd,
    #competition_sd = siga_vec_comsie(),
    carrying_cap_sd = 3
  ) %>%
    expand.grid()

  walltime <- get_walltime(competition_sd)
  nb_gens <- get_nb_gens(competition_sd)
  seeds <- sample(1:500000, nb_replicates, replace = FALSE)

  run_comsie_sim_hpc(
    nb_gens = nb_gens,
    nb_replicates = nb_replicates,
    walltime = walltime,
    params_array = params_array,
    sampling_on_event = FALSE,
    sampling_freq = 200,
    check_pkgs_version = FALSE,
    sampling_frac = 0.05,
    seeds = seeds
  )
})
beepr::beep(1)

nb_gens <- sort(rep(nb_gens_vec_comsie(), 7), TRUE)
# walltime <- walltime_vec_comsie() %>% map(rep, 7) %>% unlist()
# seeds <- sample(1:50000, nrow(params_array) * nb_replicates)

sigas <- siga_vec_comsie()[c(1, 2, 4, 7, 9)]
competition_sd <- sigas[3]
sigas %>% walk(function(competition_sd) {
  params_array <- create_comsie_params(
    immigration_rate = c(
      1, 0.1#,
      #0.01, 0.001, 0.0005, 0.0001, 0
    ),
    competition_sd = competition_sd,
    carrying_cap_sd = 3
  ) %>%
    expand.grid()

  nb_replicates <- 100
  walltime <- get_walltime(competition_sd)
  #walltime <- "60:00:00"
  nb_gens <- get_nb_gens(competition_sd)
  seeds <- sample(1:50000, nrow(params_array) * nb_replicates, replace = FALSE)

  run_comsie_sim_hpc(
    nb_gens = nb_gens,
    nb_replicates = nb_replicates,
    walltime = walltime,
    params_array = params_array,
    sampling_on_event = FALSE,
    sampling_freq = 200,
    check_pkgs_version = FALSE,
    sampling_frac = 0.05,
    seeds = seeds
  )
})
beepr::beep(1)

cat /data/p282688/fabrika/comsie_data/logs/comsie_sim_22614677.log
cat /data/$USER/fabrika/comsie_data/logs/comsie_sim_22614673.log

download_logbook_hpc(pkg = "comsie")
logbook <- read_logbook(pkg = "comsie")
rm_logbook_entries(NULL, pkg = "comsie")
logbook$job_id %>% complete_logbook_entries(pkg = "comsie", vars = c("status", "runtime"))
# logbook[1:4,]$job_id %>% rm_logbook_entries(pkg = "comsie")

job_ids <- logbook[1:54,]$job_id
copy_sim_csv_to_hd(job_ids, pkg = "comsie")
copy_sim_log_to_hd(job_ids, pkg = "comsie")

fs::file_delete(glue::glue("comsie_data/sims/comsie_sim_{job_ids}.csv"))
fs::file_delete(glue::glue("comsie_data/logs/comsie_sim_{job_ids}.log"))

subset <- logbook %>% dplyr::filter(near(competition_sd, 0.369))

job_ids %>% download_sim_csv_hpc(pkg = "comsie")
job_ids %>% download_sim_log_hpc(pkg = "comsie")

comsie_tbl <- comsie::read_comsie_tbl(path_to_sim_hd(job_ids[3], pkg = "comsie"))

sum(logbook$csv_size)

job_ids %>% download_sim_log_hpc("comsie")

job_id <- logbook[1,]$job_id

gammas <- 10 ^ (0:-5)
siga <- 0.369

gammas %>% walk(function(gamma) {
  cat(siga, " ", gamma, "\n")
  job_id <- logbook %>%
    dplyr::filter(near(competition_sd, siga), near(immigration_rate, gamma)) %>%
    pull(job_id)
  comsie_tbl <- read_comsie_tbl(path_to_sim_hd(job_id, "comsie"))

  c("clade") %>% walk(function(fill_by) {
    gg <- comsie_tbl %>% plot_zt(
      xlim = c(0, max(comsie_tbl$t)),
      ylim = c(-1.5, 1.5),
      binwidths = c(200, 0.01),
      fill_by = fill_by,
      alpha = 3/4
    ) +
      labs(title = glue::glue("Simulation {job_id} coloured by {fill_by}"))

    ggsave(
      filename = glue::glue("../comsie_ms/figs/zt_gamma_{gamma}_siga_{siga}_by_{fill_by}.png"),
      plot = gg, width = 14, height = 7
    )
  })
})

subset %>% select(job_id, immigration_rate)

comsie_tbl <- read_comsie_tbl(path_to_sim_hd(22646830, "comsie"))
comsie_tbl %>% plot_zt(
  xlim = c(0, 25000),
  ylim = c(-1.5, 1.5),
  binwidths = c(200, 0.01),
  fill_by = "clade",
  alpha = 1
)
comsie_tbl %>% dplyr::filter(t == 15000) %>%
  group_by(species) %>% count()

logbook <- read_logbook(pkg = "comsie")
subset <- logbook %>%
  dplyr::filter(
    batch_id %in% c("b35244")
  )
sum(subset$csv_size)
job_ids <- subset %>% dplyr::filter(
  status == "COMPLETED"
) %>% pull(job_id)
job_ids %>% download_sim_log_hpc("comsie")
job_ids %>% download_sim_csv_hpc("comsie")

job_ids %>% complete_logbook_entries(pkg = "comsie", vars = c("status", "runtime","csv_size"))

copy_sim_csv_to_hd(job_ids, pkg = "comsie")
copy_sim_log_to_hd(job_ids, pkg = "comsie")
fs::file_delete(glue::glue("comsie_data/sims/comsie_sim_{job_ids}.csv"))
fs::file_delete(glue::glue("comsie_data/logs/comsie_sim_{job_ids}.log"))

comsie_tbl <- read_comsie_tbl(path_to_sim_hd(22667894, "comsie"))
devtools::load_all("../comsie/")

comsie_tbl %>%
  plot_zt(
    fill_by = "species",
    xlim = c(0, max(comsie_tbl$t)),
    #xlim = c(35000, 50000),
    ylim = c(-10, 10),
    binwidths = c(200, 0.01),
    alpha = 1
  )

