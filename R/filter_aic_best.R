#' Filter best ML results and compute AIC-based selection scores
#'
#' Returns a table with best maximum likelihood results for each of the 10 DD
#' models, and computes the delta AIC, AIC weights, and the latter's cumulative sum.
#'
#' @param mle_tbl a data frame containing maximum likelihood estimates for each of
#' the DD models (at least one row for each model), with at least cols `dd_model`,
#' and `aic`. E.g. the output of [read_mle_tbl].
#'
#' @export
#'
filter_aic_best <- function(mle_tbl) {
  aic_tbl <- mle_tbl %>%
    dplyr::group_by(dd_model) %>%
    dplyr::slice_min(aic) %>%
    dplyr::ungroup() %>%
    dplyr::arrange(aic) %>%
    dplyr::mutate(
      "delta_aic" = aic - min(aic),
      "aicw_num" = exp(-delta_aic / 2),
      "aicw_denom" = sum(aicw_num),
      "aicw" = round(aicw_num / aicw_denom, 3),
      "cumsum_aicw" = cumsum(aicw)
    )
  return(aic_tbl)
}
