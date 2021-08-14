#' Fetch and print dd ML log from Peregrine
#'
#' Given a job ID, prints the corresponding `.log` file from Peregrine.
#'
#' @param job_id eight-digit job ID given by Peregrine upon
#' submission.
#'
#' @author Théo Pannetier
#' @export
cat_ml_log_hpc <- function(
  job_id,
  with_fossil
) {
  fossil_or_not <- ifelse(with_fossil, "with_fossil", "without_fossil")
  # Connect to hpc
  session <- ssh::ssh_connect(
    "p282688@peregrine.hpc.rug.nl"
  )

  command <- glue::glue(
    "cat ", path_to_fabrika_hpc(), "comrad_data/logs/dd_ml_{fossil_or_not}_{job_id}.log; echo \n" # space between multiple jobs
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
