run_dd_ml_hpc_without_fossil <- function(siga, sigk, dd_model, i, job_id, verbose) {
  if (!fabrika::is_on_peregrine()) {
    stop("This function is only intended to be run on the Peregrine HPC.")
  }
  cat(
    glue::glue("siga = {siga} sigk = {sigk}\nFitting DD model {dd_model$name} on tree {i}\n\n")
  )
  # Load data
  phylos <- readRDS(
    glue::glue("/data/p282688/fabrika/comrad_data/phylos/comrad_phylos_sigk_{sigk}_siga_{siga}.rds")
  )
  phylo <- phylos[[i]]
  branching_times <- ape::branching.times(ape::drop.fossil(phylo))
  # Re-scale branching times from 0 to 100
  scaling_factor <- max(branching_times) / 100
  branching_times <- branching_times / scaling_factor
  # Draw initial parameter values
  init_params_ls <- comrad::draw_init_params_dd_ml(
    phylos = phylos,
    nb_sets = 500,
    dd_model = dd_model
  )
  # Run ml for each initial parameter set
  ml <- purrr::imap_dfr(
    init_params_ls,
    function(init_params, i) {
      cat("init params:", i , "/", length(init_params_ls), "\n")
      print(init_params)
      # Re-scale parameters
      init_params[1] <- init_params[1] * scaling_factor
      init_params[2] <- init_params[2] * scaling_factor

      comrad::fit_dd_model_without_fossil(
        branching_times =  branching_times,
        dd_model = dd_model,
        init_params = init_params,
        num_cycles = Inf,
        verbose = verbose
      )
    })
  ml <- dplyr::mutate(ml, "tree" = i, "job_id" = job_id)
  # Scale back
  ml <- dplyr::rename(ml, "ml_lambda_0" = ml_lambda, "ml_mu_0" = ml_mu)
  ml <- dplyr::mutate(
    ml,
    "ml_lambda_0" = ifelse(conv == -1, ml_lambda_0, ml_lambda_0 / scaling_factor),
    "ml_mu_0" = ifelse(conv == -1, ml_mu_0, ml_mu_0 / scaling_factor)
  )
  # Save output
  saveRDS(ml, glue::glue("/data/p282688/fabrika/comrad_data/ml_results/dd_ml_without_fossil_{job_id}.rds"))
}
