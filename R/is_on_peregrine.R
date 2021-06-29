#' Is code being run on peregrine?
#'
#' @export
is_on_peregrine <- function() {
  grepl(
    pattern = "pg-node",
    Sys.getenv("HOSTNAME")
  ) ||
    grepl(
      pattern = "peregrine.hpc",
      Sys.getenv("HOSTNAME")
    )
}
