#' Creates an Excel workbook with worksheets.
#'
## Copyright(c) 2017-2020 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' @return TRUE if the Excel file was successfully created. FALSE if any errors
#' occurred.
#'
#' @examples
#' \donttest{
#' library(nprcgenekeepr)
#'
#' make_df_list <- function(size) {
#'   df_list <- list(size)
#'   if (size <= 0)
#'     return(df_list)
#'   for (i in seq_len(size)) {
#'     n <- sample(2:10, 2, replace = TRUE)
#'     df <- data.frame(matrix(data = rnorm(n[1] * n[2]), ncol = n[1]))
#'     df_list[[i]] <- df
#'   }
#'   names(df_list) <- paste0("A", seq_len(size))
#'   df_list
#' }
#' df_list <- make_df_list(3)
#' sheetnames <- names(df_list)
#' create_wkbk(file = file.path(tempdir(), "example_excel_wkbk.xlsx"),
#'             df_list = df_list,
#'             sheetnames = sheetnames, replace = FALSE)
#' }
#'
#' @param file filename of workbook to be created
#' @param df_list list of data frames to be added as worksheets to workbook
#' @param sheetnames character vector of worksheet names
#' @param replace Specifies if the file should be replaced if it
#' already exist (default is FALSE).
#' @importFrom stringi stri_c
#' @importFrom WriteXLS WriteXLS
#' @export
create_wkbk <- function(file, df_list, sheetnames, replace = FALSE) {
  if (length(df_list) != length(sheetnames))
    stop(stri_c("Number of 'sheetnames' specified does not equal the number ",
                "of data frames in 'df_list'."))

  if (file.exists(file)) {
    if (replace) {
      file.remove(file)
    } else {
      warning(stri_c("File, ", file, " exists and was not overwritten."))
      return(FALSE)
    }
  }
  WriteXLS(x = df_list, ExcelFileName = file, SheetNames = sheetnames,
           Encoding = "UTF-8", col.names = TRUE, AdjWidth = TRUE)
}
