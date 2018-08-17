#' Eliminates partial parentage situations by adding unique placeholder
#' IDs for the unknown parent.
#'
#' @param ped datatable that is the `Pedigree`. It contains pedigree
#' information. The fields \code{sire} and \code{dam} are required.
#' @return The updated pedigree with partial parentage removed.
#' @export
addUIds <- function(ped) {
  s <- which(is.na(ped$sire) & !is.na(ped$dam))
  d <- which(!is.na(ped$sire) & is.na(ped$dam))

  if (!identical(s, integer(0))) {
    k <- length(s)
    sireIds <- paste("U", sprintf("%04d", 1:k), sep = "")
    ped[s, "sire"] <- sireIds
  }
  else{
    k <- 0
  }

  if (!identical(d, integer(0))) {
    m <- k + 1
    n <- k + length(d)
    damIds <- paste("U", sprintf("%04d", m:n), sep = "")
    ped[d, "dam"] <- damIds
  }

  return(ped)
}