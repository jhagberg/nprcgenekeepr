library(shiny)
library(shinyBS)
if (!require("DT"))
  install.packages("DT")
library(DT)
source("../application/uitpInput.R")
#source("../application/uitpErrorTab.R")
source("../application/uitpPedigreeBrowser.R")
source("../application/uitpGeneticValueAnalysis.R")
source("../application/uitpSummaryStatistics.R")
source("../application/uitpBreedingGroupFormation.R")
source("../application/uitpPyramidPlot.R")
source("../application/uitpGvAndBgDesc.R")
if (getSiteInfo()$center == "ONPRC") {
  source("../application/uitpOripReporting.R")
  navbarPageArgs <- list(
    title = "Genetic Management Tools",
    uitpInput,
#    uitpErrorTab,
    uitpPedigreeBrowser,
    uitpGeneticValueAnalysis,
    uitpSummaryStatistics,
    uitpBreedingGroupFormation,
    uitpOripReporting,
    uitpPyramidPlot,
    uitpGvAndBgDesc,
    id = "tab_pages"
  )
} else {
  navbarPageArgs <- list(
    title = "Genetic Management Tools",
    uitpInput,
#    uitpErrorTab,
    uitpPedigreeBrowser,
    uitpGeneticValueAnalysis,
    uitpSummaryStatistics,
    uitpBreedingGroupFormation,
    uitpPyramidPlot,
    uitpGvAndBgDesc,
    id = "tab_pages"
  )
}

shinyUI(tagList(
  tags$head(tags$style(src = "app_style.js")),
  #tags$head(tags$script(src = "add_tabs.js")),
  # Important! : 'Freshly baked' tabs first enter here.
  # uiOutput("navbarPage", style = "display: none;"),
  # End Important

  do.call(navbarPage, navbarPageArgs)

  ))
