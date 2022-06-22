# Already run jobs
logbook <- readr::read_csv("comsie_data/daisie/logs/logbook_daisie_ml.csv") %>%
  dplyr::rename(siga = competition_sd, gamma = immigration_rate, i = replicate) %>%
  dplyr::filter(status %in% c("COMPLETED", "CANCELLED,TIMEOUT"))

args <- subset %>%
  dplyr::filter(status == "OUT_OF_MEMORY") %>%
  transmute(
  "siga" = competition_sd,
  "gamma" = immigration_rate,
  "i" = replicate,
  "f" = f,
  "ddmodel" = ddmodel,
  "params_i" = params_i
  )

args <- tidyr::expand_grid(
  "siga" = c(0.369, 0.091),
  "gamma" = c(1e-03),
  "i" = 1:100,
  "f" = 1,
  "ddmodel" = 11,
  "params_i" = 1
) #%>%
  # Rm already run jobs
  anti_join(logbook)

# IW !!!!!!!!!!!!!
commands <- args %>% glue::glue_data(
  "sbatch /data/p282688/fabrika/comsie_data/daisie/fit_daisie_IW_to_comsie_hpc.bash {siga} {gamma} {i} {f} {ddmodel} {params_i}"
)
session <- ssh::ssh_connect(
  "p282688@peregrine.hpc.rug.nl"
)
ssh::ssh_exec_wait(
  session = session,
  command = commands[2:200]
)
ssh::ssh_disconnect(
  session = session
)

# CS !!!!!!!!!!!!!
commands <- args %>% glue::glue_data(
  "sbatch /data/p282688/fabrika/comsie_data/daisie/fit_daisie_CS_to_comsie_hpc.bash {siga} {gamma} {i} {f} {ddmodel} {params_i}"
)
session <- ssh::ssh_connect(
  "p282688@peregrine.hpc.rug.nl"
)
ssh::ssh_exec_wait(
  session = session,
  command = commands[1:200]
)
ssh::ssh_disconnect(
  session = session
)
