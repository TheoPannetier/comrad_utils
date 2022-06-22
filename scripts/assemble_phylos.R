logbook <- read_logbook()

sigk <- 1
siga <- 0.1

args <- tidyr::expand_grid(sigk, siga)

args %>% pwalk(function(sigk, siga) {
  cat(siga, sigk, "\n")
  job_ids <- logbook %>% dplyr::filter(
    dplyr::near(competition_sd, siga),
    carrying_cap_sd == sigk,
    sampling_on_event == TRUE
  ) %>% pull(job_id)
  if (length(job_ids) != 100) {
    stop("wrong length")
  }
  filenames <- glue::glue("../fabrika/comrad_data/sims/comrad_sim_{job_ids}.csv")
  phylos <- filenames %>% map(read_comrad_tbl) %>% map(sim_to_phylo)
  names(phylos) <- job_ids
  saveRDS(phylos, glue::glue("../fabrika/comrad_data/phylos/comrad_phylos_sigk_{sigk}_siga_{siga}_full_1000.rds"))
})

args %>% pwalk(function(sigk, siga) {
  cat(siga, sigk, "\n")
  phylos <- readRDS(glue::glue("../fabrika/comrad_data/phylos/comrad_phylos_sigk_{sigk}_siga_{siga}_full.rds"))
  if (length(phylos) != 100) {
    stop("wrong length")
  }
})

sigk <- 3
phylos <- readRDS(glue::glue("../fabrika/comrad_data/phylos/comrad_phylos_sigk_{sigk}_siga_{siga}_full.rds"))
phylos %>% map_dfr(get_ltt_tbl, .id = "replicate") %>%
  ggplot(aes(x = time, y = N, group = replicate)) +
  geom_step() +
  theme_bw()


phylos <- readRDS("../fabrika/comrad_data/phylos/comrad_phylos_sigk_1_siga_0.1_full.rds")
job_ids <- logbook %>% dplyr::filter(
  batch_id == "b13391"
) %>% pull(job_id)
filenames <- glue::glue("../fabrika/comrad_data/sims/comrad_sim_{job_ids}.csv")
phylos2 <- filenames %>% map(read_comrad_tbl) %>% map(sim_to_phylo)

comrad_tbl <- read_comrad_tbl(filenames[1])
filenames[1]
names(phylos2) <- job_ids
phylos <- append(phylos, phylos2)
saveRDS(phylos, glue::glue("../fabrika/comrad_data/phylos/comrad_phylos_sigk_1_siga_0.1_full_1000.rds"))
