#' Create a histoslider
#'
#' @importFrom reactR createReactShinyInput
#' @importFrom htmltools htmlDependency tags
#'
#' @export
#' @examples
#'
#' library(shiny)
#'
#' shinyApp(
#'   div(
#'     input_histoslider("foo", rnorm(100)),
#'     sliderInput("bar", "Bar", min = 0, max = 100, value = 10)
#'   ),
#'   function(input, output) {
#'     observe(print(input$foo))
#'     observe(print(input$bar))
#'   }
#' )
#'
input_histoslider <- function(id, values, start = NULL, end = NULL) {

  if (!is.numeric(values)) {
    stop("`values` must be a numeric vector")
  }

  x <- hist(values, plot = FALSE)
  dat <- lapply(seq_along(x$counts), function(i) {
    list(
      y = x$counts[[i]],
      x0 = x$breaks[[i]],
      x = x$breaks[[i + 1]]
    )
  })

  rng <- range(x$breaks)
  if (is.null(start)) start <- rng[1]
  if (is.null(end)) end <- rng[2]
  selection <- c(start, end)

  reactR::createReactShinyInput(
    id,
    class = "histoslider",
    dependencies = htmltools::htmlDependency(
      name = "histoslider-input",
      version = "1.0.0",
      src = "www/histoslider/histoslider",
      package = "histoslider",
      script = "histoslider.js"
    ),
    default = selection,
    configuration = list(
      data = dat,
      selection = selection
    ),
    container = htmltools::tags$span
  )
}

#' Update a histoslider
#'
#' @export
update_histoslider <- function(id, value, configuration = NULL, session = shiny::getDefaultReactiveDomain()) {
  message <- list(value = value)
  if (!is.null(configuration)) message$configuration <- configuration
  session$sendInputMessage(id, message);
}
