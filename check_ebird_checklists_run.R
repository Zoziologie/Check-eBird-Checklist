# Check ebird checklists run script
# Author: Linus Blomqvist

# Source function
source("check_ebird_checklists_fcn.R")

# Specify text file (put path and file name within quotation marks)
# This is the file you would download from https://ebird.org/data/download
# When downloading this file you can specify area, date range, etc
txt_file <- ""

# Run function
chk <- create_chk(txt_file)

# Export as xlsx (change name manually within quotation marks)
write_xlsx(chk, "")
