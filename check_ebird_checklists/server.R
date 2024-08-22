# Source function
source("check_ebird_checklists_fcn.R")

options(shiny.maxRequestSize=100*1024^2)

server <- function(input, output) {

  datasetInput <- reactive({
    req(input$upload)
    # input$file1 will be NULL initially. After the user selects
    # and uploads a file, it will be a data frame with 'name',
    # 'size', 'type', and 'datapath' columns. The 'datapath'
    # column will contain the local filenames where the data can
    # be found.
    inFile <- input$upload

    if (is.null(inFile))
      return(NULL)

    create_chk(inFile$datapath, input$too_many_species, input$too_many_species_stationary, input$too_long_distance, input$too_many_observers) %>%
      select(url:number_species, all_of(input$vars)) %>%
      mutate(dubious = apply(.[, 10:ncol(.)], 1, any)) %>%
      filter(dubious == TRUE) %>%
      select(-dubious)
  })

  output$contents <- renderDataTable({
    datasetInput()
  })

  output$downloadData <- downloadHandler(
    filename = "check_ebird_checklist.csv",
    content = function(file) {
      write.csv(datasetInput(), file, row.names = FALSE)
    }
  )
}
