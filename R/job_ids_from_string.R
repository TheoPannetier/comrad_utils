#' Extract job IDs from a string
#'
#' Returns 8-digits sequences from a string
#'
#' @param string a string, typically some console output from [queue()] or
#' [run_comrad_sim_hpc()].
#'
#' @author Théo Pannetier
#' @export
job_ids_from_string <- function(string) {
  job_ids <- stringr::str_match_all(
    string,
    "([:digit:]{8})"
  )[[1]][,2]
  return(job_ids)
}
