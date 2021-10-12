#' Shortcut for grid of sigma_alpha, sigma_k values
#'
#' @export
comrad_params_grid <- function() {
  tidyr::expand_grid(
    "sigk" = 1:5,
    "siga" = seq(0.1, 1, 0.1)
  )
}

#' @export
comrad_params_retained <- function() {
  comrad_params_grid() %>%
    dplyr::filter(
      (sigk == 1 & siga < 0.4)
      | (sigk == 2 & siga < 0.6)
      | (sigk == 3 & siga < 0.8)
      | (sigk == 4 & siga < 0.9)
      | (sigk == 5 & siga < 1)
    )
}

#' @export
are_params_retained <- function(siga, sigk) {
  (sigk == 1 & siga < 0.4) ||
    (sigk == 2 & siga < 0.6) ||
    (sigk == 3 & siga < 0.8) ||
    (sigk == 4 & siga < 0.9) ||
    (sigk == 5 & siga < 1)
}
