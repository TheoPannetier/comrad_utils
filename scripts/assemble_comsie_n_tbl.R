options(dplyr.summarise.inform = FALSE, readr.show_progress = FALSE)

read_diversity <- function(job_id, siga, gamma, i, f) {
  #cat(job_id, "\n")

  # Load tbl
  comsie_tbl <- read_comsie_tbl(path_to_sim_hd(job_id, pkg = "comsie"))

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

  comsie_tbl <- split_founder_col(comsie_tbl)

  nb_clades <- comsie_tbl %>%
    dplyr::filter(near(t, island_age, tol = 0.000001)) %>%
    pull(mainland_sp) %>% unique() %>% length()

  nb_species <- comsie_tbl %>%
    dplyr::filter(near(t, island_age, tol = 0.000001)) %>%
    pull(species) %>% unique() %>% length()

  max_sp_in_clade <- comsie_tbl %>%
    dplyr::filter(near(t, island_age, tol = 0.000001)) %>%
    group_by(t, mainland_sp, immig_nb) %>%
    summarise("N" = n_distinct(species)) %>%
    pull(N) %>% max()

  n_tbl <- tibble::tibble(
    "job_id" = job_id,
    "siga" = siga,
    "gamma" = gamma,
    "replicate" = i,
    "f" = f,
    "nb_clades" = nb_clades,
    "nb_species" = nb_species,
    "max_sp_in_clade" = max_sp_in_clade
  )
  return(n_tbl)
}

logbook <- read_logbook(pkg = "comsie")

args <- expand_grid(
  "siga" = siga_vec_comsie()[c(1)],
  "gamma" =  c(0),
  #"siga" = siga_vec_comsie()[c(9)],
  #"gamma" =  c(1e-03, 1e-04),
  "f" = c(1)
) %>%
  dplyr::filter(
    !(siga %in% siga_vec_comsie()[c(1, 9)] & gamma %in% c(1e-04, 1e-03))
  )

 siga <- 0.091
 gamma <- 1e-03
 f <- 1
 i <- 1

args %>%
  pwalk(function(siga, gamma, f) {
    cat(siga, gamma, f, "\n")

    job_ids <- logbook %>%
      dplyr::filter(
        near(competition_sd, siga),
        near(immigration_rate, gamma)
      ) %>% pull(job_id)

    new_rows <- job_ids %>% imap_dfr(function(job_id, i) {
      #if (i < 17) return()
      cat(i, "/", length(job_ids), "\n")
      rows <- read_diversity(
        job_id, siga, gamma, i, f
      )
      return(rows)
    })
    n_tbl <- readRDS("/Volumes/morozilka/comsie_data/diversity/comsie_n_tbl.rds")
    n_tbl <- bind_rows(n_tbl, new_rows)
    saveRDS(n_tbl, "/Volumes/morozilka/comsie_data/diversity/comsie_n_tbl.rds")
  })
beepr::beep(1)

n_tbl2 <- readRDS("/Volumes/morozilka/comsie_data/diversity/comsie_n_tbl.rds")
n_tbl2 <- bind_rows(n_tbl2, n_tbl)
saveRDS(n_tbl2, "/Volumes/morozilka/comsie_data/diversity/comsie_n_tbl.rds")

ov <- n_tbl %>% group_by(
 siga, gamma, f
) %>% count()
