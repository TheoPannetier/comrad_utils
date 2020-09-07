#' Run comrad simulations on the Peregrine HPC
#'
#' Calls `run_comrad_sim.bash` and passes arguments to
#' [comrad::run_simulation()], submits the simulation jobs through [ssh] to
#' Peregrine.
#'
#' @inheritParams default_params_doc
#' @param params_array a data frame containing all combinations of `comrad`
#' parameters to submit. One column per parameter, one row for each unique
#' combination of values. Tip: use [create_comrad_params()] to provide the
#' parameter values, then combine the output with [base::expand.grid()] as in
#' the default.
#' @param nb_replicates numeric, number of replicate simulations to run.
#' Each unique combination of parameters in `params_array` will be submitted
#' `nb_replicates` times.
#' @param sampling_freq numeric \code{> 0}, the frequency (in generations) at
#' which the community is written to output. See [comrad::set_sampling_freq()]
#' for the default option.
#' @param sampling_frac numeric (between 0 and 1), fraction of the community
#' (in terms of individuals) written to output at every sampled generation. A
#' truncation is operated.
#' @param seeds numeric vector of integers, to seed simulations with. Length
#' must be `nrow(params_array) * nb_replicates`, i.e each job receives a unique
#' seed. This is because each simulation job is run in an independent session,
#' so simulations run with the same seed will be identical. Use this to repeat
#' simulations, otherwise use the default.
#' @param walltime character, maximum time allocated by the HPC to a job.
#' Format must be either `HH:MM:SS` or `D-HH:MM:SS`.
#' @author Théo Pannetier
#' @export
#'
run_comrad_sim_hpc <- function(
  nb_gens,
  params_array = fabrika::create_comrad_params() %>% expand.grid(),
  nb_replicates = 1,
  sampling_freq = comrad::set_sampling_freq(nb_gens),
  sampling_frac = comrad::default_sampling_frac(),
  seeds = sample(1:50000, nb_replicates * nrow(params_array)),
  walltime = "00:57:00"
) {
  # Check input
  comrad::testarg_num(nb_gens)
  comrad::testarg_pos(nb_gens)
  comrad::testarg_not_this(nb_gens, 0)
  comrad::testarg_num(nb_replicates)
  comrad::testarg_int(nb_replicates)
  comrad::testarg_not_this(nb_replicates, 0)
  comrad::testarg_num(seeds)
  comrad::testarg_length(seeds, nb_replicates)

  is_walltime <- function (walltime) {
    stringr::str_detect(walltime, "^([0-9]-)?[0-9]{2}:[0-5][0-9]:[0-5][0-9]$")
  }
  if (!all(is_walltime(walltime))) {
    stop("argument \"walltime\" is not a walltime")
  }

  # Generate batch ID
  batch_id <- paste0("b", sample(10000:99999, 1))

  cat("Jobs submitted with batch ID", batch_id, "\n")

  # Concatenate sbatch calls
  commands <- params_array %>%
    glue::glue_data(
      "sbatch",
      "--time={walltime}",
      "/data/$USER/fabrika/bash/run_comrad_sim.bash",
      "{batch_id}",
      "{nb_gens}",
      "{competition_sd}",
      "{carrying_cap_sd}",
      "{carrying_cap_opt}",
      "{trait_opt}",
      "{growth_rate}",
      "{prob_mutation}",
      "{mutation_sd}",
      "{trait_dist_sp}",
      "{sampling_freq}",
      "{sampling_frac}",
      .sep = " "
    ) %>%
    # Each replicate gets its own seed
    rep(nb_replicates) %>%
    paste(seeds)

  # Connect to hpc
  session <- ssh::ssh_connect(
    "p282688@peregrine.hpc.rug.nl"
  )

  # Submit job nb_replicate times to hpc
  purrr::walk(commands, function(command) {
    ssh::ssh_exec_wait(
      session = session,
      command = command
    )
  })
  # Disconnect
  ssh::ssh_disconnect(
    session = session
  )
}
