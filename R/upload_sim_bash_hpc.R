#' Upload `run_comrad_sim.bash` to Peregrine
#'
#' Shortcut to upload/update the script.
#'
#' @author Théo Pannetier
#'
#' @export

upload_sim_bash_hpc <- function() {
  # Connect to hpc
  session <- ssh::ssh_connect(
    "p282688@peregrine.hpc.rug.nl"
  )
  # Get ssh to upload script
  ssh::scp_upload(
    session = session,
    files = "~/Github/comrad_fabrika/scripts/bash/run_comrad_sim.bash",
    to = "/data/$USER/comrad_fabrika/scripts/bash/"
  )
  ssh::ssh_disconnect(
    session = session
  )
}
