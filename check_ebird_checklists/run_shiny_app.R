# Set working directory
setwd("/Users/linusblomqvist/Library/CloudStorage/Dropbox/Birding/ebird_R/Check-eBird-Checklist/check_ebird_checklists")

# Run app locally
library(shiny)
source("server.R")
source("ui.R")
shinyApp(ui, server)

# Deploy to shinyapps.io
library(rsconnect)
deployApp()
