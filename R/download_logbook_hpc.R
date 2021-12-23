#' Download the logbook from Peregrine to local
#'
#' @param which_one character, which logbook? can be `"sims"` or `"dd_ml_without_fossil"`
#'
#' @author Théo Pannetier
#' @export
#'
download_logbook_hpc <- function(which_one = "sims", pkg = "comrad") {
  # Connect to hpc
  session <- ssh::ssh_connect(
    "p282688@peregrine.hpc.rug.nl"
  )
  if (which_one == "sims") {
    if (pkg == "comrad") {
      which_file <- "comrad_data/logs/logbook.csv"
    } else if (pkg == "comsie") {
      which_file <- "comsie_data/logs/logbook_comsie.csv"
    } else {
      stop("pkg must be either comrad or comsie.")
    }
  } else if (which_one == "dd_ml_without_fossil") {
    which_file <- "comrad_data/logs/logbook_dd_ml_without_fossil.csv"
  } else if (which_one == "dd_ml_with_fossil") {
    which_file <- "comrad_data/logs/logbook_dd_ml_with_fossil.csv"
  } else if (which_one == "dd_ml_with_fossil2") {
    which_file <- "comrad_data/logs/logbook_dd_ml_with_fossil2.csv"
  } else {
    stop("which_one should be either sims, dd_ml_with_fossil or dd_ml_without_fossil")
  }
  # Get ssh to download file
  ssh::scp_download(
    session = session,
    files = paste0(path_to_fabrika_hpc(), which_file),
    to = glue::glue(path_to_fabrika_local(), "{pkg}_data/logs/")
  )
  # Disconnect
  ssh::ssh_disconnect(
    session = session
  )
}
