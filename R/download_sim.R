#' Download simulation output from Peregrine
#'
#' Given a vector of job IDs, will download the corresponding `.csv` output or `.log`
#' files from Peregrine to the corresponding `comrad` directory.
#'
#' @param job_ids 8-digit numeric or character vector. The IDs of jobs to
#' get the output of.
#'
#' @author Théo Pannetier
#' @name download_sim
NULL

#' @export
#' @rdname download_sim
download_sim_output <- function(job_ids) {

  if (!all(stringr::str_length(job_ids) == 8)) {
    stop("Invalid input: job_ids must have 8 digits.")
  }

  # Connect to hpc
  session <- ssh::ssh_connect(
    "p282688@peregrine.hpc.rug.nl"
  )
  # Files to download
  files <- glue::glue(
    "/data/p282688/comrad/data/sims/comrad_sim_{job_ids}.csv"
  )
  # Get ssh to download files
  purrr::walk(
    files,
    function(file) {
      ssh::scp_download(
        session = session,
        files = file,
        to = "~/Github/comrad/data/sims/"
      )
    }
  )
  ssh::ssh_disconnect(
    session = session
  )
}

#' @export
#' @rdname download_sim
download_sim_log <- function(job_ids) {

  if (!all(stringr::str_length(job_ids) == 8)) {
    stop("Invalid input: job_ids must have 8 digits.")
  }

  # Connect to hpc
  session <- ssh::ssh_connect(
    "p282688@peregrine.hpc.rug.nl"
  )
  # Files to download
  files <- glue::glue(
    "/data/p282688/comrad/data/logs/comrad_sim_{job_ids}.log"
  )
  # Get ssh to download files
  purrr::walk(
    files,
    function(file) {
      ssh::scp_download(
        session = session,
        files = file,
        to = "~/Github/comrad/data/logs/"
      )
    }
  )
  ssh::ssh_disconnect(
    session = session
  )
}

