#' Extract job IDs from console output
#'
#' Reads the output printed to console after submitting jobs on Peregrine
#' and extract all job IDs found in there.
#'
#' @param console_output character string, the message printed to console
#' after submitting jobs, e.g. via [run_comrad_sim_hpc] or directly via
#' `sbatch`. Should be of the form `"(Submitted batch job [:digit:]{8}\\n)+"`
#' @author Théo Pannetier
#' @export
extract_job_ids_console <- function(console_output) {
  job_ids <- stringr::str_match_all(
    console_output,
    "Submitted batch job ([:digit:]{8})"
    )[[1]][,2]
  return(job_ids)
}
