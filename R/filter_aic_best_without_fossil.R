#' Filter best ML results and compute AIC-based selection scores for `dd_ML` results without fossil
#'
#' Returns a table with best maximum likelihood results for each of the 10 DD
#' models, and computes the delta AIC, AIC weights, and the latter's cumulative sum.
#'
#' @param mle_tbl a data frame containing maximum likelihood estimates for each of
#' the DD models (at least one row for each model), with at least cols `dd_model`,
#' `tree` and `aic`. E.g. the output of [read_mle_tbl_without_fossil()].
#'
#' @export
#'
filter_aic_best_without_fossil <- function(ml_tbl) {
  ml_tbl <- ml_tbl %>% group_by(tree, dd_model) %>%
    slice_min(aic) %>%
    dplyr::ungroup(dd_model) %>%
    dplyr::arrange(tree, aic) %>%
    dplyr::mutate(
      "delta_aic" = aic - min(aic),
      "aicw_num" = exp(-delta_aic / 2),
      "aicw_denom" = sum(aicw_num),
      "aicw" = round(aicw_num / aicw_denom, 5),
      "cumsum_aicw" = cumsum(aicw)
    )
  return(ml_tbl)
}
