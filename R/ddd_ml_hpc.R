ddd_ml_hpc <- function(siga, sigk, ddmodel) {
  is_on_peregrine <- grepl(pattern = "pg-node", Sys.getenv("HOSTNAME"))
  if (!is_on_peregrine) {
    stop("This function is only intended to be run on the Peregrine HPC.")
  }
  if (!ddmodel %in% c(1, 4)) {
    stop("arg \"ddmodel\" must be either 1 (LC) or 4 (XC).")
  }
  phylos <- readRDS(
    glue::glue("/data/p282688/fabrika/comrad_data/phylos/comrad_phylos_sigk_{sigk}_siga_{siga}.rds")
  )[1:10]
  phylos <- purrr::map(phylos, ape::drop.fossil)
  brts_ls <- purrr::map(phylos, ape::branching.times)

  dd_model <- ifelse(ddmodel == 1, "lc", "xc")
  init_ml <- readRDS(
    glue::glue("/data/p282688/fabrika/comrad_data/ml_results/ml_{dd_model}_sigk_{sigk}_siga_{siga}.rds")
  )
  init_ml <- dplyr::slice_max(init_ml, loglik)
  init_ml <- dplyr::select(init_ml, dplyr::starts_with("ml_"))
  initparsopt <- unlist(init_ml)

  ml_tbl <- purrr::map_dfr(brts_ls, function(brts) {
    out <- try(DDD::dd_ML(
      brts = brts,
      initparsopt = initparsopt,
      ddmodel = ddmodel,
      num_cycles = Inf
    ))
    if (!is.data.frame(out)) { # default results in likely case of an error
      out <- data.frame(lambda = NA, mu = NA, K = NA, loglik = NA, df = NA, conv = NA)
    }
    out_tbl <- bind_cols(init_ml, out)
    out_tbl <- dplyr::mutate(out_tbl, "ddmodel" = ddmodel)
  }, .id = "replicate")

  saveRDS(
    ml_tbl,
    file = glue::glue(
      path_to_fabrika_hpc(),
      "comrad_data/DDD_ml/DDD_ddmodel_{ddmodel}_sigk_{sigk}_siga_{siga}.rds"
    )
  )
}
