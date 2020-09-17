#' Get job status on Peregrine
#'
#' Extract job status from `jobinfo`
#'
#' @param  job_id eight-digit job ID given by Peregrine upon
#' submission.
#'
#' @author Théo Pannetier
#' @export
#'
job_status <- function(
  job_id
) {
  # Capture jobinfo
  info <- utils::capture.output(fabrika::job_info(job_id = job_id))
  # Extract status
  status <- stringr::str_match(
      info,
      "^State[:blank:]{15}\\:[:blank:]([:graph:]*)$"
    )[, 2]
  status <- status[!is.na(status)]
  return(status)
}
