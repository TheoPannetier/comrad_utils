## Edit bash scripts
install_comrad_hpc(ref = "develop")
# check installation
upload_sim_bash_hpc()

## Run simulations
run_comrad_sim_hpc(
  nb_gens = 50000,
  nb_replicates = 100
)
## Catch job IDs
job_ids <- job_ids_from_string(
  "JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
          13601215   gelifes run_comr  p282688  R 1-23:28:50      1 pg-node216
          13601198   gelifes run_comr  p282688  R 1-23:28:58      1 pg-node217
          13601183   gelifes run_comr  p282688  R 1-23:29:05      1 pg-node217
          13601167   gelifes run_comr  p282688  R 1-23:29:13      1 pg-node217
          13601229   gelifes run_comr  p282688  R 1-23:23:01      1 pg-node224 "
)


job_ids <- batch_id_to_job_ids("b12337")
job_ids %>% cat_sim_log_hpc()

## Watch Peregrine
queue()
job_ids %>% job_status()
job_ids %>% has_job_completed() %>% sum()
cat_sim_log_hpc(job_ids[1])

job_ids <- batch_id_to_job_ids("")

## Download & upload data
download_logbook_hpc()
job_ids %>% complete_logbook_entries()
logbook <- read_logbook()
job_ids %>% download_sim_log_hpc()
job_ids %>% download_sim_csv_hpc()

job_ids %>% upload_sim_csv_drive()
job_ids %>% upload_sim_log_drive()
update_logbook_drive()

job_ids[!job_ids %>% is_sim_csv_on_drive()] %>% upload_sim_csv_drive()
job_ids[!job_ids %>% is_sim_log_on_drive()] %>% upload_sim_log_drive()

# Git!!

logbook <- read_logbook()

# Grab job IDs
batch_id <- "b24475"
job_ids <- batch_id %>% batch_id_to_job_ids()
files <- glue::glue("comrad_data/sims/comrad_sim_{job_ids}.csv")

# Load data
comrad_tbls <- purrr::map(files, comrad::read_comrad_tbl, skip = 17)

# Plot!
comrad_tbls %>% purrr::map(
  function(x) {
    x %>%
    comrad::plot_comm_trait_evolution() +
      ggplot2::theme_classic()
  }
)
