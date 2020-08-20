#' Run comrad simulations on the Peregrine HPC
#'
#' Calls `run_comrad_sim.bash` and passes arguments to
#' [comrad::run_simulation()], submits the simulations through [ssh].
#'
#' @param nb_replicates numeric, number of replicate simulations to run. All
#' replicates share the same parameters. One job is submitted per replicate.
#' @inheritParams default_params_doc
#' @param return_job_ids logical. By default, the job IDs are captured and
#' returned.
#'
#' @author Théo Pannetier
#' @export
#'
run_comrad_sim_hpc <- function(
  nb_gens,
  nb_replicates = 1,
  competition_sd = comrad::default_competition_sd(),
  carrying_cap_sd = comrad::default_carrying_cap_sd(),
  carrying_cap_opt = comrad::default_carrying_cap_opt(),
  trait_opt = comrad::default_trait_opt(),
  growth_rate = comrad::default_growth_rate(),
  prob_mutation = comrad::default_prob_mutation(),
  mutation_sd = comrad::default_mutation_sd(),
  trait_dist_sp = comrad::default_trait_dist_sp(),
  return_job_ids = TRUE
) {
  # Check input
  comrad::testarg_num(nb_replicates)
  comrad::testarg_int(nb_replicates)
  comrad::testarg_not_this(nb_replicates, 0)
  comrad::testarg_num(nb_gens)
  comrad::testarg_pos(nb_gens)
  comrad::testarg_int(nb_gens)
  comrad::testarg_num(competition_sd)
  comrad::testarg_pos(competition_sd)
  comrad::testarg_num(carrying_cap_sd)
  comrad::testarg_pos(carrying_cap_sd)
  comrad::testarg_num(carrying_cap_opt)
  comrad::testarg_pos(carrying_cap_opt)
  comrad::testarg_num(trait_opt)
  comrad::testarg_num(growth_rate)
  comrad::testarg_pos(growth_rate)
  comrad::testarg_num(prob_mutation)
  comrad::testarg_prop(prob_mutation)
  comrad::testarg_num(mutation_sd)
  comrad::testarg_pos(mutation_sd)
  comrad::testarg_num(trait_dist_sp)
  comrad::testarg_pos(trait_dist_sp)
  comrad::testarg_log(return_job_ids)

  # Connect to hpc
  session <- ssh::ssh_connect(
    "p282688@peregrine.hpc.rug.nl"
  )

  # Prepare command
  command <- paste(
    "sbatch comrad/scripts/bash/run_comrad_sim.bash",
    nb_gens,
    competition_sd,
    carrying_cap_sd,
    carrying_cap_opt,
    trait_opt,
    growth_rate,
    prob_mutation,
    mutation_sd,
    trait_dist_sp
  )

  # For each replicate
  job_ids <- purrr::map(
    1:nb_replicates,
    function(x) {
      # Capture output to extract job ID
      console_output <- utils::capture.output(
        # Submit job to hpc
        ssh::ssh_exec_wait(
          session = session,
          command = command
        ),
        type = "output"
      )
      # Extract job ID
      job_id <- console_output %>%
        stringr::str_extract("^Submitted batch job [:digit:]{8}$") %>%
        stats::na.omit() %>%
        stringr::str_extract("[:digit:]{8}$") %>%
        as.numeric()
      return(job_id)
    }
  ) %>% unlist()

  ssh::ssh_disconnect(
    session = session
  )

  if (return_job_ids) {
    return(job_ids)
  }
}
