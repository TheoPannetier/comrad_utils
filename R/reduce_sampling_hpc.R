#' Reduce the sampling of a simulated community
#'
#' Reads the `.csv` file corresponding to `job_id`, and samples a fraction of
#' individuals every generation up to the new sampling fraction. It is assumed
#' the previous sampling fraction was 0.5
#'
#' @param job_id same thing as usual
#' @param new_sampling_frac the new level of sampling
#'
#' @export
reduce_sampling_hpc <- function(job_id, new_sampling_frac = 0.1) {
  library(tidyverse)
  sim_file <- glue::glue("/data/p282688/fabrika/comrad_data/sims/comrad_sim_{job_id}.csv")

  metadata <- readr::read_csv(
    sim_file,
    n_max = 19,
    skip_empty_rows = FALSE,
    col_types = list(readr::col_character())
  )

  comrad_tbl <- comrad::read_comrad_tbl(sim_file, skip = 20)

  #t_seq <- unique(comrad_tbl$t)
  #t_seq <- t_seq[t_seq %% sampling_freq) == 0]

  comrad_tbl <- comrad_tbl %>%
    # dplyr::filter(t %in% t_seq) %>%
    group_by(t) %>%
    slice_sample(
      prop = new_sampling_frac / 0.1
    )
  cat("Overwriting", sim_file, "\n")
  metadata %>% readr::write_csv(sim_file, na = "")
  cat("Metadata OK\n")
  comrad_tbl %>% readr::write_csv(sim_file, append = TRUE, col_names = TRUE)
  cat("Data OK\n")
  return(0)
}
