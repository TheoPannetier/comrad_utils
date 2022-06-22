
# DAISIE
args <- tidyr::expand_grid(
  "siga" = c(0.091, 0.369),
  "gamma" = c(1e-04),
  "i" = 1:100
) %>% pwalk(function(siga, gamma, i) {
  cat("siga =", siga, "gamma =", gamma, "i =", i, "\t")
  # Input data
  input_data <- readRDS(
    glue::glue("comsie_data/daisie/input/daisie_input_siga_{siga}_gamma_{gamma}_{i}.rds")
  )
  saveRDS(input_data, file = glue::glue(
    "comsie_data/daisie/input/daisie_input_siga_{siga}_gamma_{gamma}_{i}_f_1.rds"
  ))
  # initpars
  initpars_data <- readRDS(
    glue::glue("comsie_data/daisie/input/daisie_initpars_siga_{siga}_gamma_{gamma}_{i}.rds")
  )
  saveRDS(initpars_data, file = glue::glue(
    "comsie_data/daisie/input/daisie_initpars_siga_{siga}_gamma_{gamma}_{i}_f_1.rds"
  ))
})

# DDD
args <- tidyr::expand_grid(
  "siga" = c(0.091),
  "gamma" = c(0, 1e-04, 5e-04, 0.001, 0.01),
  "i" = 1:100
)
args[263:500, ] %>% pwalk(function(siga, gamma, i) {
  cat("siga =", siga, "gamma =", gamma, "i =", i, "\t")
  # Input data
  input_data <- readRDS(
    glue::glue("comsie_data/ddd/input/ddd_input_siga_{siga}_gamma_{gamma}_{i}.rds")
  )
  saveRDS(input_data, file = glue::glue(
    "comsie_data/ddd/input/ddd_input_siga_{siga}_gamma_{gamma}_{i}_f_1.rds"
  ))
  # initpars
  initpars_data <- readRDS(
    glue::glue("comsie_data/ddd/input/ddd_initpars_siga_{siga}_gamma_{gamma}_{i}.rds")
  )
  saveRDS(initpars_data, file = glue::glue(
    "comsie_data/ddd/input/ddd_initpars_siga_{siga}_gamma_{gamma}_{i}_f_1.rds"
  ))
})

#########

args <- tidyr::expand_grid(
  "siga_ibm" = c(0.091, 0.369),
  "gamma_ibm" = c(0.001),
  "replicate" = 1:100,
  "f" = 1
) %>% pwalk(create_comsie_initparsopt_daisie)
