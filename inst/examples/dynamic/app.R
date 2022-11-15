library(shiny)
library(htmltools)
library(histoslider)

ui <- fluidPage(
  div(
    style = css(
      width = "50%",
      marginLeft = "auto",
      marginRight = "auto",
      display = "flex",
      flexDirection = "column",
      alignItems = "center"
    ),
    uiOutput("slider", fill = TRUE),
    selectInput("var", NULL, names(mtcars), selected = "mpg", width = "fit-content", selectize = FALSE)
  )
)

shinyApp(
  ui,
  function(input, output) {
    output$slider <- renderUI({
      input_histoslider("slide", NULL, mtcars[[input$var]])
    })
  }
)
