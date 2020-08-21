#' Call `jobinfo` on Peregrine
#'
#' Prints the `jobinfo` for a given job ID.
#'
#' @param job_id eight-digit job ID given by Peregrine upon
#' submission.
#'
#' @author Théo Pannetier
#' @export

job_info <- function(
  job_id
) {
  # Connect to hpc
  session <- ssh::ssh_connect(
    "p282688@peregrine.hpc.rug.nl"
  )

  command <- glue::glue(
    "jobinfo {job_id}; echo \n" # space between multiple jobs
  )

  ssh::ssh_exec_wait(
    session = session,
    command = command
  )

  # Disconnect
  ssh::ssh_disconnect(
    session = session
  )
}
