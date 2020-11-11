#' Summary of the last generation on the HPC
#'
#' Read the community data for a (possibly running) comrad simulation on
#' Peregrine, returns the generation number (t), species diversity (d), and
#' number of individuals (n) at the last generation.
#'
#' @param  job_ids eight-digit job ID given by Peregrine upon
#' submission.
#'
#' @author Theo Pannetier
#' @export
#'
summary_last_gen_hpc <- function(job_ids) {
  if (length(job_ids) > 400) {
    stop("Please request no more than 400 job IDs.")
  }
  path_to_sims <- glue::glue("/data/p282688/fabrika/comrad_data/sims/comrad_sim_{job_ids}.csv")

  # Connect to hpc
  session <- ssh::ssh_connect(
    "p282688@peregrine.hpc.rug.nl"
  )

  command <- glue::glue(
    "module load R;",
    "Rscript -e \"",
    "comrad_tbl <- comrad::read_comrad_tbl('{path_to_sims}', skip = 20);",
    "t_last <- max(dplyr::pull(comrad_tbl, t));",
    "comm_last <- dplyr::pull(dplyr::filter(comrad_tbl, t == t_last), species);",
    "d_last <- dplyr::n_distinct(comm_last);",
    "n_last <- length(comm_last);",
    "paste(t_last, d_last, n_last);",
    "\""
  )

  out <- ssh::ssh_exec_internal(
    session = session,
    command = command
  )

  # Disconnect
  ssh::ssh_disconnect(
    session = session
  )

  summary_tbl <- out$stdout %>%
    rawToChar() %>%
    stringr::str_match_all("(\\d+|\\de\\+\\d{2}) (\\d+) (\\d+)") %>%
    .[[1]] %>% .[, 2:4] %>%
    t()
  colnames(summary_tbl) <- c("t", "d", "n")

  summary_tbl <- summary_tbl %>%
    tibble::as_tibble() %>%
    dplyr::bind_cols("job_id" = job_ids, .)

  return(summary_tbl)
}


