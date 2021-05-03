#' Read all maximum likelihood estimates
#'
#' Returns a table with all maximum likelihood results (for all of the 10 DD
#' models and all initial parameter sets) corresponding to parameters `siga`
#' and `sigk`
#'
#' @param siga parameter `competition_sd` of `comrad`
#' @param sigk parameter `carrying_cap_sd` of `comrad`
#' @param suffix character, a suffix at the end of the input files, e.g. `full`,
#' `freq` or `median`
#'
#' @export
read_mle_tbl <- function(siga, sigk, suffix = "full") {
  dd_models <- dd_model_names()
  ml_tbl <- purrr::map_dfr(dd_models, function(dd_model) {
    readRDS(
      glue::glue(path_to_fabrika_local(), "comrad_data/ml_results/ml_{dd_model}_sigk_{sigk}_siga_{siga}_{suffix}.rds")
    ) %>%
      dplyr::mutate(
        "dd_model" = dd_model,
        "nb_params" = ifelse(stringr::str_detect(dd_model, "c"), 3, 4),
        "aic" = 2 * nb_params - 2 * loglik
      )
  })
  return(ml_tbl)
}
