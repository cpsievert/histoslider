library(shiny)
library(histoslider)

shinyApp(
  input_histoslider("x", "Random", rnorm(100)),
  function(input, output) {
    observe(print(input$x))
  }
)
