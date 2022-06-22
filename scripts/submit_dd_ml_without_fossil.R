# Submit DD ML without fossil jobs
which_one <- "dd_ml_without_fossil"
download_logbook_hpc(which_one)
# 39053

logbook %>% slice_tail()

logbook <- read_logbook(which_one)
subset <- logbook %>%
  dplyr::filter(
    #!near(competition_sd, 0.1),
    #carrying_cap_sd == 5
    #batch_id %in% c("b205903", "b142747")
  )

job_ids <- subset$job_id
job_ids <- job_ids[!is_dd_ml_rds_on_hd(job_ids, with_fossil = FALSE)]
job_ids %>% download_dd_ml_without_fossil_rds_hpc()


paths <- glue::glue(path_to_fabrika_local(), "comrad_data/ml_results/dd_ml_without_fossil_{job_ids}.rds")
new_paths <- glue::glue(path_to_hd(), "comrad_data/ml_results/dd_ml_without_fossil_{job_ids}.rds")

fs::file_copy(
  path = paths,
  new_path = new_paths,
  overwrite = FALSE
)

job_ids <- job_ids[job_ids %>% is_dd_ml_rds_on_local(with_fossil = FALSE)]
job_ids %>% download_dd_ml_without_fossil_rds_hpc()

ns <- logbook %>%
  group_by(competition_sd, carrying_cap_sd, dd_model) %>%
  summarise(
    "n_entries" = n(),
    "n_completed" = sum(status == "COMPLETED")
  )

subset$job_id %>% complete_logbook_entries(which_one = which_one, vars = "status")

ml <- readRDS("comrad_data/ml_results/ml_without_fossil_sigk_1_siga_0.1.rds")
# DDD 2.5
ml <- readRDS("comrad_data/ml_results/dd_ml_without_fossil_21619678.rds")
# DDD 5.0.1
ml <- readRDS("comrad_data/ml_results/dd_ml_without_fossil_22072735.rds")

subset <- logbook %>% dplyr::filter(job_id %in% job_ids)

job_ids <- logbook$job_id

job_ids <- job_ids[!is_dd_ml_rds_on_local(job_ids, with_fossil = FALSE)]
job_ids %>% download_dd_ml_without_fossil_rds_hpc()
beepr::beep(3)

subset <- logbook %>%
  dplyr::filter(DDD_version == "[1] ‘5.0’",
                dd_model == "xx"
  ) #%>%
job_ids <- subset$job_id

job_ids[1:10] %>% complete_logbook_entries(which_one, "status")

job_ids %>% download_dd_ml_without_fossil_rds_hpc()

#######

subset <- logbook %>%
  dplyr::filter(
    near(competition_sd, 0.1),
    carrying_cap_sd == 5
  ) #%>%
job_ids <- subset$job_id

ml <- job_ids %>% map_dfr(function(job_id) {
  readRDS(glue::glue("../fabrika/comrad_data/ml_results/dd_ml_without_fossil_{job_id}.rds"))
}) %>%
  dplyr::mutate(
    "job_id" = as.character(job_id),
    # Catch failed ML results
    "ml_lambda_0" = ifelse(loglik == -1, NA, ml_lambda_0),
    "ml_mu_0" = ifelse(loglik == -1, NA, ml_mu_0),
    "ml_k" = ifelse(loglik == -1, NA, ml_k),
    "ml_alpha" = ifelse(loglik == -1, NA, ml_alpha),
    "loglik" = ifelse(loglik == -1, -Inf, loglik),
    # Compute AIC
    "nb_params" = ifelse(stringr::str_detect(dd_model, "c"), 3, 4),
    "aic" = 2 * nb_params - 2 * loglik
  ) %>% dplyr::relocate(
    init_alpha, .after = init_k
  ) %>%
  dplyr::relocate(
    ml_alpha, .after = ml_k
  )

ml2 <- ml %>%
  group_by(tree, dd_model) %>%
  slice_min(aic, with_ties = FALSE) %>%
  dplyr::ungroup(dd_model) %>%
  dplyr::arrange(tree, aic) %>%
  dplyr::mutate(
    "delta_aic" = aic - min(aic),
    "aicw_num" = exp(-delta_aic / 2),
    "aicw_denom" = sum(aicw_num),
    "aicw" = round(aicw_num / aicw_denom)
  )

#####
# args <- comrad_params_retained() %>%
#   tidyr::expand_grid(
#     "dd_model" = dd_model_names(),
#     "tree" = 1:100,
#     #"batch_id" = paste0("b", sample(100000:999999, 1)),
#     "batch_id" = "b536972",
#     "verbose" = FALSE
#   )

siga <- 0.6
sigk <- 4

batch_id <- paste0("b", sample(100000:999999, 1))
args <- tidyr::expand_grid(
  "siga" = siga,
  "sigk" = sigk,
  "dd_model" = c("pc"),
  "tree" = 1:100,
  "batch_id" = batch_id,
  "verbose" = FALSE
)

subset <- logbook %>%
  dplyr::filter(near(competition_sd, siga), carrying_cap_sd == sigk) %>%
  dplyr::rename("siga" = competition_sd, "sigk" = carrying_cap_sd)

args2 <- anti_join(args, subset, by = c("siga", "sigk", "tree", "dd_model"))

#
# ddmod <- "pl"
# trees <- subset %>%
#   dplyr::filter(
#     dd_model == ddmod
#   ) %>%
#   pull(tree)

# commands <- args %>%
#   dplyr::filter(
#     sigk %in% c(3),
#     near(siga, 0.3),
#     stringr::str_ends(dd_model , pattern = "c|l")
#     ) %>%
#   glue::glue_data(
#     "sbatch /data/p282688/fabrika/bash/run_dd_ml_without_fossil_regular.bash {siga} {sigk} {dd_model} {tree} {batch_id} {verbose}"
#   )

commands <- args %>%
  glue::glue_data(
    "sbatch /data/p282688/fabrika/bash/run_dd_ml_without_fossil.bash {siga} {sigk} {dd_model} {tree} {batch_id} {verbose}"
  )

# commands <- "sbatch /data/p282688/fabrika/bash/run_dd_ml_without_fossil_regular.bash 0.7 5 pl 43 b597180 FALSE"

session <- ssh::ssh_connect("p282688@peregrine.hpc.rug.nl")
ssh::ssh_exec_wait(
  session = session,
  command = commands
)
ssh::ssh_disconnect(session = session)

comrad_params_retained()[21:32,]

# b205903
# cat /data/${USER}/fabrika/comrad_data/logs/dd_ml_without_fossil_22544597.log
# /data/p282688/fabrika/comrad_data/ml_results/dd_ml_without_fossil_22290191.rds

download_dd_ml_without_fossil_log_hpc(22544597)

