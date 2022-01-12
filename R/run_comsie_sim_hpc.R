#' Run comrad simulations on the Peregrine HPC
#'
#' Calls `run_comsie_sim.bash` and passes arguments to
#' [comsie::run_simulation()], submits the simulation jobs through [ssh] to
#' Peregrine.
#'
#' @param nb_gens integer, how many generations should the simulation be run
#' for? Length must be either 1 (all jobs are given the same number of
#' generations) or `nrow(params_array)` (custom value for each job).
#' walltime for each job).
#' @param params_array a data frame containing all combinations of `comsie`
#' parameters to submit. One column per parameter, one row for each unique
#' combination of values. Tip: use [create_comsie_params()] to provide the
#' parameter values, then combine the output with [base::expand.grid()] as in
#' the default.
#' @param nb_replicates numeric, number of replicate simulations to run.
#' Each unique combination of parameters in `params_array` will be submitted
#' `nb_replicates` times.
#' @param sampling_on_event logical. If `TRUE`, the community is sampled every
#' time a speciation or extinction happens, and `sampling_freq` is ignored and
#' must be set to `NA`.
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
#' Format must be either `HH:MM:SS` or `D-HH:MM:SS`. Length must be either 1
#' (all jobs are given the same walltime) or `nrow(params_array)` (custom
#' walltime for each job).
#' @param check_pkgs_version logical. If `TRUE`, `fabrika` compares installed
#' versions of `comrad` and `comsie` on HPC vs local before running the simulations, and
#' return an error if they mismatch.
#' @param brute_force_opt a string specifying which brute force option to use
#' to speed up the calculation of competition coefficients. Defaults to
#' "simd_omp". Other options are "omp", for multithreading with OpenMP, "simd"
#' for single instruction, multiple data (SIMD) via the C++ library
#' [`xsimd`](https://github.com/xtensor-stack/xsimd); and "simd_omp" for both.

#' @author Théo Pannetier
#' @export
#'
run_comsie_sim_hpc <- function(
  nb_gens,
  params_array,
  nb_replicates = 1,
  sampling_on_event = FALSE,
  sampling_freq = ifelse(
    sampling_on_event, NA, 200
  ),
  sampling_frac = 0.05,
  seeds = sample(1:50000, nb_replicates * nrow(params_array)),
  walltime = "00:57:00",
  check_pkgs_version = TRUE,
  brute_force_opt = "simd_omp"
) {
  # Input control
  if (!is.data.frame(params_array)) {
    stop("argument \"params_array\" should be a data frame.")
  }
  exptd_var_names <- fabrika::create_comsie_params() %>% names()
  if (!all(params_array %>% names() == exptd_var_names)) {
    stop("\"params_array\" variables should be the same as in create_comsie_params()")
  }
  comrad::testarg_num(nb_gens)
  comrad::testarg_pos(nb_gens)

  comrad::testarg_not_this(nb_gens, 0)
  if (!length(nb_gens) %in% c(1, nrow(params_array))) {
    stop("argument \"nb_gens\" must have length either 1 or nrow(params_array)")
  }
  comrad::testarg_num(nb_replicates)
  comrad::testarg_int(nb_replicates)
  comrad::testarg_not_this(nb_replicates, 0)
  comrad::testarg_num(seeds)
  comrad::testarg_length(seeds, nb_replicates * nrow(params_array))
  is_walltime <- function (walltime) {
    stringr::str_detect(walltime, "^([0-9]-)?[0-9]{1,3}:[0-5][0-9]:[0-5][0-9]$")
  }
  if (!all(is_walltime(walltime))) {
    stop("argument \"walltime\" is not a walltime")
  }
  if (!length(walltime) %in% c(1, nrow(params_array))) {
    stop("argument \"walltime\" must have length either 1 or nrow(params_array)")
  }
  if (sampling_on_event) {
    if (!is.na(sampling_freq)) {
      stop("If \"sampling_on_event\" is TRUE \"sampling_freq\" must be NA.")
    }
  } else {
    comrad::testarg_num(sampling_freq)
    comrad::testarg_int(sampling_freq)
  }
  if (!brute_force_opt %in% c("none", "simd", "omp", "simd_omp")) {
    stop("brute_force_opt must be one of \"none\", \"simd\", \"omp\", \"simd_omp\"")
  }

  # Check comrad version
  if (check_pkgs_version) {
    fabrika::compare_comrad_versions()
    fabrika::compare_comsie_versions()
  }

  # Generate batch ID
  batch_id <- paste0("b", sample(10000:99999, 1))
  cat("Jobs submitted with batch ID", batch_id, "\n")

  # Concatenate sbatch calls
  params_array <- params_array %>% dplyr::mutate(
    "nb_gens" = nb_gens,
    "walltime" = walltime
  )
  commands <- params_array %>%
    dplyr::mutate(
      "nb_gens" = nb_gens,
      "walltime" = walltime
    ) %>%
    glue::glue_data(
      "sbatch",
      "--time={walltime}",
      "/data/$USER/fabrika/bash/run_comsie_sim.bash",
      "{batch_id}",
      "{nb_gens}",
      "{immigration_rate}",
      "{mainland_nb_species}",
      "{mainland_z_sd}",
      "{competition_sd}",
      "{carrying_cap_sd}",
      "{carrying_cap_opt}",
      "{trait_opt}",
      "{growth_rate}",
      "{mutation_sd}",
      "{trait_dist_sp}",
      "{sampling_on_event}",
      "{sampling_freq}",
      "{sampling_frac}",
      "{brute_force_opt}",
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
