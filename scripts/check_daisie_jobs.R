args <- expand_grid(
  "competition_sd" = siga_vec_comsie()[c(1, 9)],
  "immigration_rate" = c(1e-04, 1e-02),
  "replicate" = 1:100,
  "daisie_version" = c("CS", "IW"),
  "ddmodel" = 11,
  "params_i" = 1
)

path <- "../fabrika/comsie_data/daisie/output/"
files <- list.files("../fabrika/comsie_data/daisie/output/")
path_to_files <- files %>% map_chr(function(file) paste0(path, file))

ml <- path_to_files %>% map_dfr(readRDS) %>%
  dplyr::mutate(across(contains(c("lambda_", "mu_", "gamma_")), ~ . / 1e04)) %>%
  dplyr::filter(!is.na(loglik)) %>%
  as_tibble() %>%
  dplyr::filter(
  # gamma_0 incorrect for those and should be run again
  !(daisie_version == "IW" & immigration_rate == 0.01)
)

overview <- left_join(args, ml, by = c("competition_sd", "immigration_rate", "replicate", "daisie_version", "ddmodel", "params_i"))

overview_cs <- overview %>% dplyr::filter(daisie_version == "CS")
overview_iw <- overview %>% dplyr::filter(daisie_version == "IW")

# 192 missing jobs, about half
completed_cs <- overview_cs %>% dplyr::filter(!is.na(job_id))
# + 3 that failed

completed_iw <- overview_iw %>% dplyr::filter(!is.na(job_id))
# 187 missing
sum(completed_iw)

logbook <- read_csv("comsie_data/daisie/logs/logbook_daisie_ml.csv")
job_ids <- logbook$job_id[1392:1511]
status <- job_status(job_ids)
beepr::beep(1)
logbook$status <- status
write_csv(logbook, "comsie_data/daisie/logs/logbook_daisie_ml.csv")
logbook %>% dplyr::group_by(status) %>%
  count()

rows <- which(logbook$daisie_version == "IW" & logbook$immigration_rate == 1e-04)
runtime <- job_runtime(logbook[rows, ]$job_id)
beepr::beep(1)

logbook$walltime[rows] <- runtime

to_enquire <- logbook %>% dplyr::filter(
  is.na(status) | status %in% c("RUNNING")
) %>% pull(job_id)
to_enquire <- 601:741
status <- job_status(job_ids[to_enquire])
beepr::beep(1)

logbook$status[to_enquire] <- status

args <- logbook %>%
  dplyr::filter(status == "OUT_OF_MEMORY") %>%
  select(competition_sd, immigration_rate, replicate, daisie_version, ddmodel, params_i) %>%
  dplyr::rename("siga" = competition_sd, "gamma" = immigration_rate)

# 141 oom'd; 215 completed; 2 failed; 42 running
completed_iw %>%
  mutate("success" = !is.na(loglik)) %>%
  group_by(competition_sd, immigration_rate, success) %>%
  count()

# siga hi gamma lo 80 / 100
# siga hi gamma hi  3 / 100
# siga lo gamma lo 93 / 100
# siga lo gamma hi  0 / 100

# lost all IW high immigration
# but got most IW low immigration

survivors <- completed_iw %>%
  mutate("success" = !is.na(loglik)) %>%
  dplyr::filter(
    competition_sd == 0.091, immigration_rate ==  0.01, success
  ) %>% pull(replicate)

logbook %>%
  dplyr::filter(
    competition_sd == 0.091, immigration_rate ==  0.01,
    daisie_version == "IW",
    replicate %in% survivors
  ) %>% pull(job_id)

ml_cs <- ml %>%
  dplyr::filter(daisie_version == "CS")

ml_cs %>%
  dplyr::group_by(competition_sd, immigration_rate, init_gamma_0) %>%
  count()

args <- ml_cs %>%
  dplyr::filter(
    init_gamma_0 == 0.000000001
  ) %>%
  select(competition_sd, immigration_rate, replicate, params_i, ddmodel, daisie_version) %>%
  dplyr::rename("siga" = competition_sd, "gamma" = immigration_rate)

ml_iw <- ml %>%
  dplyr::filter(daisie_version == "IW")

ml_iw %>%
  dplyr::group_by(competition_sd, immigration_rate, init_gamma_0) %>%
  count()

ml_iw %>% dplyr::filter(
  immigration_rate == 0.0001
) %>%
  mutate("success" = !is.na(loglik)) %>%
  dplyr::group_by(competition_sd, immigration_rate, success) %>%
  count()

files_to_rm <- glue::glue_data(args,
  "daisie_ml_siga_{siga}_gamma_{gamma}_rep_{replicate}_{daisie_version}_ddmodel_11_1.rds"
)

fs::file_delete(
  paste0(path, files_to_rm)
)

session <- ssh::ssh_connect("p282688@peregrine.hpc.rug.nl")
ssh::ssh_exec_wait(
  session = session,
  command = paste0("rm /data/p282688/fabrika/comsie_data/daisie/output/", files_to_rm)
)
ssh::ssh_disconnect(session)

args <- logbook %>% dplyr::filter(
  job_id %in% job_ids
) %>%
  select(competition_sd, immigration_rate, replicate, params_i, ddmodel, daisie_version) %>%
  dplyr::rename("siga" = competition_sd, "gamma" = immigration_rate)
