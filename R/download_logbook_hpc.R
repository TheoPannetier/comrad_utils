#' Download the logbook from Peregrine to local
#'
#' er, it's all in the title, really.
#'
#' @author Théo Pannetier
#' @export
#'
download_logbook_hpc <- function() {
  # Connect to hpc
  session <- ssh::ssh_connect(
    "p282688@peregrine.hpc.rug.nl"
  )
  # Get ssh to download file
  ssh::scp_download(
    session = session,
    files = "/data/$USER/fabrika/comrad_data/logs/logbook.csv",
    to = "~/Github/fabrika/comrad_data/logs/"
  )
  # Disconnect
  ssh::ssh_disconnect(
    session = session
  )
}
