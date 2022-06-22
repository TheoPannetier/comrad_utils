fix_comsie_ancestor_data <- function(job_id) {
  cat(job_id, "\n")
  path_to_sim_input <- glue::glue("/Volumes/samsagace/comsie_data/sims/comsie_sim_{job_id}.csv")
  header <- readr::read_csv(
    path_to_sim_input,
    n_max = 1026,
    skip_empty_rows = FALSE,
    col_types = list(readr::col_character())
  )
  comsie_tbl <- comsie::read_comsie_tbl(path_to_sim_input)
  t_max <- max(comsie_tbl$t)
  if (t_max %% 5000 != 0) {
    stop(glue::glue("{job_id} may not have completed: t_max = {t_max}."))
  }
  nrows <- nrow(comsie_tbl)
  all_spp <- unique(comsie_tbl$species)
  path_to_log <- path_to_log_hd(job_id, pkg = "comsie")

  # Read all events
  events_tbl <- read_events_from_log(path_to_log)
  events_tbl <- dplyr::bind_rows(
    # Add entry for immigration of first species, not recorded in log
    tibble::tibble(
      "t" = 0,
      "species" = unique(comsie_tbl$species[comsie_tbl$t == 0]),
      "ancestor" = NA,
      "event" = "immigration"
    ),
    events_tbl
  )

  # spp_duplicates <- events_tbl %>%
  #   dplyr::group_by(species) %>%
  #   summarise(
  #     "n_immig" = sum(event == "immigration"),
  #     "n_other" = sum(event %in% c("cladogenesis", "anagenesis")),
  #     "has_multiple_origins" = n_other > 1 || (n_immig > 0 && n_other > 0)
  #   ) %>%
  #   dplyr::filter(has_multiple_origins) %>%
  #   dplyr::pull(species)
  #
  # events_tbl %>%
  #   dplyr:::filter(species %in% spp_duplicates)

  anag_times <- events_tbl$t[events_tbl$event == "anagenesis"]
  events_tbl$is_anag_time <- events_tbl$t %in% anag_times

  # All species alive at the time of an anagenesis event must be fixed
  spp_to_fix <- unique(comsie_tbl$species[comsie_tbl$t %in% anag_times])

  # Read true ancestors from events
  correct_ancestors <- map_chr(spp_to_fix, function(sp) {
    #cat(sp, "\n")
    anc <- unique(events_tbl$ancestor[events_tbl$species == sp])
    if (length(anc) > 1) {
      cat(glue::glue("Species {sp} has multiple origins\n"))
      return("skip_this")
    }
    return(anc)
  })
  if (any(correct_ancestors[!is.na(correct_ancestors)] == "skip_this")) {
    # then skip this job
    readr::write_file(glue::glue(job_id, "\n\n"), file = "~/comsie_to_deal_with.txt", append = TRUE)
    return()
  }

  # Fix ancestors
  for (i in seq_along(spp_to_fix)) {
    comsie_tbl$ancestral_species[comsie_tbl$species == spp_to_fix[i]] <- correct_ancestors[i]
  }

  # Check output
  if (!nrow(comsie_tbl) == nrows) {
    stop("Nb of rows has changed!")
  }
  walk(all_spp, function(sp) {
    this_sp <- comsie_tbl[comsie_tbl$species == sp, ]
    ancestors <- unique(this_sp$ancestral_species)
    if (length(ancestors) > 1) {
      stop(glue::glue("Species {sp} still has more than 1 ancestor!"))
    }
  })

  # Save output
  path_to_sim_output <- path_to_sim_hd(job_id, pkg = "comsie")
  header %>% readr::write_csv(path_to_sim_output, na = "", quote = "none")
  comsie_tbl %>% readr::write_csv(path_to_sim_output, append = TRUE, col_names = FALSE)
  readr::write_file(glue::glue(job_id, "\n\n"), file = "~/comsie_fixed_jobs.txt", append = TRUE)
}
