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
is_params_retained <- function() {
  # retained if k_eq >= 8
  comrad_params_grid() %>%
    dplyr::mutate("is_retained" = c(
      # 0.1    0.2    0.3   0.4    0.5    0.6    0.7    0.8    0.9    1
      TRUE,  TRUE,  TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE,# 1
      TRUE,  TRUE,  TRUE, TRUE,  TRUE,  FALSE, FALSE, FALSE, FALSE, FALSE,# 2
      TRUE,  TRUE,  TRUE, TRUE,  TRUE,  TRUE,  TRUE,  FALSE, FALSE, FALSE,# 3
      TRUE,  TRUE,  TRUE, TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  FALSE, FALSE,# 4
      TRUE,  TRUE,  TRUE, TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  FALSE # 5
    ))
}
