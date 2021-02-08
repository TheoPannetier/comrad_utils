#' Plot maximum likelihood estimates of DD rates
#'
#' @param rates_tbl a data frame with cols `N`, `rate`, `dd_model` and `value`.
#' E.g. the output of `get_ml_rates()`.
#'
#' @export
plot_ml_rates <- function(rates_tbl) {

  rates_plot <- rates_tbl %>%
    dplyr::mutate("rate" = factor(rate, levels = c("speciation", "extinction"))) %>%
    ggplot2::ggplot(ggplot2::aes(x = N, y = value, colour = dd_model, linetype = rate)) +
    ggplot2::labs(
      x = "Number of species",
      y = "Rate"
      ) +
    ggplot2::theme_bw() +
    ggplot2::geom_line() +
    ggplot2::geom_point(aes(shape = rate), size = 0.5) +
    ggplot2::scale_colour_brewer(palette = "Dark2")

  return(rates_plot)
}
