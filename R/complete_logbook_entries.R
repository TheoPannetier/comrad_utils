#' Complete logbook entries after job completion
#'
#' `status` and `runtime` entries can be written only after a job has completed
#' (or failed). This function download the logbook from Peregrine, writes the
#' entries for `job_ids`, and uploads back to Peregrine. EDIT 1.7.0. also
#' updates the logbook with the size of the `sim` `.csv` file, and summary
#' information about the state of the community at the last step.
#'
#' @param job_ids eight-digit job IDs given by Peregrine upon
#' submission.
#' @param vars character vector, name of variables to update. Can be `status`,
#' `runtime`, `csv_size`, and/or `last_gen` (defaults to all).
#'
#' @author Théo Pannetier
#' @export
#'
complete_logbook_entries <- function(job_ids,
                                     vars = c(
                                       "status",
                                       "runtime",
                                       "csv_size",
                                       "last_gen"
                                     )
) {
  if (any(!vars %in% c(
    "status", "runtime", "csv_size", "last_gen"
  ))) {
    stop("Input \"vars\" is incorrect.")
  }

  session <- ssh::ssh_connect(
    "p282688@peregrine.hpc.rug.nl"
  )

  cat("Downloading logbook from Peregrine\n")
  fabrika::download_logbook_hpc()
  logbook <- read_logbook()

  to_update <- logbook$job_id %in% job_ids

  if ("status" %in% vars) {
    cat("Updating `status` entries\n")
    status <- fabrika::job_status(job_id = job_ids)
    logbook$status[to_update] <- status

    cat("Saving updated logbook and uploading back to Peregrine\n")
    readr::write_csv(
      logbook,
      file = paste0(path_to_fabrika_local(), "comrad_data/logs/logbook.csv")
    )
    ssh::scp_upload(
      session = session,
      files = paste0(path_to_fabrika_local(), "comrad_data/logs/logbook.csv"),
      to = paste0(path_to_fabrika_hpc(), "comrad_data/logs/")
    )
  }
  if ("runtime" %in% vars) {
    cat("Updating `runtime` entries\n")
    runtime <- fabrika::job_runtime(job_id = job_ids)
    logbook$runtime[to_update] <- runtime

    cat("Saving updated logbook and uploading back to Peregrine\n")
    readr::write_csv(
      logbook,
      file = paste0(path_to_fabrika_local(), "comrad_data/logs/logbook.csv")
    )
    ssh::scp_upload(
      session = session,
      files = paste0(path_to_fabrika_local(), "comrad_data/logs/logbook.csv"),
      to = paste0(path_to_fabrika_hpc(), "comrad_data/logs/")
    )
  }
  if ("csv_size" %in% vars) {
    cat("Updating `csv_size` entries\n")
    command <- glue::glue(
      "du ", path_to_fabrika_hpc(), "comrad_data/sims/comrad_sim_{job_ids}.csv"
    )
    out <- ssh::ssh_exec_internal(
      session = session,
      command = command
    )
    csv_size <- out$stdout %>%
      rawToChar() %>%
      stringr::str_match_all(
        "(\\d+)\t/data/p282688/fabrika/comrad_data/sims/comrad_sim_\\d{8}.csv\n"
      ) %>%
      .[[1]] %>% .[, 2] %>%
      fs::as_fs_bytes() %>%
      magrittr::multiply_by(1024) # du returns kilobytes, fs_bytes expects bytes

    logbook$csv_size[to_update] <- csv_size

    cat("Saving updated logbook and uploading back to Peregrine\n")
    readr::write_csv(
      logbook,
      file = paste0(path_to_fabrika_local(), "comrad_data/logs/logbook.csv")
    )
    ssh::scp_upload(
      session = session,
      files = paste0(path_to_fabrika_local(), "comrad_data/logs/logbook.csv"),
      to = paste0(path_to_fabrika_hpc(), "comrad_data/logs/")
    )
  }
  if ("last_gen" %in% vars) {
    cat("Updating `last_gen` entries\n")
    # summary_last_gen can only deal with 400 jobs at a time
    job_seq <- split(job_ids, f = seq_along(job_ids) %/% 300)
    summary_last_gen <- purrr::map_dfr(job_seq, summary_last_gen_hpc)
    logbook$t_last_gen[to_update] <- summary_last_gen$t
    logbook$d_last_gen[to_update] <- summary_last_gen$d
    logbook$n_last_gen[to_update] <- summary_last_gen$n

    cat("Saving updated logbook and uploading back to Peregrine\n")
    readr::write_csv(
      logbook,
      file = paste0(path_to_fabrika_local(), "comrad_data/logs/logbook.csv")
    )
    ssh::scp_upload(
      session = session,
      files = paste0(path_to_fabrika_local(), "comrad_data/logs/logbook.csv"),
      to = paste0(path_to_fabrika_hpc(), "comrad_data/logs/")
    )
  }
  ssh::ssh_disconnect(session = session)
}
