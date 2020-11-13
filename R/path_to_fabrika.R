#' Path to `fabrika` on my local computer
#'
#' @export
path_to_fabrika_local <- function() {
  "~/Github/fabrika/"
}

#' Path to `fabrika` on the Peregrine HPC
#'
#' @export
path_to_fabrika_hpc <- function() {
  "/data/$USER/fabrika/"
}

write_path_to_fabrika_local <- function(path_to_fabrika = here::here()) {

  if (!stringr::str_sub(path_to_fabrika, start = -7L, end = -1L) == "fabrika") {
    stop("\"path_to_fabrika\" does not point to fabrika. Try again from within fabrika.Rproj")
  }
  r_profile <- readr::read_file(paste0(path_to_fabrika, "/.Rprofile"))
}

path_to_fabrika <- here::here()
