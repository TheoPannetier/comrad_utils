#' Install comrad on the Peregrine HPC
#'
#' Install or update [comrad](https://github.com/TheoPannetier/comrad) from
#' branch `brute_force` on the Peregrine HPC. The code on this branch is
#' compiled with flag `-march=native`, and so must be installed from the source
#' code. This function builds, upload and install the source code to Peregrine.
#'
#' @param rebuild logical. If `TRUE`, call `devtools::build()` first.
#' If `FALSE`, upload and install the source code corresponding to the current
#' version in `fabrika/libs`.
#'
#' @author Théo Pannetier
#' @export
#'
install_comrad_hpc <- function(rebuild = TRUE) {

  # Assert current installation brute force option matches the version requested
  if (!has_brute_force_opt()) {
    stop("install branch `brute_force` locally first")
  }

  version <- utils::packageVersion("comrad")

  if (rebuild) {
    devtools::build(
      pkg = "~/Github/comrad/",
      path = glue::glue(path_to_fabrika_local(), "libs")
    )
  }

  source <- glue::glue(path_to_fabrika_local(), "libs/comrad_{version}.tar.gz")

  # Connect to hpc
  session <- ssh::ssh_connect(
    "p282688@peregrine.hpc.rug.nl"
  )
  # Upload source
  ssh::scp_upload(
    session = session,
    files = source,
    to = glue::glue(path_to_fabrika_hpc(), "libs/")
  )

  command <- glue::glue(
    "sbatch /data/$USER/fabrika/bash/install_comrad.bash {version}"
  )

  # Submit job to install comrad
  ssh::ssh_exec_wait(
    session = session,
    command = command
  )

  ssh::ssh_disconnect(
    session = session
  )
}
