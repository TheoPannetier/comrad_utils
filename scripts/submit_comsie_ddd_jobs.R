

### DDD
args <- expand_grid(
  "siga" = c(0.369),
  "gamma" = c(5e-04, 1e-02),
  "replicate" = c(1:100),
  "f" = 0.5,
  "params_i" = 1:4
)

commands <- glue::glue_data(args, "sbatch /data/p282688/fabrika/comsie_data/ddd/fit_ddd_to_comsie_hpc.bash {siga} {gamma} {replicate} {f} {params_i}")

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
  "siga" = c(0.369),
  "gamma" = c(5e-04, 1e-02),
  "replicate" = c(1:100),
  "f" = 1,
  "params_i" = 1:4
)

commands <- glue::glue_data(args, "sbatch /data/p282688/fabrika/comsie_data/ddd/fit_cr_to_comsie_hpc.bash {siga} {gamma} {replicate} {f} {params_i}")

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
