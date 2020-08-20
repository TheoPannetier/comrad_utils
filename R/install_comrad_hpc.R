#' Install comrad on the Peregrine HPC
#'
#' Install or update the package from the `master` branch
#' ([https://github.com/TheoPannetier/comrad]) to Peregrine.
#'
#' @author Théo Pannetier
#' @export
#'
install_comrad_hpc <- function() {
  # Connect to hpc
  session <- ssh::ssh_connect(
    "p282688@peregrine.hpc.rug.nl"
  )
  # Submit job to install comrad
  ssh::ssh_exec_wait(
    session = session,
    command = "sbatch comrad/scripts/bash/install_comrad.bash"
  )

  ssh::ssh_disconnect(
    session = session
  )
}
