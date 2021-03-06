uitpPedigreeBrowser <-
  tabPanel(
    "Pedigree Browser",
    div(
    div(
      # Main Panel
      div(
        style = "float: left; width: 500px; padding: 1px;",
        helpText(paste0("IDs of selected focal animals may be manually ",
                        "entered here if analysis of all individuals is ",
                        "not needed. IDs may be pasted from Excel or you ",
                        "can browse for and select a file containing the list ",
                        "of focal animals.")),
      tags$textarea(id = "focalAnimalIds", rows = 5, cols = 60, ""),
      fileInput("focalAnimalUpdate", "Choose CSV file with focal animals",
                multiple = FALSE,
                accept = c("text/csv",
                           "text/comma-separated-values,text/plain",
                           ".csv")),
      popify(actionButton("specifyFocalAnimal", label = "Update Focal Animals"),
             paste0("Read selected file of focal animals or list of animals ",
             "entered and update the table below")),
      popify(checkboxInput("clearFocalAnimals", label = "Clear Focal Animals",
                           value = FALSE),
             paste0("Focal animal list is to be cleared as well using a file ",
                    "with no animal IDs. (Files are not affected).")),
      helpText(paste0("The search field below will search all columns for ",
                      "matches to any text or number entered."),
               style = "color:blue")
    #   div(
    #     # Right Side Panel
    #     style = paste("margin-left: 550px;",
    #       "width: 500px; height: 180px; padding: 10px;",
    #       "border: 1px solid lightgray; background-color: #EDEDED;",
    #       "margin-left: 560px; margin-top: 3px; margin-bottom: 3px;",
    #       "border-radius: 25px; box-shadow: 0 0 5px 2px #888"
    #     )#,
    #     #includeHTML("../extdata/pedigree_browser.html")
    #   )
    )
    ),
    # div(
    # conditionalPanel(
    #   condition = "input$focalAnimalUpdate",
    #   div(popify(checkboxInput("clearFocalAnimals",
    #                            label = paste0("Clear focal Animals"),
    #                            width = "150%",
    #                            value = FALSE)
    #   )))),
    div(
    # Right Side Panel
         style = paste("margin-left: 550px;",
          "width: 500px; height: 180px; padding: 10px"),
      popify(checkboxInput("uid", label = "Display Unknown IDs",
                        value = TRUE),
             paste0("Unknown IDs, beginning with a capital U, are created ",
                    "by the application for all animals with only one  ",
                    "parent.")),
      popify(checkboxInput("trim",
                    label = "Trim pedigree based on focal animals",
                    value = FALSE),
             paste0("Trim the pedigree to include only relatives of the focal ",
                    "animals provided.")),
      popify(downloadButton("downloadPedigree", "Export"),
             paste0("Export the pedigree into a CSV (comma separted value)  ",
                    "file.")),
      helpText("A population must be defined before proceeding
               to the Genetic Value Analysis.", style = "color:blue")
    ),
      DT::dataTableOutput("pedigree")
    ))

