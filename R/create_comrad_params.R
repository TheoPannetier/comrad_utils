#' Create a list of standard comrad parameters
#'
#' Just returns a list with all standard parameters. This makes it easy to
#' modify a few while keeping default values for others.
#'
#' @inheritParams default_params_doc
#'
#' @author Théo Pannetier
#' @export
create_comrad_params <- function(
   competition_sd = comrad::default_competition_sd(),
   carrying_cap_sd = comrad::default_carrying_cap_sd(),
   carrying_cap_opt = comrad::default_carrying_cap_opt(),
   trait_opt = comrad::default_trait_opt(),
   growth_rate = comrad::default_growth_rate(),
   prob_mutation = comrad::default_prob_mutation(),
   mutation_sd = comrad::default_mutation_sd(),
   trait_dist_sp = comrad::default_trait_dist_sp(),
   switch_carr_cap_sd_after = NA,
   switch_carr_cap_sd_to = NA
) {
   # Check params format
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
   if (!is.na(switch_carr_cap_sd_after)) {
      comrad::testarg_num(switch_carr_cap_sd_after)
      comrad::testarg_num(switch_carr_cap_sd_to)
      comrad::testarg_pos(switch_carr_cap_sd_to)
   }

   # Return params in a single list
   comrad_params <- list(
      "competition_sd" = competition_sd,
      "carrying_cap_sd" = carrying_cap_sd,
      "carrying_cap_opt" = carrying_cap_opt,
      "trait_opt" = trait_opt,
      "growth_rate" = growth_rate,
      "prob_mutation" = prob_mutation,
      "mutation_sd" = mutation_sd,
      "trait_dist_sp" = trait_dist_sp,
      "switch_carr_cap_sd_after" = switch_carr_cap_sd_after,
      "switch_carr_cap_sd_to" = switch_carr_cap_sd_to
   )
   return(comrad_params)
}
