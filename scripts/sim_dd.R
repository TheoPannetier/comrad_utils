siga <- seq(0.1, 1, 0.1)
siga[[3]]
siga[[3]] == 0.3
all.equal()

sigk <- 1:3
dd_model <- list(
  dd_model_lc(),
  dd_model_ll(),
  dd_model_lx(),
  dd_model_xc(),
  dd_model_xl(),
  dd_model_xx()
)

args <- tidyr::expand_grid(sigk, siga, dd_model)
devtools::load_all("../comrad/")
siga <- 1
sigk <- 1
dd_model <- dd_model_xc()

logbook <- read_logbook()
args[58:180, ] %>% pwalk(function(sigk, siga, dd_model) {
  cat(glue::glue("siga = {siga}, sigk = {sigk}, dd_model = {dd_model$name}\n\n"))
  # Read MLE params for the model
  ml <- read_mle_tbl(siga, sigk, sampling_on_event = TRUE) %>%
    filter_aic_best() %>%
    dplyr::rename("ddmod" = "dd_model") # resolve ambiguity in var names
  params <- ml %>% dplyr::filter(ddmod == dd_model$name) %>%
    select(starts_with("ml_")) %>%
    unlist()
  names(params) <- substr(names(params), 4, 1000)
  if (dd_model$name %in% c("lc", "xc")) {
    params <- params[-4] # rm alpha
  }
  if (any(length(siga) != 1, length(sigk) != 1)) {
    stop("args don't have length 1")
  }
  nb_gens <- logbook %>%
    dplyr::filter(near(competition_sd, siga), carrying_cap_sd == sigk, sampling_on_event == TRUE) %>%
    dplyr::pull(nb_gens) %>%
    unique()
  if (length(nb_gens) == 0) {
    stop("No match logbook")
  }
  if (length(nb_gens) > 1) {
    stop("More than 1 nb_gens found in logbook.")
  }
  phylos <- map(1:100, function(i) {
    cat("Tree", i, "/", 100, "\n")
    simulate_dd_phylo(
      params = params,
      nb_gens = nb_gens,
      dd_model = dd_model
      )
  })
  outputfile <- glue::glue(
    "../fabrika/comrad_data/phylos/dd_phylos_{dd_model$name}_sigk_{sigk}_siga_{siga}.rds"
  )
  saveRDS(phylos, outputfile)
})
