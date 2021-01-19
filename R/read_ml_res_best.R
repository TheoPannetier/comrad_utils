#' Read best maximum likelihood results
#'
#' Returns a table with best maximum likelihood results for each of the 6 DD
#' models corresponding to parameters `siga` and `sigk`.
#'
#' @param siga parameter `competition_sd` of `comrad`
#' @param sigk parameter `carrying_cap_sd` of `comrad`
#'
#' @export
read_ml_res_best <- function(siga, sigk) {
  ml_res_all <- read_ml_res_all(siga, sigk)
  ml_res_best <- ml_res_all %>%
    dplyr::group_by(dd_model) %>%
    dplyr::slice_min(aic) %>%
    dplyr::ungroup() %>%
    dplyr::arrange(aic) %>%
    dplyr::mutate(
      "delta_aic" = aic - min(aic),
      "aicw_num" = exp(-delta_aic / 2),
      "aicw_denom" = sum(aicw_num),
      "aicw" = round(aicw_num / aicw_denom, 2),
      "cumsum_aicw" = cumsum(aicw)
    )
  return(ml_res_best)
}
