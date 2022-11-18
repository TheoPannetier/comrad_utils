{
  job_id <- 23183254
  siga = 0.369
  gamma = 0.001
  i = 17
  f = 1
  skip_daisie = FALSE
  skip_ddd = FALSE
}

logbook <- read_logbook(pkg = "comsie")
source("../fabrika/R/create_comsie_phylos_from_sim.R")

args <- expand_grid(
  "siga" = c(0.369, 0.091),
  "gamma" = c(5e-04, 1e-02),
  "f" = 0.5
)

args %>% pwalk(function(siga, gamma, f) {

    cat(siga, gamma, f, "\n")

    job_ids <- logbook %>%
      dplyr::filter(
        near(competition_sd, siga),
        near(immigration_rate, gamma)
      ) %>% pull(job_id)

    job_ids %>% iwalk(function(job_id, i) {
      #if (i < 17) return()
      cat(i, "/", length(job_ids), "\n")
      create_comsie_phylos_from_sim(
        job_id, siga, gamma, i,
        f = f,
        skip_daisie = TRUE,
        skip_ddd = FALSE
      )
    })
  })

subset <- comsie_tbl %>%
  dplyr::filter(
    species == "#3A08DA" #| ancestral_species == "#1287B9"
    #mainland_sp == "#25974A"
  )

sp <- "#0DFB22"
#53CAF5

spp[!spp %in% spp_alive]
#3A08DA
sp <- "#3A08DA"
