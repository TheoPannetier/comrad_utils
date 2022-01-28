siga_vec_comsie <- function() {
  # assuming sigma_k = 3
  return(c(
    "K = 20" = 0.369,
    "K = 30" = 0.267,
    "K = 40" = 0.209,
    "K = 50" = 0.172,
    "K = 60" = 0.146,
    "K = 70" = 0.127,
    "K = 80" = 0.112,
    "K = 90" = 0.100,
    "K = 100" = 0.091
    ))
}

nb_gens_vec_comsie<- function() {
  return(c(
    "K = 20" = 350000,
    "K = 30" = 275000,
    "K = 40" = 200000,
    "K = 50" = 185000,
    "K = 60" = 170000,
    "K = 70" = 155000,
    "K = 80" = 140000,
    "K = 90" = 125000,
    "K = 100" = 110000
  ))
}

walltime_vec_comsie <- function() {
  return(c(
    "K = 20" = "21:00:00",
    "K = 30" = "29:00:00",
    "K = 40" = "33:00:00",
    "K = 50" = "45:00:00",
    "K = 60" = "60:00:00",
    "K = 70" = "67:00:00",
    "K = 80" = "78:00:00",
    "K = 90" = "87:00:00",
    "K = 100" = "110:00:00"
  ))
}

get_walltime <- function(siga) {
  dplyr::case_when(
    near(siga, 0.369) ~ "21:00:00",
    near(siga, 0.267) ~ "29:00:00",
    near(siga, 0.209) ~ "33:00:00",
    near(siga, 0.172) ~ "45:00:00",
    near(siga, 0.146) ~ "60:00:00",
    near(siga, 0.127) ~ "67:00:00",
    near(siga, 0.112) ~ "78:00:00",
    near(siga, 0.100) ~ "87:00:00",
    near(siga, 0.091) ~ "110:00:00"
  )
}

get_nb_gens <- function(siga) {
  case_when(
    near(siga, 0.369) ~ 350000,
    near(siga, 0.267) ~ 275000,
    near(siga, 0.209) ~ 200000,
    near(siga, 0.172) ~ 185000,
    near(siga, 0.146) ~ 170000,
    near(siga, 0.127) ~ 155000,
    near(siga, 0.112) ~ 140000,
    near(siga, 0.100) ~ 125000,
    near(siga, 0.091) ~ 110000
  )
}
