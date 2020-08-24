#' Read logbook
#'
#' Load `logbook.csv` into R as a data frame
#'
#' @author Théo Pannetier
#' @export
read_logbook <- function() {
  logbook <- readr::read_csv(
    "comrad_data/logs/logbook.csv",
    col_types = list(
      "batch_id" = readr::col_character(),
      "job_id" = readr::col_character(),
      "time_subm" = readr::col_datetime(),
      "status" = readr::col_character(),
      "runtime" = readr::col_time(),
      "nb_gens" = readr::col_double(),
      "competition_sd" = readr::col_double(),
      "carrying_cap_sd" = readr::col_double(),
      "carrying_cap_opt" = readr::col_double(),
      "trait_opt" = readr::col_double(),
      "growth_rate" = readr::col_double(),
      "prob_mutation" = readr::col_double(),
      "mutation_sd" = readr::col_double(),
      "trait_dist_sp" = readr::col_double(),
      "seed" = readr::col_double()
    )
  )
  return(logbook)
}
