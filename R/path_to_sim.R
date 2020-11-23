#' Path to a simulation data file on local computer
#'
#' Returns the (local) absolute path to the .csv file corresponding to `job_id`
#'
#' @param job_id eight-digit job ID given by Peregrine upon submission.
#' @author Theo Pannetier
#' @export
#'
path_to_sim_local <- function(job_id) {
  glue::glue(path_to_fabrika_local(), "comrad_data/sims/comrad_sim_{job_id}.csv")
}

#' Path to a simulation data file on Peregrine
#'
#' Returns the (local) absolute path to the .csv file corresponding to `job_id`
#'
#' @param job_id eight-digit job ID given by Peregrine upon submission.
#' @author Theo Pannetier
#' @export
#'
path_to_sim_hpc <- function(job_id) {
  glue::glue(path_to_fabrika_hpc(), "comrad_data/sims/comrad_sim_{job_id}.csv")
}


