create_comsie_phylos_from_sim <- function(job_id, siga, gamma, i, f, skip_daisie = FALSE, skip_ddd = FALSE) {
  cat(job_id, "\n")

  # Read input
  comsie_tbl <- read_comsie_tbl(path_to_sim_hd(job_id, pkg = "comsie")) %>%
    # Reduce
    dplyr::mutate(t = t / 1e04)

  # Set what is the present based on f
  stt <- comsie_tbl %>% group_by(t) %>%
    summarise("nb_sp" = n_distinct(species))
  n_p <- last(stt$nb_sp) # total diversity
  n_f <- ceiling(n_p * f) # fraction of total diversity
  # Last time diversity was under that level
  island_age <- last(stt$t[stt$nb_sp <= n_f])
  n_f <- stt$nb_sp[stt$t == island_age] # fix n_f if that value was never reached
  if (is.na(island_age)) stop("Island age could not be set.")

  # Cut tbl to present
  comsie_tbl <- comsie_tbl %>%
    dplyr::filter(t <= island_age)

  # Rm dead clades
  colonists_alive <- comsie_tbl %>%
    dplyr::filter(near(t ,island_age)) %>%
    pull(founder) %>% unique() %>% sort()

  comsie_tbl <- comsie_tbl %>% dplyr::filter(founder %in% colonists_alive)

  # Split founder column into mainland_sp and nb_immig
  comsie_tbl <- split_founder_col(comsie_tbl)

  # Rm clades not alive at present and set expectations
  clades_alive <- comsie_tbl %>%
    dplyr::filter(near(t, island_age, tol = 0.000001)) %>%
    pull(mainland_sp) %>% unique() %>% sort()
  spp_alive <- comsie_tbl %>%
    dplyr::filter(near(t, island_age, tol = 0.000001)) %>%
    pull(species) %>% unique() %>% sort()
  if (length(spp_alive) != n_f) stop("Number of species alive differs from n_f")

  # Nest by clade and colonisation event
  comsie_ls <- split_comsie_tbl(comsie_tbl)

  # Convert into species-level diversity record
  comsie_ls_spp <- comsie_ls %>%
    purrr::map(function(clade_ls) {
      clade_ls %>% purrr::map(build_comsie_spp_tbl)
    })

  newick_tbl_ls <- comsie_ls_spp %>%
    purrr::imap(function(clade_ls, clade_name) {
      #cat(clade_name, "\n")
      clade_ls %>% purrr::map(function(spp_tbl) {
        spp_tbl <- add_entries_missing_ancestors(spp_tbl, job_id)
        newick_tbl <- build_newick_tbl(spp_tbl)
        return(newick_tbl)
      })
    })

  if (!skip_daisie) {
    # Separate phylos for every colonisation event
    phylo_ls_sep <- newick_tbl_ls %>%
      purrr::map(function(clade_ls) {
        clade_ls %>% purrr::map(function(newick_tbl) {
          # Add stem
          newick_str <- paste0(
            "(", newick_tbl$species_name, ":", newick_tbl$time_death - newick_tbl$time_birth, ");"
          )
          # Build phylo
          phylo <- newick_to_phylo(newick_str, with_fossil = FALSE)
        })
      })
    # Get all_colonisations object
    all_colonisations <- get_all_colonisations(phylo_ls_sep, island_age)
    rm(phylo_ls_sep)
  }

  # Gather tables to get one per mainland sp
  newick_tbl_ls <- newick_tbl_ls %>%
    purrr::map(function(clade_ls) {
      clade_ls %>% dplyr::bind_rows()
    })

  # Create one phylo per mainland sp
  phylo_ls_joint <- purrr::imap(newick_tbl_ls, bind_newick_str_comsie) %>%
    purrr::map(newick_to_phylo, with_fossil = FALSE)

  # Assert expectations are satisfied
  clades <- sort(names(phylo_ls_joint))
  if (!all(clades %in% clades_alive)) {
    stop("Clade assemblage different from expectations")
  }
  spp <- phylo_ls_joint %>% map(function(phy) phy$tip.label) %>%
    unlist(use.names = FALSE) %>% sort()
  if (!all(spp %in% spp_alive)) {
    stop("Species assemblage different from expectations")
  }

  if (!skip_daisie) {
    # DAISIE data
    nb_mainland_sp_present <- phylo_ls_joint %>%
      imap_lgl(function(phylo, mainland_sp) {
        mainland_sp %in% phylo$tip.label
      }) %>% sum()
    not_present <- 1000 - nb_mainland_sp_present

    colonists_ls <- phylo_ls_joint %>% imap(function(phylo, mainland_sp) {
      branching_times <- c(island_age, ape::branching.times(phylo))
      stac <- get_stac(phylo$tip.label, mainland_sp)
      return(list(
        "colonist_name" = mainland_sp,
        "branching_times" = branching_times,
        "stac" = stac,
        "all_colonisations" = all_colonisations[[mainland_sp]],
        "missing_species" = 0
      ))
    })
    datalist <- c(
      list(list("island_age" = island_age, "not_present" = not_present)),
      colonists_ls
    )
    saveRDS(datalist, glue::glue(path_to_fabrika_local(), "comsie_data/daisie/input/daisie_input_siga_{siga}_gamma_{gamma}_{i}_f_{f}.rds"))
  }

  if (!skip_ddd) {
    # DDD data
    brts_ls <- phylo_ls_joint %>% map(ape::branching.times)
    saveRDS(brts_ls, glue::glue(path_to_fabrika_local(), "comsie_data/ddd/input/ddd_input_siga_{siga}_gamma_{gamma}_{i}_f_{f}.rds"))
    readr::write_file(glue::glue(job_id, "\n\n"), file = "~/comsie_phylos_done.txt", append = TRUE)
  }
}
