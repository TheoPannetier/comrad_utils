logbook <- readr::read_csv("comsie_data/daisie/logs/logbook_daisie_ml.csv")

# Complete STATUS entries
job_ids <- logbook$job_id[is.na(logbook$status)]
status <- job_status(job_ids)
beepr::beep(1)
status
logbook$status[which(logbook$job_id %in% job_ids)] <- status

# Complete RUNTIME entries
runtime <- job_runtime(job_ids)
beepr::beep(1)
logbook$runtime[which(logbook$job_id %in% job_ids)] <- runtime

readr::write_csv(logbook, file = "comsie_data/daisie/logs/logbook_daisie_ml.csv")

# How many with each status
overview <- logbook %>%
  group_by(status, competition_sd, immigration_rate, f, daisie_version) %>%
  count()

comm_size_tbl <- readRDS("/Volumes/morozilka/comsie_data/diversity/comm_size_daisie.rds")

# Add a nb clades entry
find_nb_clades <- function(i) {
  siga <- logbook$competition_sd[i]
  gamma <- logbook$immigration_rate[i]
  rep <- logbook$replicate[i]

  nb_clades <- comm_size_tbl %>% dplyr::filter(
    near(competition_sd, siga),
    near(immigration_rate, gamma),
    replicate == rep
  ) %>% pull(nb_clades)
  testit::assert(length(nb_clades) == 1)
  return(nb_clades)
}
find_nb_clades(23)
nb_clades <- map_int(1:nrow(logbook), find_nb_clades)
logbook$nb_clades <- nb_clades

# Subset for manual inspection
subset <- logbook %>%
  dplyr::filter(
    # competition_sd == 0.091,
    # immigration_rate == 0.0001,
    status == "COMPLETED",
    daisie_version == "IW"
  )
subset %>%
  group_by(status, competition_sd, immigration_rate) %>%
  count()

job_ids <- logbook %>%
  dplyr::filter(
    status == "COMPLETED",
    is.na(runtime)
  ) %>% pull(job_id)

# Rm failed / incorrect jobs entries
to_rm <- logbook %>%
  dplyr::filter(
    status %in% c("FAILED", )
  ) %>%
  pull(job_id)

logs_to_rm <- glue::glue(
  path_to_fabrika_hpc(),
  "/comsie_data/daisie/logs/daisie_ml_{to_rm}.log"
)

session <- ssh::ssh_connect("p282688@peregrine.hpc.rug.nl")
ssh::ssh_exec_wait(
  session, command = glue::glue("rm {logs_to_rm}")
)
ssh::ssh_disconnect(session)

logbook <- logbook %>% dplyr::filter(
  !job_id %in% to_rm
)
