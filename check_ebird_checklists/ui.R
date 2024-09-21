selected_checks <- c("ampm", "midnight", "high_number_species", "only_one_species", "same_count_all_species", "multi_day", "too_many_observers", "too_short_duration", "too_fast", "complete_media", "not_stationary", "not_traveling", "pelagic_too_long", "specialized_protocol", "no_observer_mismatch", "too_long_distance_land", "too_long_distance_offshore")

ui <- fluidPage(
  tags$head(includeHTML("google-analytics.Rhtml")),
  titlePanel("Check eBird Checklists"),
  sidebarLayout(
    sidebarPanel(
      fileInput("upload", "Choose .txt file",
                buttonLabel = "Upload...", multiple = TRUE, accept = ".txt"),
      hr(),
      numericInput('too_many_species', 'high_number_species threshold', value = 70),
      numericInput('too_many_observers', 'too_many_observers threshold', value = 20),
      numericInput('too_many_species_stationary', 'not_stationary threshold', value = 50),
      numericInput('too_long_land', 'too_long_distance_land threshold (km)', value = 20),
      numericInput('too_long_offshore', 'too_long_distance_offshore threshold (km)', value = 50),
      hr(),
      checkboxGroupInput("vars", "Select checks to include:",
                         choices = selected_checks,  # Choices will be set in the server
                         selected = selected_checks),
      hr(),
      downloadButton(
        "downloadData",
        label = "Download spreadsheet",
        class = NULL,
        icon = shiny::icon("download")
      )
    ),
    mainPanel(HTML("<p>This web app helps detect eBird checklists with potential checklist-level errors.<p>"),
              HTML("<p>First upload a .txt file containing eBird data, downloaded from <a href = 'https://ebird.org/data/download'>https://ebird.org/data/download.</a> Adjust the thresholds for different checks if needed, and then select which checks to run. Finally, click the download button and it will give you a .csv file with a list of potentially problematic checklists."),
              HTML("<p>The 'flags' column in this spreadsheet indicates the type of potential error, as listed below. Note: just because a checklist gets flagged by this algorithm does not mean that it necessarily has an error. Each flagged checklist needs to be individually assessed by a reviewer before any action is taken.<p>"),
              HTML("<p>For larger areas or longer time periods, a very large number of checklists might be flagged. Doing one month at a time for an individual county might be a reasonable approach. Also, in some cases, a single check might account for a large share of the flagged checklists. In our experience, this can happen with no_observer_mismatch. In this case, to reduce the burden, you can deselect the offending check. <p>"),
              HTML("<p><li>ampm: A frequent issue is for the time to be entered as AM instead of PM (i.e., in the middle of the night, rather than in the afternoon).</li>
                  <li>midnight: Starting a checklist at midnight should be quite uncommon, but it's often used to enter day-list or incorrectly add time on a historical/incidental list without time.</li>
                  <li>high_number_species: Checklists with an exceptionally high number of species (<b>X</b>, relative to your region) are generally indicative of multi-day lists or list-building.</li>
                  <li>only_one_species: A complete checklist with a single species is often indicative of incorrectly checking the 'Complete' button. Nocturnal checklists are not flagged, as it is quite common to only have one species when owling.</li>
                  <li>same_count_all_species: Most commonly occurs when the number of individuals for every species is 1, in which case it is possible that the correct selection should be X to mark presence.</li>
                  <li>multi_day: Checklists that span over two days are not valid.</li>
                  <li>too_many_observers: Checklists with more than <b>X</b> people could represent multi-party effort or some other issue.</li>
                  <li>too_short_duration: Checklists with a high number of species relative to the duration are suspicious.</li>
                  <li>too_fast: Catch protocol issues with incoherent duration and distance</li>
                  <li>complete_media: Checklists marked as complete with a media for each species often tend to rather be 'Incomplete' checklists.</li>
                  <li>not_stationary: Staionary checklists with more than <b>X</b> species could be traveling checklists.</li>
                  <li>not_traveling: Traveling checklists of less than 30 m should be entered as stationary.</li>
                  <li>pelagic_too_long: Checklists with the pelagic protocol are flagged if they are longer than 75 minutes.</li>
                  <li>specialized_protocol: You might want to check the use of non-standard protocols.</li>
                  <li>no_observer_mismatch: Flagged when a checklist is shared with a larger number of people than the indicated number of observers.</li>
                  <li>too_long_distance_land: A checklist of more than <b>X</b> km could be invalid based on distance covered. This check is only run on checklists from land or less than 2 miles offshore.</li>
                  <li>too_long_distance_offshore: Offshore checklists (more than 2 miles from land) over <b>X</b> km might be invalid based on distance covered. The acceptable distance for an offshore list can be longer than that for an onshore list.</li><br><br>
                   Code by Raphaël Nussbaumer and Linus Blomqvist (<a href = 'https://github.com/Zoziologie/Check-eBird-Checklist'>here)</a>. Web app by Linus Blomqvist. <br>
                   This app is a work in progress. For questions or suggestions please contact linus [dot] blomqvist [at] gmail [dot] com.<p>")
  )
)
)
