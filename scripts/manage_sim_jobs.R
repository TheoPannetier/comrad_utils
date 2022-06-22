prev_logbook <- read_csv("../fabrika/comrad_data/logs/logbook_sampling_freq.csv",
                         col_types = list("runtime" = readr::col_character()))
logbook <- read_logbook()

siga <- 0.1
sigk <- 1

nb_gens <- logbook %>% dplyr::filter(
  competition_sd == siga,
  carrying_cap_sd == sigk
) %>%
  distinct(nb_gens) %>% pull(nb_gens)

walltime <- logbook %>% dplyr::filter(
  competition_sd == siga,
  carrying_cap_sd == sigk
) %>%
  distinct(runtime) %>% pull()
walltime

#seeds <- logbook %>% dplyr::filter(competition_sd == siga, carrying_cap_sd == sigk, sampling_on_event == TRUE) %>% pull(seed)

run_comrad_sim_hpc(
  params_array = create_comrad_params(
    competition_sd = siga,
    carrying_cap_sd = sigk
  ) %>% expand.grid(),
  nb_replicates = 900,
  walltime = "04:59:00",
  nb_gens = nb_gens,
  sampling_on_event = TRUE,
  sampling_frac = 0.05,
  #seeds = seeds,
  check_comrad_version = FALSE,
  brute_force_opt = "simd_omp"
)

download_logbook_hpc()
logbook <- read_logbook()
job_ids <- logbook %>% dplyr::filter(batch_id == "b47743") %>% pull(job_id)
logbook %>% dplyr::filter(batch_id == "b47743") %>% pull(status) %>% unique()
logbook %>% dplyr::filter(competition_sd == 0.2, carrying_cap_sd == 1,
                          sampling_on_event == FALSE, batch_id != "b47743")
logbook <- logbook %>% dplyr::filter(batch_id != "b91125")

job_ids <- logbook %>% dplyr::filter(
  carrying_cap_sd == 1,
  competition_sd == 0.5
)
    # %>% pull(job_id)
job_ids %>% complete_logbook_entries(vars = c("status"))

nc <- logbook[1001:2000, ] %>% dplyr::filter(status == "CANCELLED,TIMEOUT")
nc$job_id[5:12] %>% complete_logbook_entries(vars = "last_gen")

job_id <- logbook %>% dplyr::filter(
  competition_sd == 0.1, carrying_cap_sd == 2
) %>% pull(job_id) %>% .[1]

job_ids[!is_sim_csv_on_local(job_ids)] %>% download_sim_csv_hpc()

nc <- logbook %>% dplyr::filter(
  competition_sd == 0.7,
  carrying_cap_sd == 3,
  status != "COMPLETED"
)

new_jobs <- logbook %>% dplyr::filter(
  carrying_cap_sd == 2,
  competition_sd == 0.2,

) %>% pull(job_id)
new_jobs %>% complete_logbook_entries(c("status", "runtime"))
new_jobs %>% download_sim_csv_hpc()
new_jobs %>% download_sim_csv_hpc()

logbook <- read_logbook()

jobs_failed <-  logbook %>% dplyr::filter(
  carrying_cap_sd == 2,
  competition_sd == 0.4,
  status == "CANCELLED,TIMEOUT"
) %>% pull(job_id)
jobs_failed[!is_sim_csv_on_local(jobs_failed)] %>% download_sim_csv_hpc()

logbook <- logbook %>% dplyr::filter(!job_id %in% jobs_failed)

logbook <- logbook %>% dplyr::arrange(desc(sampling_on_event), carrying_cap_sd, competition_sd)

readr::write_csv(
  logbook,
  file = paste0(path_to_fabrika_local(), "comrad_data/logs/logbook.csv")
)

session <- ssh::ssh_connect(
  "p282688@peregrine.hpc.rug.nl"
)

ssh::scp_upload(
  session = session,
  files = paste0(path_to_fabrika_local(), "comrad_data/logs/logbook.csv"),
  to = paste0(path_to_fabrika_hpc(), "comrad_data/logs/")
)
ssh::ssh_disconnect(session = session)

logbook <- read_logbook()
subset <- logbook %>% dplyr::filter(
  #carrying_cap_sd == 5,
  #competition_sd == 1,
  #sampling_on_event == TRUE,
  batch_id == "b13391"
  )
subset %>% pull(csv_size) %>% sum()
job_ids <- subset %>% pull(job_id)

job_ids %>% complete_logbook_entries(c("csv_size"))

logbook %>% dplyr::filter(status == "pending_check") %>% pull(job_id) %>%
  complete_logbook_entries(c("status"))

job_ids[!is_sim_csv_on_local(job_ids)] %>% download_sim_csv_hpc()
job_ids[!is_sim_log_on_local(job_ids)] %>% download_sim_log_hpc()
job_ids[!is_sim_csv_on_hd(job_ids)]

subset %>% pull(csv_size) %>% sum()

job_ids <- logbook %>% dplyr::filter(carrying_cap_sd %in% 4:5) %>% pull(job_id)
job_ids[1001:2000] %>% complete_logbook_entries(c("csv_size"))


