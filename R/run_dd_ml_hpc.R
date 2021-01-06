run_dd_ml_hpc <- function(siga, sigk, dd_model, check_comrad_version = TRUE) {
  # Check function is called from Peregrine
  is_on_peregrine <- Sys.getenv("HOSTNAME") == "peregrine.hpc.rug.nl"

  if (!is_on_peregrine) {
    stop("This function is meant to be run on the peregrine HPC only.")
  }
  # Check comrad version
  if (check_comrad_version) {
    fabrika::compare_comrad_versions()
  }
  # Load data
  phylos <- readRDS(
    glue::glue(path_to_fabrika_hpc(), "comrad_data/phylos/comrad_phylos_sigk_{sigk}_siga_{siga}.rds")
  )
  waiting_times_tbl <- phylos %>% purrr::map_dfr(waiting_times)
  # Draw initial parameter values
  init_params_ls <- draw_init_params_dd_ml(
    phylos = phylos,
    nb_sets = 1000,
    dd_model = dd_model
  )
  # Run ml for each initial parameter set
  ml <- purrr::map_dfr(
    init_params_ls,
    function(init_params) {
      cat("init params: \n")
      print(init_params)
      fit_dd_model(
        waiting_times_tbl = waiting_times_tbl,
        dd_model = dd_model,
        init_params = init_params,
        num_cycles = Inf
      )
    })
  # Save output
  saveRDS(
    ml,
    glue::glue(
      path_to_fabrika_hpc(),
      "comrad_data/ml_results/ml_{dd_model$name}_sigk_{sigk}_siga_{siga}.rds")
  )
}

