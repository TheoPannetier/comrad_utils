rm_sim_csv_hpc <- function(job_id, pkg = "comrad") {
  if (length(job_ids) > 1000) {
    stop("Can't rm more than a 1000 jobs at once, sorry.")
  }
  # Connect to hpc
  session <- ssh::ssh_connect(
    "p282688@peregrine.hpc.rug.nl"
  )
  # Files to delete
  files <- path_to_sim_hpc(job_ids, pkg = pkg)
  # Delete files
  ssh::ssh_exec_wait(
    session = session,
    command = glue::glue("rm {files}")
  )
  ssh::ssh_disconnect(
    session = session
  )
}

rm_sim_log_hpc <- function(job_id, pkg = "comrad") {
  if (length(job_ids) > 1000) {
    stop("Can't rm more than a 1000 jobs at once, sorry.")
  }
  # Connect to hpc
  session <- ssh::ssh_connect(
    "p282688@peregrine.hpc.rug.nl"
  )
  # Files to delete
  files <- path_to_log_hpc(job_ids, pkg = pkg)
  # Delete files
  ssh::ssh_exec_wait(
    session = session,
    command = glue::glue("rm {files}")
  )
  ssh::ssh_disconnect(
    session = session
  )
}
