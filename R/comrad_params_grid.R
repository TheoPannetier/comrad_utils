#' Shortcut for grid of sigma_alpha, sigma_k values
#'
#' @export
comrad_params_grid <- function(add_is_retained = FALSE) {
  params_tbl <- tidyr::expand_grid(
    "sigk" = 1:5,
    "siga" = seq(0.1, 1, 0.1)
  )
  if (add_is_retained) {
    params_tbl <- params_tbl %>% dplyr::mutate(
      "is_retained" = purrr::map2_lgl(siga, sigk, function (this_siga, this_sigk) {
        are_params_retained(this_siga, this_sigk)
      })
    )
  }
  return(params_tbl)
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
