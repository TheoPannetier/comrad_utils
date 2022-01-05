rm_logbook_entries <- function(
  job_ids,
  which_one = "sims",
  pkg = "comrad"
) {
  session <- ssh::ssh_connect(
    "p282688@peregrine.hpc.rug.nl"
  )

  if (which_one == "sims") {
    if (pkg == "comrad") {
      rel_path_to_logbook <- "comrad_data/logs/logbook.csv"
    } else if (pkg == "comsie") {
      rel_path_to_logbook <- "comsie_data/logs/logbook_comsie.csv"
    } else {
      stop("pkg must be either comrad or comsie.")
    }
  }  else if (which_one == "dd_ml_without_fossil") {
    rel_path_to_logbook <- "comrad_data/logs/logbook_dd_ml_without_fossil.csv"
  } else if (which_one == "dd_ml_with_fossil") {
    rel_path_to_logbook <- "comrad_data/logs/logbook_dd_ml_with_fossil.csv"
  } else if (which_one == "dd_ml_with_fossil2") {
    rel_path_to_logbook <- "comrad_data/logs/logbook_dd_ml_with_fossil2.csv"
  } else {
    stop("which_one should only be \"sims\", \"dd_ml_with_fossil\" or \"dd_ml_without_fossil\"")
  }

  download_logbook_hpc(which_one = which_one, pkg = pkg)
  logbook <- read_logbook(which_one = which_one, pkg = pkg)

  logbook <- logbook %>%
    dplyr::filter(!job_id %in% job_ids)

  readr::write_csv(
    logbook,
    file = paste0(path_to_fabrika_local(), rel_path_to_logbook)
  )
  ssh::scp_upload(
    session = session,
    files = paste0(path_to_fabrika_local(), rel_path_to_logbook),
    to = paste0(path_to_fabrika_hpc(), "comrad_data/logs/")
  )
  ssh::ssh_disconnect(session = session)
}
