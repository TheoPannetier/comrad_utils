#' Get job IDs from a batch ID
#'
#' Reads the logbook and returns the job IDs associated with the input batch ID.
#'
#' @param batch_id character or numeric, the ID assigned to a batch of jobs by
#' [run_comrad_sim_hpc()].
#' @param which_one character, which logbook? can be `"sims"` or `"dd_ml_without_fossil"`
#' @author Théo Pannetier
#' @export

batch_id_to_job_ids <- function(batch_id, which_one = "sims") {

  logbook <- fabrika::read_logbook(which_one = which_one)
  entries <- logbook$batch_id == as.character(batch_id)
  job_ids <- logbook$job_id[entries]

  return(job_ids)
}
