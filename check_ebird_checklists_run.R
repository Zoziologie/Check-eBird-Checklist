# Check ebird checklists run script
# Author: Linus Blomqvist

# Source function
source("check_ebird_checklists/check_ebird_checklists_fcn.R")

# Specify text file (put path and file name within quotation marks)
# This is the file you would download from https://ebird.org/data/download
# When downloading this file you can specify area, date range, etc
txt_file <- "ebd_US-CA-083_202401_202401_relJan-2024.txt"

# function arguments: txt_file, too_many_species, too_many_species_stationary, too_long_distance, too_many_observers
# Run function
chk <- create_chk(txt_file, 70, 50, 20, 30)

# Export as xlsx (change name manually within quotation marks)
write_xlsx(chk, "ebird_checklist_chk_dec")
