#' Fetch and print simulation log from Peregrine
#'
#' Given a job ID, prints the corresponding `.log` file from Peregrine.
#'
#' @param job_id eight-digit job ID given by Peregrine upon
#' submission.
#'
#' @author Théo Pannetier
#'
#' @name cat_sim_hpc
NULL

#' @export
#' @rdname cat_sim_hpc
cat_sim_log_hpc <- function(
  job_id
) {
  # Connect to hpc
  session <- ssh::ssh_connect(
    "p282688@peregrine.hpc.rug.nl"
  )

  command <- glue::glue(
    "cat ", path_to_fabrika_hpc(), "comrad_data/logs/comrad_sim_{job_id}.log; echo \n" # space between multiple jobs
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

#' @export
#' @rdname cat_sim_hpc
cat_sim_csv_hpc <- function(
  job_id
) {
  # Connect to hpc
  session <- ssh::ssh_connect(
    "p282688@peregrine.hpc.rug.nl"
  )

  command <- glue::glue(
    "cat ", path_to_fabrika_hpc(), "comrad_data/sims/comrad_sim_{job_id}.csv; echo \n" # space between multiple jobs"
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
