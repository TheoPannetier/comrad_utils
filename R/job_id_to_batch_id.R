#' Get batch ID from a job ID
#'
#' Reads the logbook and returns the batch ID associated with the input job ID.
#'
#' @param job_id numeric or character, eight-digit job ID given by Peregrine
#' upon submission.
#'
#' @details Try `job_id %>% job_id_to_batch_id() %>% batch_id_to_job_ids()` to
#' find all other jobs submitted along with `job_id`.
#'
#' @author Théo Pannetier
#' @export
job_id_to_batch_id <- function(job_id) {

    logbook <- fabrika::read_logbook()
    entry <- logbook$job_id == as.character(job_id)
    batch_id <- unique(logbook$batch_id[entry])

    return(batch_id)
}
