run_dd_ml_array <- function(
  func_name,
  task_id,
  job_id,
  logbook_file,
  time_subm
) {
  if (!fabrika::is_on_peregrine()) {
    stop("This function is only intended to be run on the Peregrine HPC.")
  }

  # All parameter values
  arg_tbl <- tidyr::expand_grid(
    sigk = 1:5,
    siga = seq(0.1, 1, 0.1),
    dd_model = dd_models_names(),
    i = 1:100
  )

  # Extract parameter values for this task
  task_id <- as.numeric(task_id)
  dd_model <- comrad::dd_models()[[arg_tbl$dd_model[task_id]]]
  siga <- arg_tbl$siga[task_id]
  sigk <- arg_tbl$sigk[task_id]
  i <- arg_tbl$i[task_id]

  # Additional metadata
  comrad_version <- packageVersion("comrad")
  ddd_version <- packageVersion("DDD")

  # Add entry to logbook
  cat(
    glue::glue("\n{job_id},{time_subm},NA,NA,{siga},{sigk},{dd_model$name},{i},{comrad_version},{ddd_version}\n\n"),
    file = logbook_file,
    append = TRUE
  )

  source(paste0("/data/p282688/fabrika/R/", func_name, ".R"))
  dd_ml_func <- eval(parse(text = func_name))
  dd_ml_func(
    siga = siga,
    sigk = sigk,
    dd_model = dd_model,
    i = i,
    job_id = job_id
  )
}
