#' Get maximum likelihood estimates of DD rates
#'
#' @param siga parameter `competition_sd` of `comrad`
#' @param sigk parameter `carrying_cap_sd` of `comrad`
#'
#' @export
get_ml_rates <- function(siga, sigk) {

  # Read ML results
  ml_res_tbl <- read_ml_res_best(siga = siga, sigk = sigk)

  # Read ml params
  extract_ml_params <- function(ddmod) {
    params <- ml_res_tbl %>%
      dplyr::filter(dd_model == ddmod) %>%
      dplyr::select(ml_lambda_0, ml_mu_0, ml_k, ml_alpha) %>%
      unlist()
    names(params) <- c("lambda_0", "mu_0", "k", "alpha")
    return(params)
  }

  Nmax <- max(ml_res_tbl$ml_k) * 1.5

  rates_tbl <- tibble(
    "N" = 0:Nmax,
    "speciation_lc" = dd_model_lc()$speciation_func(params = extract_ml_params("lc"), N),
    "extinction_lc" = dd_model_lc()$extinction_func(params = extract_ml_params("lc"), N),
    "speciation_xc" = dd_model_xc()$speciation_func(params = extract_ml_params("xc"), N),
    "extinction_xc" = dd_model_xc()$extinction_func(params = extract_ml_params("xc"), N),
    "speciation_ll" = dd_model_ll()$speciation_func(params = extract_ml_params("ll"), N),
    "extinction_ll" = dd_model_ll()$extinction_func(params = extract_ml_params("ll"), N),
    "speciation_lx" = dd_model_lx()$speciation_func(params = extract_ml_params("lx"), N),
    "extinction_lx" = dd_model_lx()$extinction_func(params = extract_ml_params("lx"), N),
    "speciation_xl" = dd_model_xl()$speciation_func(params = extract_ml_params("xl"), N),
    "extinction_xl" = dd_model_xl()$extinction_func(params = extract_ml_params("xl"), N),
    "speciation_xx" = dd_model_xx()$speciation_func(params = extract_ml_params("xx"), N),
    "extinction_xx" = dd_model_xx()$extinction_func(params = extract_ml_params("xx"), N)
  )

  rates_tbl <- rates_tbl %>%
    tidyr::pivot_longer(
      cols = speciation_lc:extinction_xx,
      names_to = c("rate", "dd_model"),
      names_pattern = "(.*)_(.*)"
    ) %>%
    dplyr::mutate(
      "rate" = factor(rate, levels = c("speciation", "extinction"))
    )

  return(rates_tbl)
}
