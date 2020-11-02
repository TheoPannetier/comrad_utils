#' Complete logbook entries after job completion
#'
#' `status` and `runtime` entries can be written only after a job has completed
#' (or failed). This function download the logbook from Peregrine, writes the
#' entries for `job_ids`, and uploads back to Peregrine.
#'
#' @param job_ids eight-digit job IDs given by Peregrine upon
#' submission.
#'
#' @author Théo Pannetier
#' @export
#'
complete_logbook_entries <- function(job_ids) {

  cat("Downloading logbook from Peregrine\n")
  fabrika::download_logbook_hpc()
  logbook <- fabrika::read_logbook()

  cat("Updating `status` and `runtime` entries\n")
  status <- fabrika::job_status(job_id = job_ids)
  runtime <- fabrika::job_runtime(job_id = job_ids)
  to_update <- logbook$job_id %in% job_ids
  logbook$status[to_update] <- status
  logbook$runtime[to_update] <- runtime

  cat("Saving updated logbook and uploading back to Peregrine\n")
  readr::write_csv(
    logbook,
    file = paste0(path_to_fabrika_local(), "comrad_data/logs/logbook.csv")
  )
  session <- ssh::ssh_connect(
    "p282688@peregrine.hpc.rug.nl"
  )
  ssh::scp_upload(
    session = session,
    files = paste0(path_to_fabrika_local(), "comrad_data/logs/logbook.csv"),
    to = paste0(path_to_fabrika_hpc(), "comrad_data/logs/")
  )
  ssh::ssh_disconnect(session = session)
}
