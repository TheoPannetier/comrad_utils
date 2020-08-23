#' Has a job completed?
#'
#' Is the job status `COMPLETED`?
#'
#' @param  job_id eight-digit job ID given by Peregrine upon
#' submission.
#'
#' @return logical
#'
#' @author Théo Pannetier
#' @export
has_job_completed <- function(
  job_id
) {
  fabrika::job_status(job_id = job_id) == "COMPLETED"
}
