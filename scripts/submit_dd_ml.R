siga <- 0.1
sigk <- 1
dd_model <- dd_model_names()
args <- tidyr::expand_grid(sigk, siga, dd_model)

commands <- glue::glue_data(args,"sbatch /data/p282688/fabrika/bash/run_dd_ml.bash {siga} {sigk} {dd_model}")

session <- ssh::ssh_connect("p282688@peregrine.hpc.rug.nl")
ssh::ssh_exec_wait(
  session = session,
  command = commands
)
ssh::ssh_disconnect(session = session)
