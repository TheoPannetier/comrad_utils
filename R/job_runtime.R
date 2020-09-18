#' Get job runtime on Peregrine
#'
#' Extract the time a job has been running on Peregrine from `jobinfo`
#'
#' @param  job_id eight-digit job ID given by Peregrine upon
#' submission.
#'
#' @author Théo Pannetier
#' @export
#'
job_runtime <- function(
  job_id
) {
  # Capture jobinfo
  info <- utils::capture.output(fabrika::job_info(job_id = job_id))

  # Extract runtime string
  runtime_str <- stats::na.omit(
    stringr::str_match(
      info, "^Used walltime[:blank:]{7}\\:[:blank:]{1,3}([\\d+]?[\\-]?\\d{2}\\:\\d{2}\\:\\d{2})$"
    )[, 2]
  )
  attr(runtime_str, "na.action") <- NULL
  return(runtime_str)
}
