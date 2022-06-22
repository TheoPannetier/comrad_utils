create_comsie_initparsopt_ddd <- function(siga_ibm, gamma_ibm, replicate, f) {
  cat(siga_ibm, gamma_ibm, replicate, "\n")

  filename_datalist <- paste0("ddd_input_siga_", siga_ibm, "_gamma_", gamma_ibm, "_", replicate, "_f_", f, ".rds")
  brts_list <- readRDS(paste0("../fabrika/comsie_data/ddd/input/", filename_datalist))
  initparsopt_ls <- purrr::map(brts_list, function(brts) {
    ntips <- length(brts)
    t_max <- max(brts)
    proto_lambda_0 <- log(ntips) / t_max
    initparsopt <- list(
      c("lambda_0" = proto_lambda_0 * 2, "mu_0" = proto_lambda_0 * 2 * 0.25, "k" = ntips * 1.5),
      c("lambda_0" = proto_lambda_0 * 2, "mu_0" = proto_lambda_0 * 2 * 0.5,  "k" = ntips * 1.5),
      c("lambda_0" = proto_lambda_0 * 1, "mu_0" = proto_lambda_0 * 1 * 0.25, "k" = ntips * 1.5),
      c("lambda_0" = proto_lambda_0 * 2, "mu_0" = proto_lambda_0 * 2 * 0.25, "k" = ntips * 0.8)
    )
    return(initparsopt)
  })
  filename_init_params <- paste0("ddd_initpars_siga_", siga_ibm, "_gamma_", gamma_ibm, "_", replicate, "_f_", f, ".rds")
  saveRDS(initparsopt_ls, paste0("../fabrika/comsie_data/ddd/input/", filename_init_params))
}
