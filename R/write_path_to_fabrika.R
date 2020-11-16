#' Overwrite `path_to_fabrika_local`
#'
#' Calling this function will overwrite the absolute path to the `fabrika`
#' folder written in [path_to_fabrika_local()], then re-install the package.
#' Working dir must be set to the fabrika folder before calling this.
#'
#' @author Theo Pannetier
#' @export
#'
#'
write_path_to_fabrika_local <- function() {

  if (!stringr::str_sub(getwd(), start = -7L, end = -1L) == "fabrika") {
    stop("Working dir is not set to fabrika. Try again from within fabrika.Rproj")
  }

  path_to_fabrika <- here::here()

  rscript_path <- fs::path(path_to_fabrika, "R/path_to_fabrika.R")

  if (!fs::file_exists(rscript_path)) {
    stop("Could not find path_to_fabrika.R; are you working from within fabrika.Rproj?")
  } else {
    rscript <- readr::read_file(rscript_path)
  }

  current_line <- "path_local <- \"[:graph:]*\"\r\n"
  new_line <- paste0("path_local <- \"", path_to_fabrika, "/\"\r\n")

  rscript <- rscript %>% stringr::str_replace(
    pattern = current_line,
    replacement = new_line
  )

  cat("Overwriting path_to_fabrika.R\n")
  readr::write_file(rscript, rscript_path)

  cat("Path overwritten. Re-installing fabrika.\n")
  devtools::install(path_to_fabrika)
}
