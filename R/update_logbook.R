#' Update logbook entries after job completion
#'
#' `status` and `runtime` entries can be written only after a job has completed
#' (or failed). This function download the logbook from Peregrine, writes the
#' entries for `job_ids`, and uploads back to Peregrine.
#'
#' @param job_id eight-digit job ID given by Peregrine upon
#' submission.
#'
#' @author Théo Pannetier
#' @export
#'
update_logbook <- function(job_ids) {

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
  readr::write_csv(logbook, path = "comrad_data/logs/logbook.csv")
  session <- ssh::ssh_connect(
    "p282688@peregrine.hpc.rug.nl"
  )
  ssh::scp_upload(
    session = session,
    files = "comrad_data/logs/logbook.csv",
    to = "/data/$USER/fabrika/comrad_data/logs/"
  )
  ssh::ssh_disconnect(session = session)
}
