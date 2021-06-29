run_dd_ml_hpc_split <- function(siga, sigk, dd_model) {
  if (!is_on_peregrine()) {
    stop("This function is only intended to be run on the Peregrine HPC.")
  }
  cat(
    glue::glue("siga = {siga} sigk = {sigk}\nFitting DD model {dd_model$name}\n\n")
  )
  # Load data
  phylos <- readRDS(
    glue::glue("/data/p282688/fabrika/comrad_data/phylos/comrad_phylos_sigk_{sigk}_siga_{siga}.rds")
  )
  waiting_times_tbl_ls <- purrr::map(
    list(1:50, 51:100), function (i) {
      purrr::map_dfr(phylos[i], comrad::waiting_times, .id = "replicate")
    }
  )
  # Use same intial parameters as run without split
  ml <- readRDS(
    glue::glue("/data/p282688/fabrika/comrad_data/ml_results/ml_{dd_model$name}_sigk_{sigk}_siga_{siga}.rds")
  )
  ml <- dplyr::select(ml, dplyr::starts_with("init_"))

  # Split table into list
  init_params_ls <- purrr::pmap(ml, function(...) {
    params <- c(...)
    names(params) <- substring(names(params), 6) # remove init_ prefix
    return(params)
  })

  # Run ml for each initial parameter set
  ml_ls <- purrr::map(waiting_times_tbl_ls, function (waiting_times_tbl) {
    purrr::imap_dfr(
      init_params_ls,
      function(init_params, i) {
        cat("init params:", i , "/", length(init_params_ls), "\n")
        print(init_params)
        comrad::fit_dd_model_with_fossil(
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
