# Set working directory
setwd("~/Documents/Check-eBird-Checklist/check_ebird_checklists")

# Run app locally
library(shiny)
source("server.R")
source("ui.R")
shinyApp(ui, server)

# Deploy to shinyapps.io
library(rsconnect)
deployApp()
