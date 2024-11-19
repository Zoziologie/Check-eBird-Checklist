# Code to filter out specific observer IDs for check no_observer_mismatch

library(tidyverse)

check_df <- read_csv("~/Library/CloudStorage/Dropbox/Birding/ebird_R/outputs/chk_files/check_ebird_checklist_oct_2024_v2.csv")

check_clean <- check_df %>%
  filter(!(flags == "no_observer_mismatch" & str_detect(observer_id, "obsr729081|obsr4754607")))

write_csv(check_clean, "~/Library/CloudStorage/Dropbox/Birding/ebird_R/outputs/chk_files/check_ebird_checklist_oct_2024_v3.csv")
