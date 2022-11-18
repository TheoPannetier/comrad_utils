fit_ddd_to_comsie <- function(siga_ibm,
                              gamma_ibm,
                              replicate,
                              f,
                              params_i,
                              path_to_dir = "/data/p282688/fabrika/comsie_data/ddd",
                              job_id = NULL
) {
  cat(
    "siga", siga_ibm, "gamma", gamma_ibm, "replicate", replicate, "f", f, "\n",
    "params_i", params_i, "\n",
    "job_id", job_id, "\n"
  )
  # Read input
  filename_datalist <- paste0("ddd_input_siga_", siga_ibm, "_gamma_", gamma_ibm, "_", replicate, "_f_", f, ".rds")
  brts_list <- readRDS(paste0(path_to_dir, "/input/", filename_datalist))

  filename_initparsopt <- paste0("ddd_initpars_siga_", siga_ibm, "_gamma_", gamma_ibm, "_", replicate, "_f_", f, ".rds")
  initparsopt_list <- readRDS(paste0(path_to_dir, "/input/", filename_initparsopt))

  if (length(brts_list) != length(initparsopt_list)) {
    stop("brts_list and initparsopt_list have a different length.")
  }

  df <- data.frame(
    # Input
    "job_id" = character(),
    "competition_sd" = numeric(),
    "immigration_rate" = numeric(),
    "replicate" = integer(),
    "f" = numeric(),
    "i" = integer(),
    "ntips" = integer(),
    "params_i" = integer(),
    "init_lambda_0" = numeric(),
    "init_mu_0" = numeric(),
    "init_k" = numeric(),
    # Output
    "loglik" = numeric(),
    "ml_lambda_0" = numeric(),
    "ml_mu_0" = numeric(),
    "ml_k" = numeric(),
    "conv" = integer()
  )

  for (i in seq_along(brts_list)) {
    cat("Tree", i, "/", length(brts_list), "\n")
    brts <- brts_list[[i]]
    ntips <- length(brts)
    cat("Ntips = ", ntips, "\n")
    initparsopt <- initparsopt_list[[i]][[params_i]]
    # Run DDD
    ddd_output <- try(DDD::dd_ML(
      brts = brts,
      initparsopt = initparsopt,
      ddmodel = 1,
      soc = 1,
      cond = 0,
      res = 8 * (ntips + 1),
      maxiter = 1000,
      methode = "analytical",
      optimmethod = "simplex",
      num_cycles = 3,
      verbose = FALSE
    ))

    # Prepare output
    output_df <- data.frame(
      # Input
      "job_id" = job_id,
      "competition_sd" = siga_ibm,
      "immigration_rate" = gamma_ibm,
      "replicate" = replicate,
      "f" = f,
      "i" = i,
      "ntips" = ntips,
      "params_i" = params_i,
      "init_lambda_0" = initparsopt[1],
      "init_mu_0" = initparsopt[2],
      "init_k" = initparsopt[3],
      # Output
      "loglik" = NA,
      "ml_lambda_0" = NA,
      "ml_mu_0" = NA,
      "ml_k" = NA,
      "conv" = NA
    )

    if (is.data.frame(ddd_output)) {
      # So that a default entry is still saved if error
      output_df$loglik <- ifelse(ddd_output$loglik == -1, -Inf, ddd_output$loglik)
      output_df$ml_lambda_0 <- ifelse(ddd_output$lambda == -1, NA, ddd_output$lambda)
      output_df$ml_mu_0 <- ifelse(ddd_output$mu == -1, NA, ddd_output$mu)
      output_df$ml_k <- ifelse(ddd_output$K == -1, NA, ddd_output$K)
      output_df$conv <- ifelse(ddd_output$conv == -1, 1, ddd_output$conv)
    }
    df[i, ] <- output_df
  }

  # Save output
  filename_output <- paste0(
    "ddd_ml_siga_", siga_ibm,
    "_gamma_", gamma_ibm,
    "_rep_", replicate,
    "_f_", f,
    "_params_", params_i,
    ".rds"
  )
  saveRDS(df, file = paste0(path_to_dir, "/output/", filename_output))
}
