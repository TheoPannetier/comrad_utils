#' Read all maximum likelihood results
#'
#' Returns a table with all maximum likelihood results (for all of the 6 DD
#' models and all initial parameter sets) corresponding to parameters `siga`
#' and `sigk`
#'
#' @param siga parameter `competition_sd` of `comrad`
#' @param sigk parameter `carrying_cap_sd` of `comrad`
#'
#' @export
read_ml_res_all <- function(siga, sigk) {
  dd_models <- c("lc", "xc", "ll", "lx", "xl", "xx")
  ml_tbl <- purrr::map_dfr(dd_models, function(dd_model) {
    filename <- glue::glue(
      path_to_fabrika_local(),
      "comrad_data/ml_results/ml_{dd_model}_sigk_{sigk}_siga_{siga}.rds"
    )
    readRDS(filename) %>%
      dplyr::mutate(
        "dd_model" = dd_model,
        "nb_params" = ifelse(dd_model %in% c("ll", "lx", "xx", "xl"), 4, 3),
        "aic" = 2 * nb_params - 2 * loglik
      )
  })
  return(ml_tbl)
}
