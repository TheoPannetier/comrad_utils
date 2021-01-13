run_dd_ml_hpc <- function(siga, sigk, dd_model) {
  # Load data
  phylos <- readRDS(
    glue::glue("/data/p282688/fabrika/comrad_data/phylos/comrad_phylos_sigk_{sigk}_siga_{siga}.rds")
  )
  waiting_times_tbl <- purrr::map_dfr(phylos, comrad::waiting_times)
  # Draw initial parameter values
  init_params_ls <- comrad::draw_init_params_dd_ml(
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
      comrad::fit_dd_model(
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
      "/data/p282688/fabrika/comrad_data/ml_results/ml_{dd_model$name}_sigk_{sigk}_siga_{siga}.rds")
  )
}

