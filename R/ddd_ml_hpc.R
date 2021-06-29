ddd_ml_hpc <- function(siga, sigk, ddmodel) {
  if (!is_on_peregrine()) {
    stop("This function is only intended to be run on the Peregrine HPC.")
  }
  if (!ddmodel %in% c(1, 4)) {
    stop("arg \"ddmodel\" must be either 1 (LC) or 4 (XC).")
  }
  cat(glue::glue("Running dd_ML for ddmodel = {ddmodel}, siga = {siga}, sigk = {sigk}\n\n"))

  filename <- glue::glue("/data/p282688/fabrika/comrad_data/phylos/comrad_phylos_sigk_{sigk}_siga_{siga}.rds")
  cat("Reading", filename, "\n\n")
  phylos <- readRDS(filename)[1:10]
  phylos <- purrr::map(phylos, ape::drop.fossil)
  brts_ls <- purrr::map(phylos, ape::branching.times)
  names(brts_ls) <- NULL # indexing

  dd_model <- ifelse(ddmodel == 1, "lc", "xc")
  init_ml <- readRDS(
    glue::glue("/data/p282688/fabrika/comrad_data/ml_results/ml_{dd_model}_sigk_{sigk}_siga_{siga}.rds")
  )
  init_ml <- dplyr::slice_max(init_ml, loglik)
  init_ml <- dplyr::select(init_ml, dplyr::starts_with("ml_"))
  initparsopt <- unlist(init_ml)

  ml_tbl <- purrr::imap_dfr(brts_ls, function(brts, i) {
    cat(glue::glue("Tree {i} / {length(brts_ls)} \n\n"))
    out <- try(DDD::dd_ML(
      brts = brts,
      initparsopt = initparsopt,
      ddmodel = ddmodel,
      num_cycles = Inf
    ))
    if (!is.data.frame(out)) { # default results in likely case of an error
      out <- data.frame(lambda = NA, mu = NA, K = NA, loglik = NA, df = NA, conv = NA)
    }
    out_tbl <- dplyr::bind_cols(init_ml, out)
    out_tbl <- dplyr::mutate(out_tbl, "ddmodel" = ddmodel)
  }, .id = "replicate")

  output_file <- glue::glue(
    "/data/p282688/fabrika/comrad_data/DDD_ml/DDD_ddmodel_{ddmodel}_sigk_{sigk}_siga_{siga}.rds"
  )
  cat(glue::glue("Saving at {output_file} \n\n"))
  saveRDS(
    ml_tbl,
    file = output_file
  )
}
