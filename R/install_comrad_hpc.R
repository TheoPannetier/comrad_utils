#' Install comrad on the Peregrine HPC
#'
#' Install or update the [comrad](https://github.com/TheoPannetier/comrad)
#' package (from the `master` branch) to Peregrine.
#'
#' @param ref see [remotes::install_github()]
#'
#' @author Théo Pannetier
#' @export
#'
install_comrad_hpc <- function(ref = "master") {
  # Connect to hpc
  session <- ssh::ssh_connect(
    "p282688@peregrine.hpc.rug.nl"
  )

  command <- paste(
    "sbatch /data/$USER/fabrika/bash/install_comrad.bash",
    ref
  )

  # Submit job to install comrad
  ssh::ssh_exec_wait(
    session = session,
    command = command
  )

  ssh::ssh_disconnect(
    session = session
  )
}
