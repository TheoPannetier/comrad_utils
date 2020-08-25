#' Update the logbook on Google Drive
#'
#' @author Théo Pannetier
#' @export
update_logbook_drive <- function() {

  googledrive::drive_update(
    file = "comrad_data/logs/logbook.csv",
    media = "comrad_data/logs/logbook.csv",
    overwrite = TRUE
  )

}
