
# histoslider

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/histoslider)](https://cran.r-project.org/package=histoslider)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html)
[![R build
status](https://github.com/cpsievert/histoslider/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/cpsievert/histoslider/actions)

<!-- badges: end -->

A Shiny input binding wrapper for the [histoslider](https://github.com/samhogg/histoslider) React component.

## Installation

You can install the development version of `{histoslider}` like so:

``` r
remotes::install_github("cpsievert/histoslider")
```

## Example usage

`input_histoslider()` currently supports creating histogram sliders from numeric, date, datetime vectors. The histogram bins may be customized through the `breaks` argument of an implicit call to `hist()`.

``` r
library(shiny)
library(histoslider)

numerics <- rnorm(100)
dates <- sample(
  seq(as.Date('2020-01-01'), as.Date('2030-01-01'), by = "1 month"),
  size = 500, replace = TRUE
)

datetimes <- sample(
  seq(as.POSIXct('2020-01-01 00:01'), as.POSIXct('2030-01-01 00:01'), by = "1 month"),
  size = 500, replace = TRUE
)

ui <- bslib::page_fixed(
  input_histoslider("numeric", "Numeric", numerics, start = -1, end = 1),
  input_histoslider("date", "Date", dates, breaks = 15),
  input_histoslider("datetime", "Date Time", datetimes),
  verbatimTextOutput("values")
)

server <- function(input, output) {
  output$values <- renderPrint({
    str(list(
      numeric = input$numeric,
      date = input$date,
      datetime = input$datetime
    ))
  })
}

shinyApp(ui, server)
```


![<https://i.imgur.com/XhVNGCf.gifv>](https://i.imgur.com/XhVNGCf.gif)

An `input_histoslider()` can also be updated programmatically via `update_histoslider()`. For example usage, see the [`inst/examples`](https://github.com/cpsievert/histoslider/tree/main/inst/examples) folder.
