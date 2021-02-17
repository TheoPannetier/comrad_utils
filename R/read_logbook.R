#' Read logbook
#'
#' Load `logbook.csv` into R as a data frame
#'
#' @author Théo Pannetier
#' @export
read_logbook <- function() {
  logbook <- readr::read_csv(
    paste0(path_to_fabrika_local(), "comrad_data/logs/logbook.csv"),
    col_types = list(
      "batch_id" = readr::col_character(),
      "job_id" = readr::col_character(),
      "time_subm" = readr::col_datetime(),
      "status" = readr::col_character(),
      "runtime" = readr::col_character(),
      "nb_gens" = readr::col_double(),
      "competition_sd" = readr::col_double(),
      "carrying_cap_sd" = readr::col_double(),
      "carrying_cap_opt" = readr::col_double(),
      "trait_opt" = readr::col_double(),
      "growth_rate" = readr::col_double(),
      "prob_mutation" = readr::col_double(),
      "mutation_sd" = readr::col_double(),
      "trait_dist_sp" = readr::col_double(),
      "seed" = readr::col_double(),
      "comrad_version" = readr::col_character(),
      "sampling_on_event" = readr::col_logical(),
      "sampling_freq" = readr::col_double(),
      "sampling_frac" = readr::col_double(),
      "brute_force_opt" = readr::col_character(),
      "csv_size" = readr::col_character(),
      "t_last_gen" = readr::col_double(),
      "d_last_gen" = readr::col_double(),
      "n_last_gen" = readr::col_double()
    )
  ) %>%
    dplyr::mutate(
      "csv_size" = fs::as_fs_bytes(csv_size)
    )

  return(logbook)
}
