ui <- fluidPage(
  tags$head(includeHTML("google-analytics.Rhtml")),
  titlePanel("Check eBird Checklists"),
  sidebarLayout(
    sidebarPanel(
      fileInput("upload", "Choose .txt file",
                buttonLabel = "Upload...", multiple = TRUE, accept = ".txt"),
      hr(),
      numericInput('too_many_species_stationary', 'not_stationary threshold', value = 50),
      numericInput('too_many_species', 'high_number_species threshold', value = 70),
      numericInput('too_long_distance', 'too_long_distance threshold (km)', value = 20),
      numericInput('too_many_observers', 'too_many_observers threshold', value = 20),
      hr(),
      downloadButton(
        "downloadData",
        label = "Download spreadsheet",
        class = NULL,
        icon = shiny::icon("download")
      )
    ),
    mainPanel(HTML("<p>This web app helps detect eBird checklists with potential checklist-level errors.<p>"),
              HTML("<p>First upload a .txt file containing eBird data, downloaded from <a href = 'https://ebird.org/data/download'>https://ebird.org/data/download.</a> Adjust the thresholds for different checks if needed. Finally, click the download button and it will give you a .csv file with a list of potentially problematic checklists."),
              HTML("<p>Columns 11 through 24 in this spreadsheet indicate the type of potential error, as listed below. Note: just because a checklist gets flagged by this algorithm does not mean that it necessarily has an error. Each flagged checklist needs to be individually assessed by a reviewer before any action is taken. <br>
                  <li>ampm: A frequent issue is for the time to be entered as AM instead of PM (i.e., in the middle of the night, rather than in the afternoon).</li>
                  <li>midnight: Starting a checklist at midnight should be quite uncommon, but it's often used to enter day-list or incorrectly add time on a historical/incidental list without time.</li>
                  <li>multi_day: Checklists that span over two days are not valid.</li>
                  <li>not_traveling: Traveling checklists of less than 30 m should be entered as stationary.</li>
                  <li>not_stationary: Staionary checklists with more than <b>X</b> species could be traveling checklists.</li>
                  <li>high_number_species: Checklists with an exceptionally high number of species (<b>X</b>, relative to your region) are generally indicative of multi-day lists or list-building.</li>
                  <li>only_one_species: A complete checklist with a single species is often indicative of incorrectly checking the 'Complete' button.</li>
                  <li>too_long_distance: A checklist of more than <b>X</b> km could be invalid based on distance covered.</li>
                  <li>too_short_duration: Checklists with a high number of species relative to the duration are suspicious.</li>
                  <li>too_fast: Catch protocol issues with incoherent duration and distance</li>
                  <li>complete_media: Checklists marked as complete with a media for each species often tend to rather be 'Incomplete' checklists.</li>
                  <li>too_many_observers: Checklists with more than <b>X</b> people could represent multi-party effort or some other issue.</li>
                  <li>specialized_protocol: You might want to check the use of non-standard protocols.</li><br><br>
                   Code by Raphaël Nussbaumer and Linus Blomqvist (<a href = 'https://github.com/Zoziologie/Check-eBird-Checklist'>here)</a>. Web app by Linus Blomqvist. <br>
                   This app is a work in progress. For questions or suggestions please contact linus [dot] blomqvist [at] gmail [dot] com.<p>")
  )
)
)
