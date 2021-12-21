#' Create a list of standard comsie parameters
#'
#' Just returns a list with all standard parameters. This makes it easy to
#' modify a few while keeping default values for others.
#'
#' @inheritParams default_params_doc
#'
#' @author Théo Pannetier
#' @export
create_comsie_params <- function(
  immigration_rate = 0.001,
  mainland_nb_species = 1000,
  mainland_z_sd = 0.1,
  competition_sd = comrad::default_competition_sd(),
  carrying_cap_sd = comrad::default_carrying_cap_sd(),
  carrying_cap_opt = comrad::default_carrying_cap_opt(),
  trait_opt = comrad::default_trait_opt(),
  growth_rate = comrad::default_growth_rate(),
  mutation_sd = comrad::default_mutation_sd(),
  trait_dist_sp = comrad::default_trait_dist_sp()
) {
  # Check params format
  comrad::testarg_num(immigration_rate)
  comrad::testarg_prop(immigration_rate)
  comrad::testarg_num(mainland_nb_species)
  comrad::testarg_pos(mainland_nb_species)
  comrad::testarg_num(mainland_z_sd)
  comrad::testarg_pos(mainland_z_sd)
  comrad::testarg_num(competition_sd)
  comrad::testarg_pos(competition_sd)
  comrad::testarg_num(carrying_cap_sd)
  comrad::testarg_pos(carrying_cap_sd)
  comrad::testarg_num(carrying_cap_opt)
  comrad::testarg_pos(carrying_cap_opt)
  comrad::testarg_num(trait_opt)
  comrad::testarg_num(growth_rate)
  comrad::testarg_pos(growth_rate)
  comrad::testarg_num(mutation_sd)
  comrad::testarg_pos(mutation_sd)
  comrad::testarg_num(trait_dist_sp)
  comrad::testarg_pos(trait_dist_sp)

  # Return params in a single list
  comsie_params <- list(
    "competition_sd" = competition_sd,
    "carrying_cap_sd" = carrying_cap_sd,
    "carrying_cap_opt" = carrying_cap_opt,
    "trait_opt" = trait_opt,
    "growth_rate" = growth_rate,
    "mutation_sd" = mutation_sd,
    "trait_dist_sp" = trait_dist_sp
  )
  return(comsie_params)
}
