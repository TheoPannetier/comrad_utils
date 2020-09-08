#' Compare installed comrad versions between HPC and local computer
#'
#' Calls [utils::packageVersion()] on the two instances and returns an error
#' if the two are different
#'
#' @author Théo Pannetier
#' @export
#'
compare_comrad_versions <- function() {

  session <- ssh::ssh_connect(
    "p282688@peregrine.hpc.rug.nl"
  )

  local_version <- utils::packageVersion("comrad")
  hpc_version <- utils::capture.output(
    ssh::ssh_exec_wait(
      session = session,
      command = "module load R; Rscript -e \"packageVersion('comrad')\""
    )
  )[1] %>%
    stringr::str_sub(6, 10)
  if (!local_version == hpc_version) {
    stop("comrad versions are different between HPC and local computer")
  }

  ssh::ssh_disconnect(session)
}
