#' Convert Peregrine time format to HMS
#' 
#' @param runtime a job duration in format `(DD-)HH:MM:SS`
#' @author Theo Pannetier
#' @export
runtime_to_hms <- function(runtime) {
  # Days
  days <- stringr::str_match(
    runtime, "^(\\d{1,2})\\-"
  )[, 2] %>% as.numeric()
  days <- ifelse(is.na(days), 0, days)
  # Hours
  hours <- stringr::str_match(
    runtime, "^[\\d{1,2}]?[\\-]?(\\d{2})\\:\\d{2}\\:\\d{2}$"
  )[, 2] %>% as.numeric()
  # Minutes
  minutes <- stringr::str_match(
    runtime, "^[\\d{1,2}]?[\\-]?\\d{2}\\:(\\d{2})\\:\\d{2}$"
  )[, 2] %>% as.numeric()
  # Seconds
  seconds <- stringr::str_match(
    runtime, "^[\\d{1,2}]?[\\-]?\\d{2}\\:\\d{2}\\:(\\d{2})$"
  )[, 2] %>% as.numeric()
  # HMS format
  hms <- hms::hms(
    days = days,
    hours = hours,
    minutes = minutes,
    seconds = seconds
  )
  return(hms)
}
