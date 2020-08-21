#' Fetch and print simulation output file from Peregrine
#'
#' Given a job ID, prints the corresponding `.csv` file from Peregrine.
#'
#' @param job_id eight-digit job ID given by Peregrine upon
#' submission.
#'
#' @author Théo Pannetier
#' @export
cat_sim_output_hpc <- function(
  job_id
) {
  # Connect to hpc
  session <- ssh::ssh_connect(
    "p282688@peregrine.hpc.rug.nl"
  )

  command <- glue::glue(
    "cat /data/$USER/comrad/data/sims/comrad_sim_{job_id}.csv; echo \n" # space between multiple jobs"
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
