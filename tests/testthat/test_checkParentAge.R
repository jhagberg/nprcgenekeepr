#' Copyright(c) 2017-2020 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("checkParentAge")
library(testthat)
qcPed <- nprcgenekeepr::qcPed

test_that("checkParentAge identifies the over aged parents", {
  underAgeTwo <- checkParentAge(qcPed, minParentAge = 2)
  underAgeThree <- checkParentAge(qcPed, minParentAge = 3)
  underAgeFive <- checkParentAge(qcPed, minParentAge = 5)
  underAgeSix <- checkParentAge(qcPed, minParentAge = 6)
  underAgeTen <- checkParentAge(qcPed, minParentAge = 10)
  expect_equal(nrow(underAgeTwo), 0)
  expect_equal(nrow(underAgeThree), 0)
  expect_equal(nrow(underAgeFive), 1)
  expect_equal(nrow(underAgeSix), 6)
  expect_true(all(underAgeSix$dam %in% c("EX98QB", "L42X7I", "MRGPPA",
                                         "O4Z4IB", "RY6OPR", "ZYTIYY")))
  expect_true(
    all(underAgeTen$sire[underAgeTen$sireAge < 10 &
                           !is.na(underAgeTen$sireAge)] %in%
          c("HRQJQR", "HBEMKY", "0RZ5LL", "F0YSEE", "HP3E04", "716P7O",
            "WMUJC5", "TNAWBK", "QDY8I7", "V8VU31", "H00H7D", "YIAD2N", "HRBVOE",
            "48YAZ5", "CQMWGX", "549AEC", "H0UP6R", "ODSV6N", "IZ0ELE")))
})
test_that("checkParentAge requires birth column to be potential date", {
  ped <- qcPed
  ped$birth <- ped$birth > "2000-01-01"
  expect_error(checkParentAge(ped, minParentAge = 3))
}
)
test_that("checkParentAge allows birth column to be character", {
  ped <- qcPed
  ped$birth <- format(ped$birth, format = "%Y-%m-%d")
  expect_equal(nrow(checkParentAge(ped, minParentAge = 6)), 6)
  ped <- qcPed
  ped$birth <- format(ped$birth, format = "%m-%d-%Y")
  expect_equal(nrow(checkParentAge(ped, minParentAge = 6)), 6)
})
test_that("checkParentAge returns unchanged dataframe if required column is missing", {
  ped <- checkParentAge(qcPed[ , !names(qcPed) %in% "id"])
  expect_equal(ncol(ped), ncol(qcPed[ , !names(qcPed) %in% "id"]))
  expect_equal(ped, qcPed[ , !names(qcPed) %in% "id"])
})
test_that("checkParentAge returns NULL if required column is missing and reportErrors == TRUE", {
  ped <- checkParentAge(qcPed[ , !names(qcPed) %in% "id"], reportErrors = TRUE)
  expect_true(is.null(ped))
})
test_that("checkParentAge returns NULL if required dataframe has no rows and reportErrors == TRUE", {
  ped <- checkParentAge(qcPed[0, ], reportErrors = TRUE)
  expect_true(is.null(ped))
})

