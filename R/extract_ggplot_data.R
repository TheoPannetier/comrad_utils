#' Extract data from a ggplot
#'
#' Just so I don't end up looking it up for 2 hrs again
#'
#' @param gg the output of `ggplot2::ggplot()`
#' @return a tibble
#' @export
extract_ggplot_data <- function(gg) {
  return(tibble::as_tibble(ggplot2::ggplot_build(gg)$data[[1]]))
}
