#' Shortcut for grid of sigma_alpha, sigma_k values
#'
#' @export
comrad_params_grid <- function() {
  tidyr::expand_grid(
    "sigk" = 1:5,
    "siga" = seq(0.1, 1, 0.1)
  )
}
