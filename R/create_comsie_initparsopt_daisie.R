create_comsie_initparsopt_daisie <- function(siga_ibm, gamma_ibm, replicate, f) {
  cat(siga_ibm, gamma_ibm, replicate, "\n")

  filename_datalist <- paste0("daisie_input_siga_", siga_ibm, "_gamma_", gamma_ibm, "_", replicate, "_f_", f, ".rds")
  datalist <- readRDS(paste0("../fabrika/comsie_data/daisie/input/", filename_datalist))
  clades_ls <- datalist[-1]
  ntips <- clades_ls %>% map_int(function(clade) {
    return(length(clade$branching_times))
  })
  n_p <- sum(ntips)
  island_age <- datalist[[1]]$island_age

  base_lambda_0_c <- log(n_p) / island_age
  base_mu0 <- base_lambda_0_c / 2
  base_k_cs <- max(n_p)
  base_k_iw <- n_p
  base_gamma <- gamma_ibm / 1000 * 1e04
  base_lambda_a_0 <- 1 / length(clades_ls)

  initparsopt_ls <- list(
    "CS" = list(
      c("lamda_0_c" = base_lambda_0_c,
        "mu_0" = base_mu0,
        "k" = base_k_cs,
        "gamma_0" = base_gamma,
        "lambda_0_a" = base_lambda_a_0)
    ),
    "IW" = list(
      c("lamda_0_c" = base_lambda_0_c,
        "mu_0" = base_mu0,
        "k" = base_k_iw,
        "gamma_0" = base_gamma,
        "lambda_0_a" = base_lambda_a_0)
    )
  )
  filename_init_params <- paste0("daisie_initpars_siga_", siga_ibm, "_gamma_", gamma_ibm, "_", replicate, "_f_", f, ".rds")
  saveRDS(initparsopt_ls, paste0("../fabrika/comsie_data/daisie/input/", filename_init_params))
}
