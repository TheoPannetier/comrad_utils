#' Fetch and print simulation log from Peregrine
#'
#' Given a job ID, prints the corresponding `.log` file from Peregrine.
#'
#' @param job_id eight-digit job ID given by Peregrine upon
#' submission.
#'
#' @author Théo Pannetier
#'
#' @name is_sim_on_hpc
NULL

#' @export
#' @rdname cat_sim_hpc
is_sim_csv_on_hpc <- function(
  job_id, pkg = "comrad"
) {
  # Connect to hpc
  session <- ssh::ssh_connect(
    "p282688@peregrine.hpc.rug.nl"
  )

  commands <- glue::glue(
    "test -f ", path_to_fabrika_hpc(), "{pkg}_data/sims/{pkg}_sim_{job_id}.csv"
  )

  is_on_hpc <- commands %>% map_int(function(command){
    ssh::ssh_exec_wait(
      session = session,
      command = command
    )
  }) %>%
    as.logical() %>%
    magrittr::not()

  # Disconnect
  ssh::ssh_disconnect(
    session = session
  )
  return(is_on_hpc)
}

#' @export
#' @rdname cat_sim_hpc
is_sim_log_on_hpc <- function(
  job_id, pkg = "comrad"
) {
  # Connect to hpc
  session <- ssh::ssh_connect(
    "p282688@peregrine.hpc.rug.nl"
  )

  commands <- glue::glue(
    "test -f ", path_to_fabrika_hpc(), "{pkg}_data/logs/{pkg}_sim_{job_id}.log"
  )

  is_on_hpc <- commands %>% map_int(function(command){
    ssh::ssh_exec_wait(
      session = session,
      command = command
    )
  }) %>%
    as.logical() %>%
    magrittr::not()

  # Disconnect
  ssh::ssh_disconnect(
    session = session
  )
}
