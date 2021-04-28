#' Upload a fabrika R script to Peregrine
#'
#' Shortcut to upload/update the script.
#'
#' @author Théo Pannetier
#'
#' @export

upload_rscript_hpc <- function(path_to_script) {
  # Connect to hpc
  session <- ssh::ssh_connect(
    "p282688@peregrine.hpc.rug.nl"
  )
  # Get ssh to upload script
  ssh::scp_upload(
    session = session,
    files = path_to_script,
    to = "/data/$USER/fabrika/R/"
  )
  ssh::ssh_disconnect(
    session = session
  )
}
