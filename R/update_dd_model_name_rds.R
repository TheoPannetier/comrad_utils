update_model_name <- function(x) {
  dplyr::case_when(
    x == "xc2" ~ "pc",
    x == "xl2" ~ "pl",
    x == "lx2" ~ "lp",
    x == "xx2" ~ "pp",
    TRUE ~ x
  )
}

update_dd_model_name_rds <- function(with_fossil) {
  fossil_or_not <- ifelse(with_fossil, "with_fossil", "without_fossil")
  path_to_fabrika <- ifelse(
    fabrika::is_on_peregrine(),
    fabrika::path_to_fabrika_hpc(),
    fabrika::path_to_fabrika_local()
  )
  which_one <- ifelse(with_fossil, "dd_ml_with_fossil2", "dd_ml_without_fossil")

  logbook <- fabrika::read_logbook(which_one == which_one)
  job_ids <- dplyr::pull(
    dplyr::filter(logbook, dd_model %in% c("pc", "pl", "lp", "pp")),
    job_id
  )

  purrr::walk(job_ids, function(job_id) {
    exptd_dd_model <- logbook$dd_model[logbook$job_id == job_id]
    cat("Updating", job_id, "\n")
    # Read corresponding file
    path_to_file <- glue::glue(path_to_fabrika, "comrad_data/ml_results/dd_ml_{fossil_or_not}_{job_id}.rds")
    ml <- readRDS(path_to_file)
    exptd_len <- nrow(ml)
    # Update DD model name
    ml <- dplyr::mutate(
      ml,
      "dd_model" = update_model_name(dd_model),
      "dd_model" = ifelse(is.na(dd_model), exptd_dd_model, dd_model)
    )
    # Quality check
    testthat::expect_true(all(ml$dd_model == exptd_dd_model))
    testthat::expect_equal(nrow(ml), exptd_len)
    saveRDS(ml, file = path_to_file)
  })
}
