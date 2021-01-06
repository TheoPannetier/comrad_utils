#' Upload `run_dd_ml.bash` to Peregrine
#'
#' Shortcut to upload/update the script.
#'
#' @author Théo Pannetier
#'
#' @export

upload_dd_ml_bash_hpc <- function() {
  # Connect to hpc
  session <- ssh::ssh_connect(
    "p282688@peregrine.hpc.rug.nl"
  )
  # Get ssh to upload script
  ssh::scp_upload(
    session = session,
    files = paste0(path_to_fabrika_local(), "bash/run_dd_ml.bash"),
    to = "/data/$USER/fabrika/bash/"
  )
  ssh::ssh_disconnect(
    session = session
  )
}
