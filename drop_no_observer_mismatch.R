# Code to filter out specific observer IDs for check no_observer_mismatch

library(tidyverse)

check_df <- read_csv("~/Library/CloudStorage/Dropbox/Birding/ebird_R/outputs/chk_files/check_ebird_checklist_march_2025.csv")

check_clean <- check_df %>%
  filter(!(flags == "no_observer_mismatch" & str_detect(observer_id, "obsr729081|obsr4754607|obsr656332|obsr1198534|obsr190329|obsr2070027|obsr4916683|obsr4912817|obsr4584609")))

write_csv(check_clean, "~/Library/CloudStorage/Dropbox/Birding/ebird_R/outputs/chk_files/drop_obs_mismatch/check_ebird_checklist_march_2025.csv")
