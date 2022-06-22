logbook <- read_logbook(pkg = "comsie") %>%
  dplyr::filter(
  #comrad_version == "[1] ‘0.3.1’",
  #near(competition_sd, 0.091)#,
  immigration_rate <= 1e-02,
  status %in% c("COMPLETED"),
  !is_sim_csv_on_hd(job_id, pkg = "comsie")
  )

rm_sim_csv_hpc(logbook$job_id, pkg = "comsie")
rm_logbook_entries(logbook$job_id, pkg = "comsie")

commands <- glue::glue("cat {path_to_log_hpc(logbook$job_id, pkg = 'comsie')}")
commands[3]

#23184785 #13
#23184864 #15
#23184904 #16
#23185029 #18
#23185143 #22
#23185238 #23


job_ids <- logbook$job_id
complete_logbook_entries(job_ids[1:343], pkg = "comsie", vars = c("status"))
beepr::beep(1)

"23183845"
"23183922"

logbook %>% group_by(competition_sd, immigration_rate) %>%
  count()

logbook$status[logbook$job_id %in% c(23115994, 23115993)]  <- "COMPLETED"

path_to_log_hpc("23122524", pkg = "comsie")

rm_logbook_entries(archive$job_id, pkg = "comsie")

on_hd <- job_ids[is_sim_csv_on_hd(job_ids, pkg = "comsie")]

#dplyr::filter(batch_id %in% c("b47053", "b54295", "b35244", "b38462", "b62566", "b63733", "b88382"))

ns <- logbook %>%
  group_by(immigration_rate, competition_sd) %>%
  count()


subset <- logbook %>% dplyr::filter(
  status %in% c("pending_check")
)

job_ids <- subset$job_id
sim_csv <- job_ids %>% path_to_sim_hpc(pkg = "comsie")
sim_log <- job_ids %>% path_to_log_hpc(pkg = "comsie")
sum(logbook$csv_size[1:54])

job_ids <- logbook$job_id

to_downl <- job_ids[!job_ids %>% is_sim_csv_on_hd(pkg = "comsie")]
#to_downl2 <- to_downl[!to_downl %>% is_sim_csv_on_hd(pkg = "comsie")]
to_downl %>% download_sim_csv_hpc(pkg = "comsie", to = "hd")
beepr::beep(1)

log_to_downl <- job_ids[!is_sim_log_on_hd(job_ids, pkg = "comsie")]
log_to_downl %>% download_sim_log_hpc(pkg = "comsie", to = "hd")
beepr::beep(1)
downloaded <- to_downl[is_sim_csv_on_local(to_downl, pkg = "comsie")]

copy_sim_csv_to_hd(downloaded, pkg = "comsie")

fs::file_delete(
  path_to_sim_local(downloaded[is_sim_csv_on_hd(downloaded, pkg = "comsie")], pkg = "comsie")
)
