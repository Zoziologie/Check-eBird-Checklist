ui <- fluidPage(
  titlePanel("Check eBird Checklists"),
  sidebarLayout(
    sidebarPanel(
      fileInput("upload", "Choose .txt file",
                buttonLabel = "Upload...", multiple = TRUE, accept = ".txt"),
      hr(),
      downloadButton(
        "downloadData",
        label = "Download spreadsheet",
        class = NULL,
        icon = shiny::icon("download")
      )
    ),
    mainPanel(p("This web app implements code from Raphaël Nussbaumer (https://github.com/Zoziologie/Check-eBird-Checklist) to detect eBird checklists with potential errors."),
              p("First upload a .txt file containing eBird data, downloaded from https://ebird.org/data/download. Once that's uploaded, click the download link and it will give you a .csv file with a list of problematic checklists.")
  )
)
)
