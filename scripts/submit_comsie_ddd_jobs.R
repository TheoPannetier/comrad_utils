### DDD
args <- expand_grid(
  "siga" = c(0.091),
  "gamma" = c(5e-04),
  "replicate" = c(1:100)[-62],
  "params_i" = 1:4
)

commands <- glue::glue_data(args, "sbatch /data/p282688/fabrika/comsie_data/ddd/fit_ddd_to_comsie_hpc.bash {siga} {gamma} {replicate} {params_i}")

session <- ssh::ssh_connect(
  "p282688@peregrine.hpc.rug.nl"
)

ssh::ssh_exec_wait(
  session = session,
  command = commands
)

ssh::ssh_disconnect(
  session = session
)

### CR
args <- expand_grid(
  "siga" = c(0.091),
  "gamma" = c(1e-03, 1e-02),
  "replicate" = 1:100,
  "params_i" = 1:4
)

commands <- glue::glue_data(args, "sbatch /data/p282688/fabrika/comsie_data/ddd/fit_cr_to_comsie_hpc.bash {siga} {gamma} {replicate} {params_i}")

session <- ssh::ssh_connect(
  "p282688@peregrine.hpc.rug.nl"
)

ssh::ssh_exec_wait(
  session = session,
  command = commands
)

ssh::ssh_disconnect(
  session = session
)

# DAISIE
args <- expand_grid(
  "siga" = c(0.369),
  "gamma" = c(1e-02),
  "replicate" = 1:100,
  "daisie_version" = c("IW"),
  "ddmodel" = 11,
  "params_i" = 1
)

commands <- glue::glue_data(args, "sbatch /data/p282688/fabrika/comsie_data/daisie/fit_daisie_to_comsie_hpc_short.bash {siga} {gamma} {replicate} {daisie_version} {ddmodel} {params_i}")

session <- ssh::ssh_connect(
  "p282688@peregrine.hpc.rug.nl"
)

ssh::ssh_exec_wait(
  session = session,
  command = commands[2:29]
)

ssh::ssh_disconnect(
  session = session
)

cat /data/$USER/fabrika/comsie_data/daisie/logs/
