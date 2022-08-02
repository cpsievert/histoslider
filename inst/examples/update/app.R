library(shiny)
library(htmltools)
library(histoslider)

ui <- fluidPage(
  actionButton("click", "Click"),
  div(
    style = css(
      width = "50%",
      marginLeft = "auto",
      marginRight = "auto",
      display = "flex",
      flexDirection = "column",
      alignItems = "center"
    ),
    input_histoslider("slide", NULL, mtcars$mpg),
    selectInput("var", NULL, names(mtcars), selected = "mpg", width = "fit-content", selectize = FALSE)
  )
)

shinyApp(
  ui,
  function(input, output) {
    observeEvent(input$click, {
      vals <- mtcars[[input$var]]
      update_histoslider("slide", values = vals)
    })
  }
)
