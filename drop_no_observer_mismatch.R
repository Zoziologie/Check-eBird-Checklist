# Code to filter out specific observer IDs for check no_observer_mismatch

# Load packages
library(tidyverse)

# Set parameters
date <- "april_2025"

id_drop <- "obsr729081|obsr4754607|obsr656332|obsr1198534|obsr190329|obsr2070027|obsr4916683|obsr4912817|obsr4584609"

# Execute
check_df <- read_csv(str_c("~/Library/CloudStorage/Dropbox/Birding/ebird_R/outputs/chk_files/check_ebird_checklist_", date, ".csv", sep = ""))

check_clean <- check_df %>%
  filter(!(flags == "no_observer_mismatch" & str_detect(observer_id, id_drop)))

# Save
write_csv(check_clean, str_c("~/Library/CloudStorage/Dropbox/Birding/ebird_R/outputs/chk_files/drop_obs_mismatch/check_ebird_checklist_", date, ".csv", sep = ""))
