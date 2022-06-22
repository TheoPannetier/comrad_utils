#' Shortcut for grid of sigma_alpha, gamma values
#'
#' @export
comsie_params_grid <- function() {
  params_tbl <- tidyr::expand_grid(
    "siga" = siga_vec_comsie()[c(1, 2, 4, 7, 9)],
    "gamma" = c(0, 1e-04, 5e-04, 1e-03, 1e-02#,
                #1e-01, 1
                )
  )
  return(params_tbl)
}
