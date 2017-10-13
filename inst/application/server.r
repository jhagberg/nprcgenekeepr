`%then%` <- shiny:::`%OR%`
library(futile.logger)
shinyServer(function(input, output, session) {
  nprcmanagerLog <- paste0(getSiteInfo()$homeDir, "nprcmanager.log")
  flog.logger("nprcmanager", INFO,
              appender = appender.file(nprcmanagerLog))

  #############################################################################
  # Functions for handling initial pedigree upload and QC

  # Load/QC the pedigree once a file has been specified
  sb <- reactive({
    input$getData # This button starts it all
    if (input$debugger) {
      flog.threshold(DEBUG, name = "nprcmanager")
    } else {
      flog.threshold(INFO, name = "nprcmanager")
    }

    isolate({
      flog.debug(paste0("1st. input$dataSource: ", input$dataSource,
                         "; input$sepOne: ", input$sepOne,
                         "; input$sepTwo: ", input$sepTwo,
                         "; input$sepThree: ", input$sepThree),
                  name = "nprcmanager")
      if (input$dataSource == "pedFile") {
        sep <- input$sepOne
        pedigreeFile <- input$pedigreeFileOne
        flog.debug(paste0("pedigreeFileOne - pedigreeFile$name: ",
                          pedigreeFile$name,
                          "; pedigreeFile$datapath: ", pedigreeFile$datapath),
                   name = "nprcmanager")
      } else if (input$dataSource == "commonPedGenoFile") {
        sep <- input$sepTwo
        pedigreeFile <- input$pedigreeFileTwo
        flog.debug(paste0("pedigreeFileTwo - pedigreeFile$name: ",
                          pedigreeFile$name,
                          "; pedigreeFile$datapath: ", pedigreeFile$datapath),
                   name = "nprcmanager")
      } else if (input$dataSource == "separatePedGenoFile") {
        sep <- input$sepThree
        pedigreeFile <- input$pedigreeFileThree
        genotypeFile <- input$genotypeFile
        flog.debug(paste0("pedigreeFileThree - pedigreeFile$name: ",
                          pedigreeFile$name, "; ",
                          "; pedigreeFile$datapath: ", pedigreeFile$datapath,
                          "; genotypeFile$name: ", genotypeFile$name,
                          "; genotypeFile$datapath: ", genotypeFile$datapath),
                   name = "nprcmanager")
      } else if (input$dataSource == "breeders") {
        sep <- input$sepFour
        pedigreeFile <- input$breederFile
        flog.debug(paste0("breederFile - pedigreeFile$name: ",
                          pedigreeFile$name, "; ",
                          "pedigreeFile$datapath: ", pedigreeFile$datapath),
                   name = "nprcmanager")
      } else {
        stop("Data source was not defined.")
      }
      flog.debug("sep: %s", sep, name = "nprcmanager")
      minParentAge <- renderText(input$minParentAge)
      flog.debug(paste0("minParentAge: ",
                        input$minParentAge),
                 name = "nprcmanager")
      minParentAge <- tryCatch(as.numeric(input$minParentAge),
                               warning = function(cond) {
                                 return(NULL)
                               },
                               error = function(cond) {
                                 return(NULL)
                               }
      )
      flog.debug(paste0("minParentAge: ", minParentAge),
                 name = "nprcmanager")

      # pedigreeFile and breederFile will be NULL initially.
      # After the user selects a file, it will be a filepath.
      if (is.null(pedigreeFile)) {
        return(NULL)
      }
      flog.debug(paste0("before read.csv input$dataSource: ", input$dataSource),
                 name = "nprcmanager")
      # Load pedigree table
      if (input$dataSource == "breeders") {
        flog.debug(paste0("before getBreederPed: ", pedigreeFile$name),
                   name = "nprcmanager")
        d <- getBreederPed(pedigreeFile$datapath, sep = sep)
        flog.debug(paste0("after getBreederPed: ", pedigreeFile$name,
                           "; contents rows: ", nrow(d),
                          ", columns: ", ncol(d), "; col names: '",
                          paste(names(d), collapse = "', '"), "'", sep = ""),
                   name = "nprcmanager")
      } else {
        d <- read.csv(pedigreeFile$datapath,
                      header = TRUE,
                      sep = sep,
                      stringsAsFactors = FALSE,
                      na.strings = c("", "NA"),
                      check.names = FALSE)
        flog.debug(paste0("after read.csv pedigreeFile$name: ",
                          pedigreeFile$name,
                          "; contents rows: ", nrow(d),
                          ", columns: ", ncol(d), "; col names: '",
                          paste(names(d), collapse = "', '"), "'", sep = ""),
                   name = "nprcmanager")
      }

      if (is.null(input$dataSource)) {
        stop("Did not expect input$dataSource to be NULL")
      } else if (input$dataSource == "separatePedGenoFile") {
        # Load pedigree table
        flog.debug(paste0("before read.csv genotypeFile$datapath: ",
                          genotypeFile$datapath,
                          "; contents rows: ", nrow(d),
                          ", columns: ", ncol(d), "; col names: '",
                          paste(names(d), collapse = "', '"), "'", sep = ""),
                   name = "nprcmanager")
        genotype <- read.csv(genotypeFile$datapath,
                             header = TRUE,
                             sep = sep,
                             stringsAsFactors = FALSE,
                             na.strings = c("", "NA"),
                             check.names = FALSE)
        flog.debug(paste0("genotype$name: ", genotype$name,
                          "; contents rows: ", nrow(genotype),
                          ", columns: ", ncol(genotype), "; col names: '",
                          paste(names(genotype), collapse = "', '"), "'",
                          sep = ""),
                   name = "nprcmanager")
        genotype <- tryCatch(checkGenotypeFile(genotype),
                             warning = function(cond) {
                               return(NULL)
                             },
                             error = function(cond) {
                               return(NULL)
                             },
                             finally = {
                               flog.debug(paste0("   tryCatch checkGenotype ",
                                                 "file. ", geterrmessage()),
                                          name = "nprcmanager")
                             }
        )
        d <- addGenotype(d, genotype)
        flog.debug(paste0("After addGenotype - genotypeFile$name: ",
                   genotypeFile$name,
                   "; contents rows: ", nrow(d),
                   ", columns: ", ncol(d), "; col names: '",
                   paste(names(d), collapse = "', '"), "'", sep = ""),
                   name = "nprcmanager")
      } else {
        flog.debug(paste0("Setting genotype to NULL."),
            name = "nprcmanager")
        genotype <- NULL
      }
      flog.debug(paste0("Data files may have been read.\n",
                 "contents rows: ", nrow(d),
                 ", columns: ", ncol(d), "; col names: '",
                 paste(names(d), collapse = "', '"), "'", sep = ""),
                 name = "nprcmanager")

      if (!is.null(minParentAge)) {
        flog.debug(paste0("Before qcStudbook.\n",
                   "contents rows: ", nrow(d),
                   ", columns: ", ncol(d), "; col names: '",
                   paste(names(d), collapse = "', '"), "'", sep = ""),
                   name = "nprcmanager")
        d <- tryCatch(qcStudbook(d, minParentAge),
                      warning = function(cond) {
                        return(NULL)
                      },
                      error = function(cond) {
                        return(NULL)
                      }
        )
        flog.debug(paste0("After qcStudbook.\n",
                   "contents rows: ", nrow(d),
                   ", columns: ", ncol(d), "; col names: '",
                   paste(names(d), collapse = "', '"), "'", sep = ""),
                   name = "nprcmanager")

      }
      flog.debug(paste0("before validate()."),
          name = "nprcmanager")
   validate(need(!is.null(minParentAge),
                  paste0("   Error uploading data. ",
                         geterrmessage())) %then%
               need(!is.null(d), paste0("   Error uploading data. ",
                                        geterrmessage()))
    )
    if (!is.null(d)) {
      updateTabsetPanel(session, "tab_pages", selected = "Pedigree Browser")
    }
    flog.debug(paste0("After validate(); nrow(d) = ", nrow(d),
               "; ncol(d): ", ncol(d)), name = "nprcmanager")
    d
    })
  })

  ped <- reactive({
    flog.debug(paste0("In ped <- reactive()\n"), name = "nprcmanager")
    if (is.null(sb())) {
      return(NULL)
    }
    flog.debug(paste0("In ped <- reactive() and !is.null(sb()) == TRUE\n"),
        name = "nprcmanager")

    p <- sb()
    flog.debug(paste0("column names: '", paste(names(p), collapse = "', '"),
                      "'"), name = "nprcmanager")

    p <- tryCatch({
        p <- sb()
        flog.debug(paste0("column names: '", paste(names(p),
                                                   collapse = "', '"),
                          "'"), name = "nprcmanager")
        flog.debug(" - in tryCatch before resetPopulation.",
            name = "nprcmanager")
        p <- resetPopulation(p, specifyPopulation())
        flog.debug(paste0("column names: '", paste0(names(p),
                                                    collapse = "', '"),
                          "'"), name = "nprcmanager")
        flog.debug(paste0("resetPopulation() called\n"),
            name = "nprcmanager")

        if (input$trim) {
          probands <- p$id[p$population]
          p <- trimPedigree(probands, p, removeUninformative = FALSE,
                            addBackParents = FALSE)
          #p <- trimPedigree(probands, p, removeUninformative = TRUE,
          #                  addBackParents = TRUE)
          flog.debug(paste0("trimPedigree() called\n"),
              name = "nprcmanager")
        }

        p["ped.num"] <- findPedigreeNumber(p$id, p$sire, p$dam)
        p["gen"] <- findGeneration(p$id, p$sire, p$dam)

        p
      },
      error = function(cond) {
        return(FALSE)
      })

    validate(
      need(p, geterrmessage())
    )

    return(p)
  })

  # Changing the active tab to the "Pedigree Browser" tab
  observe({
    if (!is.null(sb())) {
      updateTabsetPanel(session, "tab_pages", selected = "Pedigree Browser")
    }
  })

  # Creating the pedigree table to be displayed on the Pedigree Browser tab
  output$pedigree <- DT::renderDataTable(DT::datatable({
    if (is.null(ped())) {
      return(NULL)
    }

    # convert columns to "character" so xtables displays them properly
    p <- toCharacter(ped())

    if (!input$uid) {
      p <- p[!grepl("^U", p$id, ignore.case = TRUE), ]
      p$sire[grepl("^U", p$sire, ignore.case = TRUE)] <- NA
      p$dam[grepl("^U", p$dam, ignore.case = TRUE)] <- NA
    }

    names(p) <- headerDisplayNames(names(p))

    p
  }))

  specifyPopulation <- eventReactive(input$specifyPop, {
    p <- unlist(strsplit(input$populationIds, "[ \t\n]"))

    if (length(p) == 0) {
      return(NULL)
    } else{
      return(p)
    }
  },
  ignoreNULL = FALSE)

  # Download handler to download the full or trimmed pedigree
  output$downloadPedigree <- downloadHandler(
    filename = function() {
      paste("Pedigree", ".csv", sep = "")
    },
    content = function(file) {
      write.csv(ped(), file, na = "", row.names = FALSE)
    }
  )
  #############################################################################
  # Functions for handling the genetic value analysis generation

  geneticValue <- eventReactive(input$analysis, {
    if (is.null(ped())) {
      return(NULL)
    }
    # Ensuring the pedigree has been trimmed
    # (if there are too many animals, the program will crash)
    p <- ped()
    probands <- p$id[p$population]
    p <- trimPedigree(probands, p, removeUninformative = FALSE,
                      addBackParents = FALSE)

    validate(
      need(length(probands) != 0, "Error: No population specified")
    )

    # Setting up the progress bar
    progress <- shiny::Progress$new()
    on.exit(progress$close())

    updateProgress <- function(n = 1, detail = NULL, value = 0, reset = FALSE) {
      if (reset) {
        progress$set(detail = detail, value = value)
      } else{
        progress$inc(amount = 1 / n)
      }
    }
    #
    return(reportGV(p, gu.iter = input$iterations,
                    gu.thresh = as.integer(input$threshold),
                    byID = TRUE,
                    updateProgress = updateProgress))
  })
  # Returns the geneticValue() report
  rpt <- reactive({
    if (is.null(geneticValue())) {
      return(NULL)
    }
    return(geneticValue()[["report"]])
  })

  # Functions for displaying the Genetic Value Analysis
  gvaView <- reactive({
    if (is.null(rpt())) {
      return(NULL)
    }
    if (input$view == 0) {
      return(rpt())
    } else{
      ids <- unlist(strsplit(isolate(input$viewIds), "[ \t\n]"))
      if (length(ids) == 0) {
        return(rpt())
      } else{
        return(filterReport(ids, rpt()))
      }
    }
  })

  output$gva <- DT::renderDataTable(DT::datatable({
    if (is.null(rpt())) {
      return(NULL)
    }

    g <- gvaView()
    g$indivMeanKin <- round(g$indivMeanKin, 5)
    g$zScores <- round(g$z.scores, 2)
    g$gu <- round(g$gu, 5)
    g <- toCharacter(g)
    names(g) <- headerDisplayNames(names(g))

    return(g)
  }))

  # Download handlers for all or a subset of the Genetic Value Analysis
  output$downloadGVAFull <- downloadHandler(
    filename = function() {
      paste("GVA_full", ".csv", sep = "")
    },
    content = function(file) {
      write.csv(rpt(), file, na = "", row.names = FALSE)
    }
  )

  output$downloadGVASubset <- downloadHandler(
    filename = function() {
      paste("GVA_subset", ".csv", sep = "")
    },
    content = function(file) {
      write.csv(gvaView(), file, na = "", row.names = FALSE)
    }
  )

  #############################################################################
  # Functions for handling printing summary statistics and outputting the
  # kinship matrix

  kmat <- reactive({
    if (is.null(geneticValue())) {
      return(NULL)
    }
    return(geneticValue()[["kinship"]])
  })

  # Download handler for the kinship matrix
  output$downloadKinship <- downloadHandler(
    filename = function() {
      paste("Kinship", ".csv", sep = "")
    },
    content = function(file) {
      write.csv(kmat(), file, na = "")
    }
  )

  output$summaryStats <- renderText({
    if (is.null(geneticValue())) {
      return(NULL)
    }

    f <- geneticValue()[["total"]]
    mf <- geneticValue()[["maleFounders"]]
    ff <- geneticValue()[["femaleFounders"]]
    fe <- geneticValue()[["fe"]]
    fg <- geneticValue()[["fg"]]

    mk <- summary(rpt()[, "indivMeanKin"])
    gu <- summary(rpt()[, "gu"])

    founder <- paste("Known Founders: ", as.character(f),
                     "<br>",
                     "Known Female Founders: ", as.character(ff),
                     "<br>",
                     "Known Male Founders: ", as.character(mf),
                     "<br>",
                     "Founder Equivalents: ",
                     as.character(round(fe, digits = 2)),
                     "<br>",
                     "Founder Genome Equivalents: ",
                     as.character(round(fg, digits = 2))
    )

    header <- paste("<tr>",
                    "<th></th>",
                    "<th>Min</th>",
                    "<th>1st Quartile</th>",
                    "<th>Mean</th>",
                    "<th>Median</th>",
                    "<th>3rd Quartile</th>",
                    "<th>Max</th>",
                    "</tr>")

    k <- paste("<tr>",
               "<td>Mean Kinship</td>",
               "<td>", as.character(round(mk["Min."], 4)), "</td>",
               "<td>", as.character(round(mk["1st Qu."], 4)), "</td>",
               "<td>", as.character(round(mk["Mean"], 4)), "</td>",
               "<td>", as.character(round(mk["Median"], 4)), "</td>",
               "<td>", as.character(round(mk["3rd Qu."], 4)), "</td>",
               "<td>", as.character(round(mk["Max."], 4)), "</td>",
               "</tr>")

    g <- paste("<tr>",
               "<td>Genome Uniqueness</td>",
               "<td>", as.character(round(gu["Min."], 4)), "</td>",
               "<td>", as.character(round(gu["1st Qu."], 4)), "</td>",
               "<td>", as.character(round(gu["Mean"], 4)), "</td>",
               "<td>", as.character(round(gu["Median"], 4)), "</td>",
               "<td>", as.character(round(gu["3rd Qu."], 4)), "</td>",
               "<td>", as.character(round(gu["Max."], 4)), "</td>",
               "</tr>")

    return(paste(founder, "<br>", "<br>", "<table>", header, k, g, "</table>"))
  })

  output$mkPlot <- renderPlot({
    if (is.null(rpt())) {
      return(NULL)
    }
    mk <- rpt()[, "indivMeanKin"]
    avg <- mean(mk, na.rm = TRUE)
    std.dev <- sd(mk, na.rm = TRUE)

    upper <- avg + (2 * std.dev)
    lower <- avg - (2 * std.dev)

    hist(mk,
         breaks = 25,
         main = "Individual Mean Kinships",
         xlab = "Kinship",
         ylab = "Frequency")
    abline(v = avg, col = "red", lty = "dashed", lwd = 2)
  })

  output$zscorePlot <- renderPlot({
    if (is.null(rpt())) {
      return(NULL)
    }
    z <- rpt()[, "zScores"]
    avg <- mean(z, na.rm = TRUE)
    std.dev <- sd(z, na.rm = TRUE)

    upper <- avg + (2 * std.dev)
    lower <- avg - (2 * std.dev)

    hist(z,
         breaks = 25,
         main = "Individual Mean Kinship Z-Scores",
         xlab = "Z-Score",
         ylab = "Frequency")
    abline(v = avg, col = "red", lty = "dashed", lwd = 2)
  })
  output$guPlot <- renderPlot({
    if (is.null(rpt())) {
      return(NULL)
    }
    gu <- rpt()[, "gu"]
    avg <- mean(gu, na.rm = TRUE)
    std.dev <- sd(gu, na.rm = TRUE)

    upper <- avg + (2 * std.dev)
    lower <- avg - (2 * std.dev)

    hist(gu,
         breaks = 25,
         main = "Genetic Uniqueness",
         xlab = "Genetic Uniqueness Score",
         ylab = "Frequency")
    abline(v = avg, col = "red", lty = "dashed", lwd = 2)
  })

  output$relations <- eventReactive(input$relations, {
    renderTable({
      if (is.null(kmat())) {
        return(NULL)
      }

      j <- nrow(kmat()) * ncol(kmat())

      # Setting up the progress bar
      progress <- shiny::Progress$new()
      on.exit(progress$close())
      progress$set(message = "Finding Relationship Designations", value = 0)

      updateProgress <- function() {
        progress$inc(amount = 1 / j)
      }

      kin <- convertRelationships(kmat(), ped(),
                                  updateProgress = updateProgress)

      progress$set(message = "Preparing Table", value = 1)
      r <- makeRelationClasseTable(kin)

      toCharacter(r)
    },
    rownames = FALSE
    )
  })

  # Download handler for the first-order relationships
  output$downloadFirstOrder <- downloadHandler(
    filename = function() {
      paste("FirstOrder", ".csv", sep = "")
    },
    content = function(file) {
      p <- ped()
      r <- countFirstOrder(p, ids = p$id[p$population])
      write.csv(r, file, na = "")
    }
  )

  output$downloadRelations <- downloadHandler(
    filename = function() {
      paste("Relations", ".csv", sep = "")
    },
    content = function(file) {
      p <- ped()
      probands <- p$id[p$population]

      r <- convertRelationships(kmat(), ped(), ids = probands)
      write.csv()
    }
  )

  #############################################################################
  # Functions for handling the breeding group formation process

  bg <- eventReactive(input$grpSim, {
    if (is.null(rpt())) {
      return(NULL)
    }

    p <- ped()
    ids <- unlist(strsplit(input$grpIds, "[ \t\n]"))
    currentGroup <- unlist(strsplit(input$curGrp, "[ \t\n]"))

    if (length(ids) > 0) {
      p <- resetGroup(p, ids)
      candidates <- ids
    } else{
      candidates <- getGrpIds()
    }

    # Assume an animal that is in the group can't also be a candidate
    if (length(currentGroup) > 0) {
      candidates <- setdiff(candidates, currentGroup)
    }

    # Filter out low-value animals if desired
    use.lv <- input$lowVal
    if (!use.lv) {
      rpt <- rpt()
      lv <- rpt$id[rpt$value == "low value"]
      candidates <- setdiff(candidates, lv)
    }

    validate(
      need(length(candidates == 0), "No candidates defined"),
      need(!(length(setdiff(candidates, p$id)) > 0),
           paste("Group candidates present that are",
                 "not in the provided pedigree\n",
                 paste(setdiff(candidates, p$id), sep = "\n"))),
      need(!(length(setdiff(currentGroup, p$id)) > 0),
           paste("Current group members present that",
                 "are not in the provided pedigree\n",
                 paste(setdiff(currentGroup, p$id), sep = "\n")))
    )

    ignore <- input$ffRel
    ignore <- if (ignore) list(c("F", "F")) else NULL

    threshold <- input$kinThresh
    minAge <- input$minAge
    withKin <- input$withKin
    iter <- input$gpIter
    numGp <- ({
      input$numGp
      })

    # Setting up the progress bar
    progress <- shiny::Progress$new()
    on.exit(progress$close())
    progress$set(message = "Generating Groups", value = 0)

    n <- 1
    updateProgress <- function() {
      progress$inc(amount = 1 / iter, detail = paste("Iteration:", n))
      n <<- n + 1
    }

    if (length(currentGroup) > 0) {
      grp <- groupAddAssign(candidates = candidates,
                           currentGroup = currentGroup,
                           kmat = kmat(),
                           ped = p,
                           threshold = threshold,
                           ignore = ignore,
                           minAge = minAge,
                           iter = iter,
                           numGp = 1,
                           updateProgress = updateProgress,
                           withKin = withKin)
    } else{
      grp <- groupAddAssign(candidates = candidates,
                           currentGroup = NULL,
                           kmat = kmat(), ped = p,
                           threshold = threshold,
                           ignore = ignore,
                           minAge = minAge,
                           iter = iter,
                           numGp = numGp,
                           updateProgress = updateProgress,
                           withKin = withKin)
    }

    return(grp)
  })

  getGrpIds <- reactive({
    p <- ped()
    if ("group" %in% colnames(p)) {
      return(p$id[p$group])
    } else{
      return(p$id[p$population])
    }
  })

  # Functions to handle breeding group display
  observe({
    if (!is.null(bg())) {
      x <- length(bg()$group)

      if (x > 1) {
        gp <- list()
        for (i in 1:(x - 1)) {
          gp[paste("Group", as.character(i))] <- i
        }
        gp["Unused"] <- x

        updateSelectInput(session, "viewGrp",
                          label = "Enter the group to view:",
                          choices = gp, selected = 1)
      } else if (x == 1) {
        updateSelectInput(session, "viewGrp",
                          label = "Enter the group to view:",
                          choices = list("Unused" = 1), selected = 1)
      } else{
        updateSelectInput(session, "viewGrp",
                          label = "Enter the group to view:",
                          choices = list(" " = 1), selected = 1)
      }
    }
  })

  bgGroupView <- reactive({
    if (is.null(bg())) {
      return(NULL)
    }
    i <- as.numeric(input$viewGrp)
    gp <- bg()$group[[i]]
    gp <- as.data.frame(gp)
    colnames(gp) <- "Ego ID"

    if (nrow(gp) == 0) {
      return(NULL)
    } else {
      return(gp[order(gp$`Ego ID`), , drop = FALSE])
    }
  })
  bgGroupKinView <- reactive({
    if (is.null(bg()$groupKin)) {
      return(NULL)
    }
    i <- as.numeric(input$viewGrp)
    kmat <- bg()$groupKin[[i]]
    kmat <- as.data.frame(round(kmat, 6))

    if (nrow(kmat) == 0) {
      return(NULL)
    } else{
      return(kmat)
    }
  })

  output$breedingGroups <- DT::renderDataTable(DT::datatable({
    if (is.null(bg())) {
      return(NULL)
    }
    return(bgGroupView())
  }))
  output$breedingGroupKin <- DT::renderDataTable(DT::datatable({
    if (is.null(bg()$groupKin)) {
      return(NULL)
    }
    return(bgGroupKinView())
  }))

  # Download handler for the current group
  output$downloadGroup <- downloadHandler(
    filename = getDatedFilename(paste0("Group-", input$viewGrp,
                                      ".csv", sep = "")),
    content = function(file) {
      write.csv(bgGroupView(), file, na = "", row.names = FALSE)
    },
    contentType = "text/csv"
  )

  output$downloadGroupKin <- downloadHandler(
    filename = getDatedFilename(paste0("GroupKin-", input$viewGrp,
                                         ".csv", sep = "")),
    content = function(file) {
      write.csv(bgGroupKinView(), file, na = "", row.names = TRUE)
    },
    contentType = "text/csv"
  )

  #############################################################################
  # Function to handle display of pyramid plot
  flog.debug("before renderPlot(getPyramidPlot(ped)))", name = "nprcmanager")
  output$pyramidPlot <- renderPlot(getPyramidPlot(ped()))
  flog.debug("after renderPlot(getPyramidPlot(ped)))", name = "nprcmanager")
})
