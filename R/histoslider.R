#' Create a histoslider
#'
#' @param id An input id.
#' @param values a vector of values for which the histogram is desired.
#' @param start A value for the starting handle.
#' @param end A value for the ending handle.
#' @param width,height Any valid CSS unit defining the width/height.
#' @param breaks value passed along to [hist()].
#' @param options a list of [histoslider options](https://github.com/samhogg/histoslider/blob/b4ac504/src/components/Histoslider.js#L103-L125).
#'
#' @export
#' @examples
#'
#' library(shiny)
#'
#' shinyApp(
#'   input_histoslider("x", rnorm(100)),
#'   function(input, output) {
#'     observe(print(input$x))
#'   }
#' )
#'
input_histoslider <- function(id, values, start = NULL, end = NULL, width = "100%", height = 150, breaks = "Sturges", options = list()) {

  if (!is.numeric(values)) {
    stop("`values` must be a numeric vector")
  }

  x <- hist(values, plot = FALSE, breaks = breaks)
  bins <- lapply(seq_along(x$counts), function(i) {
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

  config <- modifyList(
    list(
      data = bins,
      selection = selection,
      width = validateCssUnit(width),
      height = validateCssUnit(height)
    ),
    options
  )

  reactR::createReactShinyInput(
    id, class = "histoslider",
    dependencies = htmltools::htmlDependency(
      name = "histoslider-input",
      version = "1.0.0",
      src = "www/histoslider/histoslider",
      package = "histoslider",
      script = "histoslider.js"
    ),
    default = selection,
    configuration = config,
    container = div
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
