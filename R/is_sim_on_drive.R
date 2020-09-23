#' Check if a simulation file is present on Google Drive
#'
#' @param job_ids eight-digit job ID given by Peregrine upon
#' submission.
#'
#' @author Théo Pannetier
#'
#' @name is_sim_on_drive
NULL

#' @rdname is_sim_on_drive
#' @export
is_sim_csv_on_drive <- function(job_ids) {
  ls <- googledrive::drive_ls("comrad/comrad_data/sims/")
  jobs_present <- ls$name %>%
    stringr::str_match(pattern = "^comrad_sim_([:digit:]{8}).csv$") %>%
    .[,2]
  return(job_ids %in% jobs_present)
}

#' @rdname is_sim_on_drive
#' @export
is_sim_log_on_drive <- function(job_ids) {
  ls <- googledrive::drive_ls("comrad/comrad_data/logs/")
  jobs_present <- ls$name %>%
    stringr::str_match(pattern = "^comrad_sim_([:digit:]{8}).log$") %>%
    .[,2]
  return(job_ids %in% jobs_present)
}
