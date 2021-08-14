#' Read and combine `dd_ML` results
#'
#' Read all `.rds` files corresponding to `job_ids`, combine them and adds
#' AIC scores.
#'
#' @param job_ids 8-digit codes (chr or num) corresponding to the ID of a
#' `dd_ML` job, should be one of the entries in
#' `logbook_dd_ml_with_fossil.csv`.
#'
#' @export
read_ml_with_fossil <- function(job_ids) {
  path_to_fabrika <- ifelse(
    is_on_peregrine(),
    path_to_fabrika_hpc(),
    path_to_fabrika_local()
  )
  ml_tbl <- job_ids %>% purrr::map_dfr(function(job_id) {
    ml_job <- readRDS(glue::glue(
      path_to_fabrika, "comrad_data/ml_results/dd_ml_with_fossil_{job_id}.rds"
    ))
    if (any(is.na(ml_job$dd_model))) {
      ddmod <- unique(ml_job$dd_model)
      ddmod <- ddmod[!is.na(ddmod)]
      if (length(ddmod) > 1) {
        stop(glue::glue("There is more than one dd_model in job {job_id}!"))
      } else {
        ml_job$dd_model <- ddmod
      }
    }
    ml_job <- ml_job %>% dplyr::mutate(
      "job_id" = as.character(job_id)
    )
  }) %>%
    dplyr::mutate(
      # Catch failed ML results
      "ml_lambda_0" = ifelse(loglik == -1, NA, ml_lambda_0),
      "ml_mu_0" = ifelse(loglik == -1, NA, ml_mu_0),
      "ml_k" = ifelse(loglik == -1, NA, ml_k),
      "ml_alpha" = ifelse(loglik == -1, NA, ml_alpha),
      "loglik" = ifelse(loglik == -1, -Inf, loglik),
      # Compute AIC
      "nb_params" = ifelse(stringr::str_detect(dd_model, "c"), 3, 4),
      "aic" = 2 * nb_params - 2 * loglik
    )
  return(ml_tbl)
}
