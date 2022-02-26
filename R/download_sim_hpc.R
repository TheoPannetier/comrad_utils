#' Download simulation files from Peregrine
#'
#' Given a vector of job IDs, will download the corresponding `.csv` or `.log`
#' files from Peregrine to the local instance of `fabrika`.
#'
#' @param job_ids 8-digit numeric or character vector. Peregrine job IDs
#' identifying the files to download.
#'
#' @author Théo Pannetier
#' @name download_sim_hpc
NULL

#' @export
#' @rdname download_sim_hpc
download_sim_csv_hpc <- function(job_ids, pkg = "comrad", to = "local") {

  if (!to %in% c("local", "hd")) {
    stop("Argument to must be either local or hd.")
  }

  if (!all(stringr::str_length(job_ids) == 8)) {
    stop("Invalid input: job_ids must have 8 digits.")
  }

  # Connect to hpc
  session <- ssh::ssh_connect(
    "p282688@peregrine.hpc.rug.nl"
  )
  # Files to download
  files <- glue::glue(path_to_fabrika_hpc(), "{pkg}_data/sims/{pkg}_sim_{job_ids}.csv")

  destination <- ifelse(
    to == "local",
    glue::glue(path_to_fabrika_local(), "{pkg}_data/sims/"),
    glue::glue(path_to_hd(), "{pkg}_data/sims/")
  )

  # Get ssh to download files
  purrr::walk(
    files,
    function(file) {
      ssh::scp_download(
        session = session,
        files = file,
        to = destination
      )
    }
  )
  ssh::ssh_disconnect(
    session = session
  )
}

#' @export
#' @rdname download_sim_hpc
download_sim_log_hpc <- function(job_ids, pkg = "comrad", to = "local") {

  if (!to %in% c("local", "hd")) {
    stop("Argument to must be either local or hd.")
  }

  if (!all(stringr::str_length(job_ids) == 8)) {
    stop("Invalid input: job_ids must have 8 digits.")
  }

  # Connect to hpc
  session <- ssh::ssh_connect(
    "p282688@peregrine.hpc.rug.nl"
  )
  # Files to download
  files <- glue::glue(path_to_fabrika_hpc(), "{pkg}_data/logs/{pkg}_sim_{job_ids}.log")

  destination <- ifelse(
    to == "local",
    glue::glue(path_to_fabrika_local(), "{pkg}_data/logs/"),
    glue::glue(path_to_hd(), "{pkg}_data/logs/")
  )

  # Get ssh to download files
  purrr::walk(
    files,
    function(file) {
      ssh::scp_download(
        session = session,
        files = file,
        to = destination
      )
    }
  )
  ssh::ssh_disconnect(
    session = session
  )
}

