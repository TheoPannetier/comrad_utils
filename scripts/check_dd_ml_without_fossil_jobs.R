# Assert DD ml without fossil jobs were successful
which_one <- "dd_ml_without_fossil"
download_logbook_hpc(which_one)
logbook <- read_logbook(which_one) %>%
  dplyr::filter(batch_id == "b274834")

job_ids %>% complete_logbook_entries(which_one, c("status"))
rm_logbook_entries(to_rm, which_one = which_one)

siga <- 0.6
sigk <- 4

#comrad_params_retained() %>% pmap(function(siga, sigk) {
  cat(siga, sigk, "\n")
  subset <- logbook %>% dplyr::filter(near(competition_sd, siga), carrying_cap_sd == sigk)
  #to_rm <- subset %>% dplyr::filter(status != "COMPLETED") %>% pull(job_id)
  #subset <- subset %>% dplyr::filter(status == "COMPLETED")
  count_dd_model <- subset %>% group_by(dd_model) %>% count()
  count_trees <- subset %>% group_by(tree) %>% count()
  if (any(count_dd_model$n != 100)) {
    stop("Missing or extra trees")
  }
  if (any(count_trees$n != 6)) {
    stop("Missing or extra DD models")
  }
  job_ids <- subset$job_id
  missing <- job_ids[!is_dd_ml_rds_on_local(job_ids, with_fossil = FALSE)]
  download_dd_ml_without_fossil_rds_hpc(missing)
  to_rm <- missing
  ml_tbl <- job_ids %>% map_dfr(function(job_id) {
    readRDS(glue::glue("../fabrika/comrad_data/ml_results/dd_ml_without_fossil_{job_id}.rds"))
  }) %>%
    dplyr::mutate(
      "job_id" = as.character(job_id),
      # Catch failed ML results
      "ml_lambda_0" = ifelse(loglik == -1, NA, ml_lambda_0),
      "ml_mu_0" = ifelse(loglik == -1, NA, ml_mu_0),
      "ml_k" = ifelse(loglik == -1, NA, ml_k),
      #"ml_alpha" = ifelse(loglik == -1, NA, ml_alpha),
      "ml_alpha" = as.numeric(NA),
      "init_alpha" = as.numeric(NA),
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

  ml_tbl <- ml_tbl %>% group_by(tree, dd_model) %>% slice_min(aic, with_ties = FALSE)
  count_ml <- ml_tbl %>%
    ungroup(dd_model) %>%
    summarise(
      sum_aic = sum(aic)
    )
  nb_viabLe <- sum(is.finite(count_ml$sum_aic))
  cat(nb_viabLe, "/ 100 viable trees\n")

  saveRDS(ml_tbl, glue::glue("../fabrika/comrad_data/ml_results/ml_without_fossil_sigk_{sigk}_siga_{siga}_new.rds"))
#})

ml_tbl2 <- ml_tbl %>%
  filter_aic_best2()

saveRDS(ml_tbl, "~/test_ml_without_fossil_sigk_4_siga_0.6_all.rds")
saveRDS(ml_tbl2, "~/test_ml_without_fossil_sigk_4_siga_0.6_best.rds")
