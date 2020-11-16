#' Path to `fabrika` on a  local computer
#'
#' @details This path is hard encoded to my the path on personal computer but
#' can be overwritten with [write_path_to_fabrika_local()].
#'
#' @export
path_to_fabrika_local <- function() {
  path_local <- "~/Github/fabrika/"
  return(path_local)
}

#' Path to `fabrika` on the Peregrine HPC
#'
#' @export
path_to_fabrika_hpc <- function() {
  "/data/$USER/fabrika/"
}
