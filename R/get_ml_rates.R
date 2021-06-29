#' Get maximum likelihood estimates of DD rates
#'
#' @param aic_tbl a data frame containing ML estimates for the 10 DD models
#' (*one* row per model) with at least cols `dd_model`, `ml_lambda_0`, `ml_mu_0`,
#' `ml_k` and `ml_alpha`. E.g. the output of `read_mle_tbl() %>% filter_aic_best()`
#' @param n_seq numeric vector, sequence of values of N for which the DD rates
#' are to be returned.
#'
#' @export
get_ml_rates <- function(aic_tbl, n_seq = 1:ceiling(max(aic_tbl$ml_k) * 1.5)) {

  # Read ml params
  extract_ml_params <- function(ddmod) {
    params <- aic_tbl %>%
      dplyr::filter(dd_model == ddmod) %>%
      dplyr::select(ml_lambda_0, ml_mu_0, ml_k, ml_alpha) %>%
      unlist()
    names(params) <- c("lambda_0", "mu_0", "k", "alpha")
    return(params)
  }

  rates_tbl <- tibble(
    "N" = n_seq,
    "speciation_lc" = dd_model_lc()$speciation_func(params = extract_ml_params("lc"), N),
    "extinction_lc" = dd_model_lc()$extinction_func(params = extract_ml_params("lc"), N),
    "speciation_xc" = dd_model_xc()$speciation_func(params = extract_ml_params("xc"), N),
    "extinction_xc" = dd_model_xc()$extinction_func(params = extract_ml_params("xc"), N),
    "speciation_pc" = dd_model_pc()$speciation_func(params = extract_ml_params("pc"), N),
    "extinction_pc" = dd_model_pc()$extinction_func(params = extract_ml_params("pc"), N),
    "speciation_ll" = dd_model_ll()$speciation_func(params = extract_ml_params("ll"), N),
    "extinction_ll" = dd_model_ll()$extinction_func(params = extract_ml_params("ll"), N),
    "speciation_lx" = dd_model_lx()$speciation_func(params = extract_ml_params("lx"), N),
    "extinction_lx" = dd_model_lx()$extinction_func(params = extract_ml_params("lx"), N),
    "speciation_lp" = dd_model_lp()$speciation_func(params = extract_ml_params("lp"), N),
    "extinction_lp" = dd_model_lp()$extinction_func(params = extract_ml_params("lp"), N),
    "speciation_xl" = dd_model_xl()$speciation_func(params = extract_ml_params("xl"), N),
    "extinction_xl" = dd_model_xl()$extinction_func(params = extract_ml_params("xl"), N),
    "speciation_xx" = dd_model_xx()$speciation_func(params = extract_ml_params("xx"), N),
    "extinction_xx" = dd_model_xx()$extinction_func(params = extract_ml_params("xx"), N),
    "speciation_pl" = dd_model_pl()$speciation_func(params = extract_ml_params("pl"), N),
    "extinction_pl" = dd_model_pl()$extinction_func(params = extract_ml_params("pl"), N),
    "speciation_pp" = dd_model_pp()$speciation_func(params = extract_ml_params("pp"), N),
    "extinction_pp" = dd_model_pp()$extinction_func(params = extract_ml_params("pp"), N)
  )

  rates_tbl <- rates_tbl %>%
    tidyr::pivot_longer(
      cols = speciation_lc:extinction_pp,
      names_to = c("rate", "dd_model"),
      names_pattern = "(.*)_(.*)"
    ) %>%
    dplyr::mutate(
      "rate" = factor(rate, levels = c("speciation", "extinction"))
    )

  return(rates_tbl)
}
