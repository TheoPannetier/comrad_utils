fit_daisie_to_comsie <- function(siga_ibm,
                                 gamma_ibm,
                                 replicate,
                                 f,
                                 daisie_version,
                                 ddmodel,
                                 params_i,
                                 path_to_dir = "/data/p282688/fabrika/comsie_data/daisie",
                                 job_id
) {
  # Read input
  filename_datalist <- paste0("daisie_input_siga_", siga_ibm, "_gamma_", gamma_ibm,"_", replicate, "_f_", f,".rds")
  datalist <- readRDS(paste0(path_to_dir, "/input/", filename_datalist))

  filename_init_params <- paste0("daisie_initpars_siga_", siga_ibm, "_gamma_", gamma_ibm, "_", replicate, "_f_", f, ".rds")
  params <- readRDS(paste0(path_to_dir, "/input/", filename_init_params))[[daisie_version]][[params_i]]
  initparsopt <- params#[-4]
  parsfix <- NULL#params[4]

  clade_sizes <- unlist(lapply(datalist[-1], function(clade) length(clade[[2]])))

  # Run DAISIE
  if (daisie_version == "CS") {
    daisie_output <- try(DAISIE::DAISIE_ML_CS(
      datalist = datalist,
      initparsopt = initparsopt,
      parsfix = parsfix,
      idparsopt = 1:5,#c(1:3, 5),
      idparsfix = NULL,#4,
      ddmodel = ddmodel,
      cond = 1,
      res =  2 * max(clade_sizes),
      optimmethod = "subplex",
      methode = "odeint::runge_kutta_cash_karp54",
      CS_version = 0
    ))
  } else if (daisie_version == "IW") {
    daisie_output <- try(DAISIE::DAISIE_ML_IW(
      datalist = datalist,
      initparsopt = initparsopt,
      parsfix = parsfix,
      idparsopt = 1:5,#c(1:3, 5),
      idparsfix = NULL,#4,
      ddmodel = ddmodel,
      cond = 1,
      res = 1.5 * sum(clade_sizes),
      optimmethod = ifelse(length(clade_sizes) > 1, "subplex", "simplex"),
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
    "f" = f,
    "params_i" = params_i,
    "init_lambda_c_0" = params[1],
    "init_mu_0" = params[2],
    "init_k" = params[3],
    "init_gamma_0" = params[4],
    "init_lambda_a_0" = params[5],
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
    "_f_", f,
    "_", daisie_version,
    "_ddmodel_", ddmodel,
    "_", params_i,
    ".rds"
  )
  saveRDS(output_df, file = paste0(path_to_dir, "/output/", filename_output))
}
