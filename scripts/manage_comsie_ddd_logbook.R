logbook <- readr::read_csv("comsie_data/ddd/logs/logbook_ddd_ml.csv")

subset <- logbook %>%
  dplyr::filter(
    immigration_rate %in% c(5e-04, 1e-02), f == 0.5
  )

subset %>% group_by(f, immigration_rate, dd_model, status) %>% count()

to_keep <- subset2$job_id
to_rm <- subset %>%
  dplyr::filter(!job_id %in% to_keep) %>%
  pull(job_id)

# Complete STATUS entries
job_ids <- subset$job_id[is.na(subset$status)]
status <- job_status(job_ids)
beepr::beep(1)
status
logbook$status[which(logbook$job_id %in% job_ids)] <- status

readr::write_csv(logbook, file = "comsie_data/ddd/logs/logbook_ddd_ml.csv")

commands <- glue::glue("rm /data/p282688/fabrika/comsie_data/ddd/logs/cr_ml_{to_rm}.log")

session <- ssh::ssh_connect(
  "p282688@peregrine.hpc.rug.nl"
)

ssh::ssh_exec_wait(
  session = session,
  command = commands
)

ssh::ssh_disconnect(
  session = session
)
