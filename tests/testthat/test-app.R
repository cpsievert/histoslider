library(shinytest2)
library(shiny)
library(htmltools)

testing_app <- function(label = NULL, ...) {

  ui <- fluidPage(
    style = css(
      width = "50%",
      marginLeft = "auto",
      marginRight = "auto",
      display = "flex",
      flexDirection = "column",
      alignItems = "center"
    ),
    input_histoslider(
      "slide", label = label,
      values = mtcars$mpg, ...
    ),
    selectInput("var", NULL, names(mtcars), selected = "mpg", width = "fit-content", selectize = FALSE)
  )

  shinyApp(
    ui,
    function(input, output) {
      observe({
        vals <- mtcars[[input$var]]
        update_histoslider("slide", values = vals)
      })
    }
  )
}

test_that("Basic functionality works", {
  skip_on_cran()
  skip_on_os("windows")
  skip_on_os("linux")

  app <- AppDriver$new(
    testing_app(),
    variant = platform_variant(),
    name = "choose-variable",
    height = 400,
    width = 700,
    view = interactive()
  )
  expect_screenshot <- function() {
    Sys.sleep(1)
    app$expect_screenshot()
  }

  expect_screenshot()
  app$set_inputs(slide = c(10, 27.9633867276888), wait_ = FALSE)
  expect_screenshot()
  app$set_inputs(slide = c(10, 35), wait_ = FALSE)
  expect_screenshot()
  app$set_inputs(var = "disp", wait_ = FALSE)
  expect_screenshot()
  app$set_inputs(slide = c(169.450800915332, 500), wait_ = FALSE)
  expect_screenshot()
  app$set_inputs(var = "cyl", wait_ = FALSE)
  expect_screenshot()
})
