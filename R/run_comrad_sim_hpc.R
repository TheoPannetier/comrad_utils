#' Run comrad simulations on the Peregrine HPC
#'
#' Calls `run_comrad_sim.bash` and passes arguments to
#' [comrad::run_simulation()], submits the simulations through [ssh].
#'
#' @inheritParams default_params_doc
#' @param nb_replicates numeric, number of replicate simulations to run. All
#' replicates share the same parameters. One job is submitted per replicate.
#' @param comrad_params a list of parameters for [comrad::run_simulation()],
#' as created with [create_comrad_params()]
#'
#' @author Théo Pannetier
#' @export
#'
run_comrad_sim_hpc <- function(
  nb_gens,
  nb_replicates = 1,
  comrad_params = fabrika::create_comrad_params()
) {
  # Check input
  comrad::testarg_num(nb_gens)
  comrad::testarg_pos(nb_gens)
  comrad::testarg_not_this(nb_gens, 0)
  comrad::testarg_num(nb_replicates)
  comrad::testarg_int(nb_replicates)
  comrad::testarg_not_this(nb_replicates, 0)

  # Connect to hpc
  session <- ssh::ssh_connect(
    "p282688@peregrine.hpc.rug.nl"
  )

  # Generate batch ID
  batch_id <- paste0("00", sample(10000:99999, 1))

  # Concatenate command
  command <- paste(
    "sbatch comrad_fabrika/scripts/bash/run_comrad_sim.bash",
    batch_id,
    nb_gens,
    comrad_params$competition_sd,
    comrad_params$carrying_cap_sd,
    comrad_params$carrying_cap_opt,
    comrad_params$trait_opt,
    comrad_params$growth_rate,
    comrad_params$prob_mutation,
    comrad_params$mutation_sd,
    comrad_params$trait_dist_sp
  )

  # Submit job nb_replicate times to hpc
  purrr::walk(
    1:nb_replicates,
    function(x) {
      ssh::ssh_exec_wait(
        session = session,
        command = command
      )
    }
  )
  # Disconnect
  ssh::ssh_disconnect(
    session = session
  )
}
