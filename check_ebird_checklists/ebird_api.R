# Tool to download checklists from eBird API
# Author: Linus Blomqvist

# Load packages
library(rebird)
library(devtools)

#
devtools::install_github("RichardLitt/rebird@15608dfca8a3c9475254441798d304b26c136633")

select_loc <- "US-CA-083"


test <- ebirdchecklistfeed(loc = "US-CA-083", date = "2020-03-24", max = 5)

test2 <- ebirdchecklist("S66188875")
