#' Get genotypes from file
#'
#' @return A genotype file compatible with others in this package.
#'
#' @param fileName character vector of temporary file path.
#' @param sep column separator in CSV file
#' @import futile.logger
#' @importFrom readxl excel_format
#' @importFrom utils read.table
#' @export
getGenotypes <- function(fileName, sep = ",") {
  flog.debug(paste0("in getGenotypes\n"),
             name = "nprcmanager")
  if (excel_format(fileName) %in% c("xls", "xlsx")) {
    genotypes <- readExcelPOSIXToCharacter(fileName)
    flog.debug(paste0("in getGenotypes after readxl, nrow(genotypes) = ",
                      nrow(genotypes), "\n"), name = "nprcmanager")
  } else {
    genotypes <- read.table(fileName,
                         header = TRUE,
                         sep = sep,
                         stringsAsFactors = FALSE,
                         na.strings = c("", "NA"),
                         check.names = FALSE)
    flog.debug(paste0("in getGenotypes after read.csv, nrow(genotypes) = ",
                      nrow(genotypes), "\n"), name = "nprcmanager")
  }
  genotypes
}