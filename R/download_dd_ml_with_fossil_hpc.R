#' Download DD ML result files from Peregrine
#'
#' Given a vector of job IDs, will download the corresponding `.rds` or `.log`
#' DD ML with fossil results files from Peregrine to the local instance of
#' `fabrika`.
#'
#' @param job_ids 8-digit numeric or character vector. Peregrine job IDs
#' identifying the files to download.
#'
#' @author Théo Pannetier
#' @name download_data_with_fossil_hpc
NULL

#' @export
#' @rdname download_data_with_fossil_hpc
download_dd_ml_with_fossil_rds_hpc <- function(job_ids) {

  if (!all(stringr::str_length(job_ids) == 8)) {
    stop("Invalid input: job_ids must have 8 digits.")
  }
  # Connect to hpc
  session <- ssh::ssh_connect(
    "p282688@peregrine.hpc.rug.nl"
  )
  # Files to download
  files <- glue::glue(
    paste0(path_to_fabrika_hpc(), "comrad_data/ml_results/dd_ml_with_fossil_{job_ids}.rds")
  )

  # Get ssh to download files
  purrr::walk(
    files,
    function(file) {
      ssh::scp_download(
        session = session,
        files = file,
        to = paste0(path_to_fabrika_local(), "comrad_data/ml_results/")
      )
    }
  )
  ssh::ssh_disconnect(
    session = session
  )
}

#' @export
#' @rdname download_data_with_fossil_hpc
download_dd_ml_with_fossil_log_hpc <- function(job_ids) {

  if (!all(stringr::str_length(job_ids) == 8)) {
    stop("Invalid input: job_ids must have 8 digits.")
  }

  # Connect to hpc
  session <- ssh::ssh_connect(
    "p282688@peregrine.hpc.rug.nl"
  )
  # Files to download
  files <- glue::glue(
    paste0(path_to_fabrika_hpc(), "comrad_data/logs/dd_ml_with_fossil_{job_ids}.log")
  )
  # Get ssh to download files
  purrr::walk(
    files,
    function(file) {
      ssh::scp_download(
        session = session,
        files = file,
        to = paste0(path_to_fabrika_local(), "comrad_data/logs/")
      )
    }
  )
  ssh::ssh_disconnect(
    session = session
  )
}

