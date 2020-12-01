#' Path to a simulation log file on local computer
#'
#' Returns the (local) absolute path to the .log file corresponding to `job_id`
#'
#' @param job_id eight-digit job ID given by Peregrine upon submission.
#' @author Theo Pannetier
#' @export
#'
path_to_log_local <- function(job_id) {
  glue::glue(path_to_fabrika_local(), "comrad_data/logs/comrad_sim_{job_id}.log")
}

#' Path to a simulation log file on Peregrine
#'
#' Returns the absolute path to the .log file corresponding to `job_id` on Peregrine
#'
#' @param job_id eight-digit job ID given by Peregrine upon submission.
#' @author Theo Pannetier
#' @export
#'
path_to_log_hpc <- function(job_id) {
  glue::glue(path_to_fabrika_hpc(), "comrad_data/logs/comrad_sim_{job_id}.log")
}


