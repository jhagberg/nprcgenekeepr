#' Check parent ages to be at least \code{minParentAge}
#'
## Copyright(c) 2017-2020 R. Mark Sharp
## This file is part of nprcgenekeepr
#' Ensure parents are sufficiently older than offspring
#'
#' @return A dataframe containing rows for each animal where one or more
#' parent was less than \code{minParentAge}. It contains all of the columns
#' in the original \code{sb} dataframe with the following added columns:
#' \enumerate{
#' \item {sireBirth} {sire's birth date}
#' \item{sireAge} {age of sire in years on the date indicated by \code{birth}.}
#' \item{damBirth} {dam's birth date}
#' \code{damAge} {age of dam in years on the date indicated by \code{birth}.}
#' }
#'
#' @examples
#' \donttest{
#' library(nprcgenekeepr)
#' qcPed <- nprcgenekeepr::qcPed
#' checkParentAge(qcPed, minParentAge = 2)
#' checkParentAge(qcPed, minParentAge = 3)
#' checkParentAge(qcPed, minParentAge = 5)
#' checkParentAge(qcPed, minParentAge = 6)
#' checkParentAge(qcPed, minParentAge = 10)
#' }
#'
#' @param sb A dataframe containing a table of pedigree and demographic
#' information.
#' @param minParentAge numeric values to set the minimum age in years for
#' an animal to have an offspring. Defaults to 2 years. The check is not
#' performed for animals with missing birth dates.
#' @param reportErrors logical value if TRUE will scan the entire file and
#' make a list of all errors found. The errors will be returned in a
#' list of list where each sublist is a type of error found.
#' @import lubridate
#' @export
checkParentAge <- function(sb, minParentAge = 2, reportErrors = FALSE) {
  if (nrow(sb) == 0 |
      !all(c("id", "sire", "dam") %in% names(sb))) {
    if (reportErrors == TRUE) {
      return(NULL)
    } else {
      return(sb)
    }
  }
  if (!any(class(sb$birth) %in% c("Date", "POSIXct", "character"))) {
    if (reportErrors) {
      ## Bad birth date column precludes checking parent age
      return(NULL)
    } else {
      stop("Birth column must be of class 'Date', 'POSIXct', or 'character'")
    }
  } else if (class(sb$birth) == "character") {
    sb$birth <- anytime(sb$birth)
  } else {
    sb$birth <- as.Date(sb$birth)
  }

  sireBirth <- data.frame(
    id = sb$id[sb$id %in% sb$sire & !is.na(sb$birth)],
    sireBirth = sb$birth[sb$id %in% sb$sire & !is.na(sb$birth)],
    stringsAsFactors = FALSE)
  damBirth <- data.frame(
    id = sb$id[sb$id %in% sb$dam & !is.na(sb$birth)],
    damBirth = sb$birth[sb$id %in% sb$dam & !is.na(sb$birth)],
    stringsAsFactors = FALSE)
  sb <- merge(sb, sireBirth, by.x = "sire", by.y = "id", all = TRUE)
  sb <- merge(sb, damBirth, by.x = "dam", by.y = "id", all = TRUE)
  sb$sireAge <- NA
  sb$sireAge[!is.na(sb$sireBirth)] <-
    (sb$birth[!is.na(sb$sireBirth)] -
       sb$sireBirth[!is.na(sb$sireBirth)]) / dyears(1)
  sb$damAge <- NA
  sb$damAge[!is.na(sb$damBirth)] <-
    (sb$birth[!is.na(sb$damBirth)] -
       sb$damBirth[!is.na(sb$damBirth)]) / dyears(1)
  sb <- sb[!is.na(sb$birth), ]
  sb <- sb[(sb$sireAge < minParentAge & !is.na(sb$sireBirth)) |
              (sb$damAge < minParentAge & !is.na(sb$damBirth)), ]
  sb$exit <- as.character(sb$exit)
  sb$sireAge <- round(sb$sireAge, 2)
  sb$damAge <- round(sb$damAge, 2)
  sb
}
