
# histoslider

<!-- badges: start -->
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

shinyApp(
  histoslider::input_histoslider("x", rnorm(100)),
  function(input, output) {
    observe(print(input$x))
  }
)
```

