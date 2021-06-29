#' Read logbook
#'
#' Load `logbook.csv` into R as a data frame
#'
#' @param which_one character, which logbook? can be `"sims"` or `"dd_ml_without_fossil"`
#'
#' @author Théo Pannetier
#' @export
read_logbook <- function(which_one = "sims") {
  path_to_fabrika <- ifelse(
    is_on_peregrine(),
    path_to_fabrika_hpc(),
    path_to_fabrika_local()
  )
  if (which_one == "sims") {
    logbook <- readr::read_csv(
      paste0(path_to_fabrika, "comrad_data/logs/logbook.csv"),
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
        "switch_carr_cap_sd_after" = readr::col_double(),
        "switch_carr_cap_sd_to" = readr::col_double(),
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
  } else if (which_one == "dd_ml_without_fossil") {
    logbook <- readr::read_csv(
      paste0(path_to_fabrika, "comrad_data/logs/logbook_dd_ml_without_fossil.csv"),
      col_types = list(
        "batch_id" = readr::col_character(),
        "job_id" = readr::col_character(),
        "time_subm" = readr::col_datetime(),
        "status" = readr::col_character(),
        "runtime" = readr::col_character(),
        "competition_sd" = readr::col_double(),
        "carrying_cap_sd" = readr::col_double(),
        "dd_model" = readr::col_character(),
        "tree" = readr::col_integer(),
        "comrad_version" = readr::col_character(),
        "DDD_version" = readr::col_character()
      )
    )
  } else if (which_one == "dd_ml_with_fossil") {
    logbook <- readr::read_csv(
      paste0(path_to_fabrika, "comrad_data/logs/logbook_dd_ml_with_fossil.csv"),
      col_types = list(
        "batch_id" = readr::col_character(),
        "job_id" = readr::col_character(),
        "time_subm" = readr::col_datetime(),
        "status" = readr::col_character(),
        "runtime" = readr::col_character(),
        "competition_sd" = readr::col_double(),
        "carrying_cap_sd" = readr::col_double(),
        "dd_model" = readr::col_character(),
        "comrad_version" = readr::col_character()
      )
    )
  } else if (which_one == "dd_ml_with_fossil2") {
    logbook <- readr::read_csv(
      paste0(path_to_fabrika, "comrad_data/logs/logbook_dd_ml_with_fossil2.csv"),
      col_types = list(
        "job_id" = readr::col_character(),
        "time_subm" = readr::col_datetime(),
        "status" = readr::col_character(),
        "runtime" = readr::col_character(),
        "competition_sd" = readr::col_double(),
        "carrying_cap_sd" = readr::col_double(),
        "dd_model" = readr::col_character(),
        "tree" = readr::col_integer(),
        "comrad_version" = readr::col_character(),
        "DDD_version" = readr::col_character()
      )
    )
  } else {
    stop("which_one should be either sims, dd_ml_with_fossil, or dd_ml_without_fossil")
  }
  return(logbook)
}
