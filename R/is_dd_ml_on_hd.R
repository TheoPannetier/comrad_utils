#' Check if a dd_ml result file is present on my external hard rive
#'
#' @param job_ids eight-digit job ID given by Peregrine upon
#' submission.
#'
#' @author Théo Pannetier
#'
#' @name is_dd_ml_on_hd
NULL

#' @rdname is_dd_ml_on_hd
#' @export
is_dd_ml_rds_on_hd <- function(job_ids, with_fossil = TRUE) {
  ls <- list.files(paste0(path_to_hd(), "comrad_data/ml_results/"))
  jobs_present <- ls %>%
    stringr::str_match(
      pattern = ifelse(
        with_fossil,
        "^dd_ml_with_fossil_([:digit:]{8}).rds$",
        "^dd_ml_without_fossil_([:digit:]{8}).rds$"
      )
    ) %>%
    .[,2]
  return(job_ids %in% jobs_present)
}

#' @rdname is_dd_ml_on_hd
#' @export
is_dd_ml_log_on_hd <- function(job_ids, with_fossil = TRUE) {
  ls <-  list.files(paste0(path_to_hd(), "comrad_data/logs/"))
  jobs_present <- ls %>%
    stringr::str_match(
      pattern = ifelse(
        with_fossil,
        "^dd_ml_with_fossil_([:digit:]{8}).log$",
        "^dd_ml_without_fossil_([:digit:]{8}).log$"
      )
    ) %>%
    .[,2]
  return(job_ids %in% jobs_present)
}
