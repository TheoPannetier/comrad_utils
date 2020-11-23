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
reduce_sampling_hpc <- function(job_id, new_sampling_frac = 0.5) {

  is_on_peregrine <- Sys.getenv("HOSTNAME") == "peregrine.hpc.rug.nl"
  if (!is_on_peregrine) {
    stop("reduce_sampling_hpc should only be called on the Peregrine HPC.")
  }

  sim_file <- job_id %>% fabrika::path_to_sim_hpc()

  metadata <- readr::read_csv(
    sim_file,
    n_max = 19,
    skip_empty_rows = FALSE,
    col_types = list(col_character())
  )

  comrad_tbl <- comrad::read_comrad_tbl(sim_file, skip = 20)

  #t_seq <- unique(comrad_tbl$t)
  #t_seq <- t_seq[t_seq %% sampling_freq) == 0]

  comrad_tbl <- comrad_tbl %>%
    # dplyr::filter(t %in% t_seq) %>%
    group_by(t) %>%
    slice_sample(
      prop = new_sampling_frac / 0.5
    )
  cat("Overwriting", sim_file, "\n")
  metadata %>% readr::write_csv(sim_file, na = "")
  cat("Metadata OK\n")
  comrad_tbl %>% readr::write_csv(sim_file, append = TRUE, col_names = TRUE)
  cat("Data OK\n")
  return(0)
}
