#' Create a histoslider
#'
#' @param id An input id.
#' @param label A label for the input (can be `NULL` or a string).
#' @param values a vector of numeric values for which the histogram is desired.
#' @param start A numeric value for the starting handle.
#' @param end A numeric value for the ending handle.
#' @param width,height Any valid CSS unit defining the width/height.
#' @param breaks determines how histogram bins are computed (see [hist()] for possible values and details).
#' @param options a list of [histoslider options](https://github.com/samhogg/histoslider/blob/b4ac504/src/components/Histoslider.js#L103-L125).
#'
#' @export
#' @examples
#'
#' library(shiny)
#'
#' shinyApp(
#'   input_histoslider("x", "Random", rnorm(100)),
#'   function(input, output) {
#'     observe(print(input$x))
#'   }
#' )
#'
input_histoslider <- function(id, label, values, start = NULL, end = NULL, width = "100%", height = 150, breaks = "Sturges", options = list()) {

  bins <- compute_bins(values, breaks)

  rng <- attr(bins, "range")
  selection <- c(
    start %||% rng[1],
    end %||% rng[2]
  )

  config <- utils::modifyList(
    list(
      data = bins,
      selection = selection,
      width = validateCssUnit(width),
      height = validateCssUnit(height),
      label = label
    ),
    options
  )

  # TODO: is there a way to do this properly without force=T?
  shiny::registerInputHandler("histoslider.histoslider", function(x, shinysession, name) {
    sort(as.numeric(x))
  }, force = TRUE)

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
    container = function(...) {
      div(..., style = css(height = "100%", width = "100%"))
    }
  )
}

#' Update a histoslider
#'
#' @export
update_histoslider <- function(id, label = NULL, values = NULL, start = NULL, end = NULL, width = NULL, height = NULL, breaks = "Sturges",  options = NULL, session = shiny::getDefaultReactiveDomain()) {

  bins <- NULL
  selection <- NULL
  if (!is.null(values)) {
    bins <- compute_bins(values, breaks)

    rng <- attr(bins, "range")
    selection <- c(
      start %||% rng[1],
      end %||% rng[2]
    )

  } else if (!is.null(start) || !is.null(end)) {

    selection <- c(
      start %||% shiny::isolate(session$input[[id]][1]),
      end %||% shiny::isolate(session$input[[id]][2])
    )

  }

  config <- dropNulls(list(
    data = bins,
    selection = selection,
    width = validateCssUnit(width),
    height = validateCssUnit(height),
    label = label
  ))

  if (length(options)) {
    config <- c(config, options)
  }

  msg <- list()
  if (!is.null(selection)) {
    msg$value <- selection
  }
  if (length(config)) {
    msg$configuration <- config
  }

  session$sendInputMessage(id, msg)
}



compute_bins <- function(values, breaks) {
  if (!is.numeric(values)) {
    stop("`values` must be a numeric vector")
  }

  x <- hist(values, plot = FALSE, breaks = breaks)
  res <- lapply(seq_along(x$counts), function(i) {
    list(
      y = x$counts[[i]],
      x0 = x$breaks[[i]],
      x = x$breaks[[i + 1]]
    )
  })

  attr(res, "range") <- range(x$breaks)
  res
}


"%||%" <- function(x, y) {
  if (is.null(x)) y else x
}


dropNulls <- function(x) {
  x[!vapply(x, is.null, FUN.VALUE = logical(1))]
}
