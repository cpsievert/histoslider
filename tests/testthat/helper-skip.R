skip_if_not_on_gha_mac <- function() {
  skip_on_cran()
  skip_if_not(on_ci(), "Not on a CI service (i.e., GHA)")
  skip_on_os("windows")
  skip_on_os("linux")
}


# a la testthat:::on_ci
on_ci <- function() {
  isTRUE(as.logical(Sys.getenv("CI")))
}
