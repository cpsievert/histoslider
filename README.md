
# histoslider

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/histoslider)](https://cran.r-project.org/package=histoslider)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html)
[![R build
status](https://github.com/cpsievert/histoslider/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/cpsievert/histoslider/actions)

<!-- badges: end -->

Provides a Shiny input binding wrapper to the [histoslider](https://github.com/samhogg/histoslider) React component.

## Installation

You can install the development version of `{histoslider}` like so:

``` r
remotes::install_github("cpsievert/histoslider")
```

## Example usage

``` r
library(shiny)
library(histoslider)

shinyApp(
  input_histoslider("x", "Random", rnorm(100)),
  function(input, output) {
    observe(print(input$x))
  }
)
```


See the `inst/examples` folder for more examples.
