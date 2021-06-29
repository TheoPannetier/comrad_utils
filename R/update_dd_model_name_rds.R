#' Replace "x2" model namesto "p" names in .rds files
#'
#' @export
update_dd_model_name_rds <- function(job_id, with_fossil) {
  cat("Updating", job_id, "\n")
  fossil_or_not <- ifelse(with_fossil, "with_fossil", "without_fossil")
  path_to_fabrika <- ifelse(
    fabrika::is_on_peregrine(),
    fabrika::path_to_fabrika_hpc(),
    fabrika::path_to_fabrika_local()
  )
  which_one <- ifelse(with_fossil, "dd_ml_with_fossil2", "dd_ml_without_fossil")
  logbook <- fabrika::read_logbook(which_one)
  exptd_dd_model <- logbook$dd_model[logbook$job_id == job_id]

  update_model_name <- function(x) {
    dplyr::case_when(
      x == "xc2" ~ "pc",
      x == "xl2" ~ "pl",
      x == "lx2" ~ "lp",
      x == "xx2" ~ "pp",
      TRUE ~ x
    )
  }

  # Read corresponding file
  path_to_file <- glue::glue(path_to_fabrika, "comrad_data/ml_results/dd_ml_{fossil_or_not}_{job_id}.rds")
  ml <- readRDS(path_to_file)
  exptd_len <- nrow(ml)
  # Update DD model name
  ml <- ml %>% dplyr::mutate(
    "dd_model" = update_model_name(dd_model),
    "dd_model" = ifelse(is.na(dd_model), exptd_dd_model, dd_model)
  )
  # Quality check
  testthat::expect_true(all(ml$dd_model == exptd_dd_model))
  testthat::expect_equal(nrow(ml), exptd_len)
  saveRDS(ml, file = path_to_file)
}
