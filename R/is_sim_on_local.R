#' Check if a simulation file is present on the local PC
#'
#' @param job_ids eight-digit job ID given by Peregrine upon
#' submission.
#'
#' @author Théo Pannetier
#'
#' @name is_sim_on_local
NULL

#' @rdname is_sim_on_local
#' @export
is_sim_csv_on_local <- function(job_ids, pkg = "comrad") {
  ls <- list.files(glue::glue(path_to_fabrika_local(), "{pkg}_data/sims/"))
  jobs_present <- ls %>%
    stringr::str_match(pattern = glue::glue("^{pkg}_sim_([:digit:]{8}).csv$")) %>%
    .[,2]
  return(job_ids %in% jobs_present)
}

#' @rdname is_sim_on_local
#' @export
is_sim_log_on_local <- function(job_ids, pkg = "comrad") {
  ls <- list.files(glue::glue(path_to_fabrika_local(), "{pkg}_data/logs/"))
  jobs_present <- ls %>%
    stringr::str_match(pattern = glue::glue("^{pkg}_sim_([:digit:]{8}).log$")) %>%
    .[,2]
  return(job_ids %in% jobs_present)
}
