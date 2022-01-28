#' Plot DD models AIC weights as a barplot
#'
#' @param aic_tbl a data frame containing AIC weights for the 10 DD models
#' (*one* row per model) with at least cols `dd_model` and `aicw`.
#' E.g. the output of `read_mle_tbl(filter_aic_best())`.
#'
#' @export
plot_aicw <- function(aic_tbl) {

  aicw_plot <- aic_tbl %>%
    ggplot2::ggplot(ggplot2::aes(y = aicw, x = 1, fill = dd_model)) +
    ggplot2::geom_col(position = "fill", show.legend = TRUE) +
    ggplot2::scale_fill_brewer(palette = "Dark2") +
    ggplot2::theme(
      axis.title.x = element_blank(),
      axis.ticks.x = element_blank(),
      axis.text.x = element_blank(),
      panel.background = element_blank()
    ) +
    labs(y = "AICw")

  return(aicw_plot)
}
