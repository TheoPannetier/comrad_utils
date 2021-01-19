#' Plot maximum likelihood estimates of DD rates
#'
#' @param siga parameter `competition_sd` of `comrad`
#' @param sigk parameter `carrying_cap_sd` of `comrad`
#'
#' @export
plot_ml_rates <- function(siga, sigk) {

  rates_tbl <- get_ml_rates(siga = siga, sigk = sigk)

  title <- bquote(sigma[alpha] ~ "=" ~ .(siga) ~~~ sigma[K] ~ "=" ~ .(sigk))

  rates_plot <- rates_tbl %>%
    ggplot2::ggplot(ggplot2::aes(x = N, y = value, colour = dd_model, linetype = rate)) +
    ggplot2::labs(
      x = "Number of species",
      y = "Rate",
      title = title
      ) +
    ggplot2::theme_bw() +
    ggplot2::geom_line() +
    ggplot2::scale_colour_brewer(palette = "Dark2")

  return(rates_plot)
}
