#' Check if a simulation file is present on my external hard rive
#'
#' @param job_ids eight-digit job ID given by Peregrine upon
#' submission.
#'
#' @author Théo Pannetier
#'
#' @name is_sim_on_hd
NULL

#' @rdname is_sim_on_hd
#' @export
is_sim_csv_on_hd <- function(job_ids) {
  ls <- list.files("F:/comrad_data/sims/")
  jobs_present <- ls %>%
    stringr::str_match(pattern = "^comrad_sim_([:digit:]{8}).csv$") %>%
    .[,2]
  return(job_ids %in% jobs_present)
}

#' @rdname is_sim_on_hd
#' @export
is_sim_log_on_hd <- function(job_ids) {
  ls <- list.files("F:/comrad_data/logs/")
  jobs_present <- ls %>%
    stringr::str_match(pattern = "^comrad_sim_([:digit:]{8}).log$") %>%
    .[,2]
  return(job_ids %in% jobs_present)
}
