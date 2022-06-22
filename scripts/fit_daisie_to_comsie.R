fit_daisie_to_comsie_hpc <- function(siga_ibm,
                                     gamma_ibm,
                                     replicate,
                                     daisie_version,
                                     ddmodel,
                                     path_to_dir = "/data/p282688/fabrika/comsie_data/daisie",
                                     job_id
) {
  # Read input
  filename_datalist <- paste0("daisie_input_siga_", siga_ibm, "_gamma_", gamma_ibm,"_", replicate, ".rds")
  datalist <- readRDS(paste0(path_to_dir, "/input/", filename_datalist))

  filename_init_params <- paste0("daisie_initpars_siga_", siga_ibm, "_gamma_", gamma_ibm, "_", replicate, ".rds")
  initparsopt <- readRDS(paste0(path_to_dir, "/input/", filename_init_params))[[daisie_version]]

  # Run DAISIE
  if (daisie_version = "CS") {
    daisie_output <- try(DAISIE::DAISIE_ML_CS(
      datalist = datalist,
      initparsopt = initparsopt,
      #idparsfix = 4,
      ddmodel = ddmodel,
      cond = 1,
      optimmethod = "subplex",
      methode = "odeint::runge_kutta_cash_karp54",
      CS_version = 0
    ))
  } else if (daisie_version = "IW") {
    daisie_output <- try(DAISIE::DAISIE_ML_IW(
      datalist = datalist,
      initparsopt = initparsopt,
      #idparsfix = 4,
      ddmodel = ddmodel,
      cond = 1,
      optimmethod = "subplex",
      methode = "odeint::runge_kutta_cash_karp54"
    ))
  } else {
    stop("daisie_version should be either CS or IW.")
  }

  # Prepare output
  output_df <- data.frame(
    # Input
    "job_id" = job_id,
    "competition_sd" = siga_ibm,
    "immigration_rate" = gamma_ibm,
    "replicate" = replicate,
    "init_lambda_c_0" = initparsopt[1],
    "init_mu_0" = initparsopt[2],
    "init_k" = initparsopt[3],
    "init_gamma_0" = initparsopt[4],
    "init_lambda_a_0" = initparsopt[5],
    "ddmodel" = ddmodel,
    "daisie_version" = daisie_version,
    # Output
    "loglik" = NA,
    "ml_lambda_c_0" = NA,
    "ml_mu_0" = NA,
    "ml_k" = NA,
    "ml_gamma_0" = NA,
    "ml_lambda_a_0" = NA,
    "df" = NA,
    "conv" = NA
  )

  if (is.data.frame(daisie_output)) {
    # That is, no error
    output_df$loglik <- daisie_output$loglik
    output_df$ml_lambda_c_0 <- daisie_output$lambda_c
    output_df$ml_mu_0 <- daisie_output$mu
    output_df$ml_k <- daisie_output$K
    output_df$ml_gamma_0 <- daisie_output$gamma
    output_df$ml_lambda_a_0 <- daisie_output$lambda_a
    output_df$df <- daisie_output$df
    output_df$conv <- daisie_output$conv
  }
  # So that an entry is still saved if error

  # Save output
  filename_output <- paste0(
    "daisie_ml_siga_", siga_ibm,
    "_gamma_", gamma_ibm,
    "_rep_", replicate,
    "_", daisie_version,
    "_ddmodel_", ddmodel,
    ".rds"
  )
  saveRDS(output_df, file = paste0(path_to_dir, "/output/", filename_output))
}
