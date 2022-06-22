#' Install `DAISIE` on the Peregrine HPC
#'
#' @param rebuild logical. If `TRUE`, call `devtools::build()` first.
#' If `FALSE`, upload and install the source code corresponding to the current
#' version in `fabrika/libs`.
#'
#' @author Théo Pannetier
#' @export
#'
install_DAISIE_hpc <- function(rebuild = TRUE) {

  version <- utils::packageVersion("DAISIE")

  if (rebuild) {
    devtools::build(
      pkg = "~/Github/DAISIE/",
      path = glue::glue(path_to_fabrika_local(), "libs")
    )
  }

  source <- glue::glue(path_to_fabrika_local(), "libs/DAISIE_{version}.tar.gz")

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
    "sbatch /data/$USER/fabrika/bash/install_DAISIE.bash {version}"
  )

  # Submit job to install DAISIE
  ssh::ssh_exec_wait(
    session = session,
    command = command
  )

  ssh::ssh_disconnect(
    session = session
  )
}
