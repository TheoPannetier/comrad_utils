#' Check the queue on Peregrine
#'
#' This is pure laziness. Shortcut for `squeue -u $USER`.
#'
#' @author Théo Pannetier
#' @export
queue <- function() {
  session <- ssh::ssh_connect(
    "p282688@peregrine.hpc.rug.nl"
  )
  ssh::ssh_exec_wait(
    session = session,
    command = "squeue -u $USER"
  )
  ssh::ssh_disconnect(
    session = session
  )
}
