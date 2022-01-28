count_lines <- function (path_to_file) {
  output <- system(glue::glue("wc -l {path_to_file}"), intern = TRUE)
  nb_lines <- as.integer(stringr::str_match(output, "[:digit:]+")[1,1])
  return(nb_lines)
}
