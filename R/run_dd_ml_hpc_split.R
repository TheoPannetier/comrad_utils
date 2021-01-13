run_dd_ml_hpc_split <- function(siga, sigk, dd_model) {
  # Load data
  phylos <- readRDS(
    glue::glue("/data/p282688/fabrika/comrad_data/phylos/comrad_phylos_sigk_{sigk}_siga_{siga}.rds")
  )
  waiting_times_tbl_ls <- purrr::map(
    list(1:50, 51:100), function (i) {
      purrr::map_dfr(phylos[i], comrad::waiting_times, .id = "replicate")
    }
  )
  # Draw initial parameter values
  init_params_ls <- comrad::draw_init_params_dd_ml(
    phylos = phylos,
    nb_sets = 1000,
    dd_model = dd_model
  )
  # Run ml for each initial parameter set
  ml_ls <- purrr::map(waiting_times_tbl_ls, function (waiting_times_tbl) {
    purrr::map_dfr(
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
  })
  # Save output
  saveRDS(
    ml_ls,
    glue::glue(
      "/data/p282688/fabrika/comrad_data/ml_results/ml_{dd_model$name}_sigk_{sigk}_siga_{siga}_split.rds")
  )
}
