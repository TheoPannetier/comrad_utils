#' Path to a simulation data file on local computer
#'
#' Returns the (local) absolute path to the .csv file corresponding to `job_id`
#'
#' @param job_id eight-digit job ID given by Peregrine upon submission.
#' @author Theo Pannetier
#' @export
#'
path_to_sim_local <- function(job_id, pkg = "comrad") {
  glue::glue(path_to_fabrika_local(), "{pkg}_data/sims/{pkg}_sim_{job_id}.csv")
}

#' Path to a simulation data file on Peregrine
#'
#' Returns the absolute path to the .csv file corresponding to `job_id` on Peregrine
#'
#' @param job_id eight-digit job ID given by Peregrine upon submission.
#' @author Theo Pannetier
#' @export
#'
path_to_sim_hpc <- function(job_id, pkg = "comrad") {
  glue::glue(path_to_fabrika_hpc(), "{pkg}_data/sims/{pkg}_sim_{job_id}.csv")
}

#' Path to a simulation data file on external hard drive
#'
#' Returns the absolute path to the .csv file corresponding to `job_id` on an
#' external hard drive
#'
#' @param job_id eight-digit job ID given by Peregrine upon submission.
#' @author Theo Pannetier
#' @export
#'
path_to_sim_hd <- function(job_id, pkg = "comrad") {
  glue::glue(path_to_hd(), "{pkg}_data/sims/{pkg}_sim_{job_id}.csv")
}

