#' Update the logbook on Google Drive
#'
#' @author Théo Pannetier
#' @export
update_logbook_drive <- function() {

  googledrive::drive_update(
    file = "comrad_data/logs/logbook.csv",
    media = paste0(path_to_fabrika_local(), "comrad_data/logs/logbook.csv"),
  )

}
