#' Copy comrad files to hard drive
#'
#' @param job_ids eight-digit job ID given by Peregrine upon submission.
#' @param overwrite logical, passed to [fs::file_copy()].
#' @author Theo Pannetier
#' @export
#'
copy_sim_csv_to_hd <- function (job_ids, overwrite = FALSE) {

  paths <- job_ids %>% path_to_sim_local()
  new_paths <- glue::glue(path_to_hd(), "comrad_data/sims/comrad_sim_{job_ids}.csv")

  fs::file_copy(
    path = paths,
    new_path = new_paths,
    overwrite = overwrite
  )
  return(0)
}

#' Copy comrad files to hard drive
#'
#' @param job_ids eight-digit job ID given by Peregrine upon submission.
#' @param overwrite logical, passed to [fs::file_copy()].
#' @author Theo Pannetier
#' @export
#'
copy_sim_log_to_hd <- function (job_ids, overwrite = FALSE) {

  paths <- job_ids %>% path_to_log_local()
  new_paths <- glue::glue(path_to_hd(), "comrad_data/logs/comrad_sim_{job_ids}.log")

  fs::file_copy(
    path = paths,
    new_path = new_paths,
    overwrite = overwrite
  )
  return(0)
}
