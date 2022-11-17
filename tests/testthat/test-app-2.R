library(shinytest2)
library(shiny)
library(htmltools)

set.seed(1024)

dates <- sample(
  seq(
    as.Date('2020-01-01'),
    as.Date('2030-01-01'),
    by = "1 month"
  ),
  size = 500, replace = TRUE
)

datetimes <- sample(
  seq(
    as.POSIXct('2020-01-01 00:01'),
    as.POSIXct('2030-01-01 00:01'),
    by = "1 month"
  ),
  size = 500, replace = TRUE
)

testing_app <- function() {
  shinyApp(
    bslib::page_fluid(
      input_histoslider("date", "Date", dates, breaks = 10),
      input_histoslider("datetime", "Date Time", datetimes),
      verbatimTextOutput("values")
    ),
    function(input, output) {
      output$values <- renderPrint({
        str(list(
          date = input$date,
          datetime = input$datetime
        ))
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
    name = "dates",
    height = 400,
    width = 700,
    view = interactive()
  )
  expect_screenshot <- function() {
    Sys.sleep(1)
    app$expect_screenshot()
  }

  expect_screenshot()

  app$set_inputs(
    date = as.numeric(
      as.Date(c("2022-05-01", "2027-03-01"))
    ) * 86400000,
    wait_ = FALSE
  )

  app$set_inputs(
    datetime = as.numeric(
      as.POSIXct(c("2022-06-23 12:01:00.0", "2027-04-01 00:01:00.0"))
    ) * 1000,
    wait_ = FALSE
  )

  expect_screenshot()
})

