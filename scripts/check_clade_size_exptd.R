logbook <- read_csv("comsie_data/daisie/logs/logbook_daisie_ml.csv")

logbook <- read_logbook(
  pkg = "comsie"
) %>%
  dplyr::filter(
    immigration_rate == 1e-03,
    competition_sd %in% c(0.369)
  ) %>%
  #group_by(competition_sd) %>%
  slice_head()

comsie_tbl %>%
  dplyr::filter(t == max(t)) %>%
  dplyr::pull(species) %>%
  unique() %>% length()
# 22 spp

comsie_tbl %>%
  dplyr::filter(t == max(t)) %>%
  dplyr::pull(founder) %>%
  unique() %>% length()

job_id <- 23182473


# Quality control
args <- expand_grid(
  "siga" = c(0.091),
  "gamma" = c(1e-03),
  "i" = 1:100
)

nb_sp_tbl <- args %>% pmap_dfr(function(siga, gamma, i) {
  cat(gamma, siga, i, "\n")
  daisie_data <- readRDS(glue::glue(
    "comsie_data/daisie/input/daisie_input_siga_{siga}_gamma_{gamma}_{i}_f_0.5.rds"
  ))
  nb_clades <- length(daisie_data) - 1
  nb_spp <- sum(daisie_data[-1] %>% map_dbl(function(clade) length(clade$branching_times) - 1))
  tibble::tibble(
    "gamma" = gamma,
    "siga" = siga,
    "i" = i,
    "nb_spp" = nb_spp,
    "nb_clades" = nb_clades
  )
  })

comm_size_tbl <- readRDS("/Volumes/morozilka/comsie_data/diversity/comm_size_daisie.rds") %>%
  dplyr::rename(
    "gamma" = immigration_rate,
    "siga" = competition_sd,
    "exptd_nb_clades" = nb_clades,
    "exptd_nb_sp" = nb_sp
  )

nb_sp_tbl <- nb_sp_tbl %>%
  left_join(comm_size_tbl)

subset <- nb_sp_tbl %>% dplyr::filter(
  gamma == 0.001,
  siga == 0.369
)
