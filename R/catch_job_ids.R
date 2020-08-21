#' Submit jobs and catch their IDs
#'
#' Calls `fun`, catches job submission messages and extracts job IDs from them.
#'
#' @param fun a function submitting jobs to Peregrine. The function should
#' otherwise be absolutely silent, i.e. the only output sent to console should
#' be `Submitted batch job XXXXXXXX` from Peregrine.
#' @param ... arguments to be passed to `fun`
#'
#' @author Théo Pannetier
#' @export
catch_job_ids <- function(
  fun,
  ...
) {
  # Call function and capture output
  console_output <- utils::capture.output(fun(...))

  # Check captured output only contains job submission messages
  is_successful_submission <- stringr::str_detect(
    console_output,
    "^Submitted batch job [:digit:]{8}$"
  )
  if (!all(is_successful_submission)) {
    warning("Unexpected output messages:")
    console_output[!is_successful_submission]
  }

  # Extract job IDs
  job_ids <- as.numeric(
    stringr::str_extract(
      console_output[is_successful_submission],
      "[:digit:]{8}$"
    )
  )
  return(job_ids)
}
