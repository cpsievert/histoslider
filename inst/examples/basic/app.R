library(shiny)
library(histoslider)

shinyApp(
  bslib::page_fluid(
    input_histoslider("x", "Random", rnorm(100))
  ),
  function(input, output) {
    observe(print(input$x))
  }
)
