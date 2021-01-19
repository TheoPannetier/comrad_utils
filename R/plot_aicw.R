#' Plot DD models AIC weights as a barplot
#'
#' @param siga parameter `competition_sd` of `comrad`
#' @param sigk parameter `carrying_cap_sd` of `comrad`
#'
#' @export
plot_aicw <- function(siga, sigk) {
  # Read ML results
  ml_res_tbl <- read_ml_res_best(siga = siga, sigk = sigk)

  title <- bquote(sigma[alpha] ~ "=" ~ .(siga) ~~~ sigma[K] ~ "=" ~ .(sigk))

  aicw_plot <- ml_res_tbl %>%
    ggplot2::ggplot(ggplot2::aes(y = aicw, x = 1, fill = dd_model)) +
    ggplot2::geom_col(position = "fill", show.legend = TRUE) +
    ggplot2::scale_fill_brewer(palette = "Dark2") +
    ggplot2::theme(
      axis.title.x = element_blank(),
      axis.ticks.x = element_blank(),
      axis.text.x = element_blank(),
      panel.background = element_blank()
    ) +
    labs(y = "AICw", title = title)

  return(aicw_plot)
}
