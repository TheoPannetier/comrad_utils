#' Upload `run_dd_ml.bash` to Peregrine
#'
#' Shortcut to upload/update the script.
#'
#' @author Théo Pannetier
#'
#' @export

upload_bash_hpc <- function(path_to_script) {
  # Connect to hpc
  session <- ssh::ssh_connect(
    "p282688@peregrine.hpc.rug.nl"
  )
  # Get ssh to upload script
  ssh::scp_upload(
    session = session,
    files = path_to_script,
    to = "/data/$USER/fabrika/bash/"
  )
  ssh::ssh_disconnect(
    session = session
  )
}
