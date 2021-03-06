% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/getSexRatioWithAdditions.R
\name{getSexRatioWithAdditions}
\alias{getSexRatioWithAdditions}
\title{getSexRatioWithAdditions returns the sex ratio of a group.}
\usage{
getSexRatioWithAdditions(ids, ped, additionalMales, additionalFemales)
}
\arguments{
\item{ids}{character vector of animal Ids}

\item{ped}{datatable that is the `Pedigree`. It contains pedigree
information including the IDs listed in \code{candidates}.}

\item{additionalMales}{Integer value of males to add to those within the
group when calculating the ratio. Ignored if calculated ratio is 0 or Inf.
Default is 0.}

\item{additionalFemales}{Integer value of females to add to those within the
group when calculating the ratio. Ignored if calculated ratio is 0 or Inf.
Default is 0.}
}
\description{
Adding males and females to the ratio calculation is possible, but the
default behavior is to simply return the sex ratio of the group.
This is a helper routine for the main one \code{calculateSexRatio}.
}
