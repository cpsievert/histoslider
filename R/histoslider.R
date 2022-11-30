#' Create a histogram slider
#'
#' Creates a Shiny UI input binding to a histogram with a slider "filter"
#' control.
#'
#' @param id An input id.
#' @param label A label for the input (can be `NULL` or a string).
#' @param values a vector of numeric values for which the histogram is desired.
#' @param start A numeric value for the starting handle.
#' @param end A numeric value for the ending handle.
#' @param width,height Any valid CSS unit defining the width/height.
#' @param breaks determines how histogram bins are computed (see [hist()] for
#'   possible values and details).
#' @param options a list of [histoslider
#'   options](https://github.com/samhogg/histoslider/blob/b4ac504/src/components/Histoslider.js#L103-L125).
#'
#'
#' @returns A Shiny UI input element.
#' @seealso [update_histoslider]
#'
#' @export
#' @examples
#'
#' if (interactive()) {
#'   library(shiny)
#'   shinyApp(
#'     input_histoslider("x", "Random", rnorm(100)),
#'     function(input, output) {
#'       observe(print(input$x))
#'     }
#'   )
#' }
#'
input_histoslider <- function(id, label, values, start = NULL, end = NULL, width = "100%", height = 175, breaks = rlang::missing_arg(), options = list()) {

  config <- rlang::list2(
    width = "100%",
    height = "100%",
    label = label,
    !!!compute_bin_config(values, breaks, start, end)
  )

  config <- utils::modifyList(config, options)

  value_type <- NULL
  if (is_date_time(values)) {
    value_type <- if (inherits(values, "Date")) "date" else "datetime"
  }

  reactR::createReactShinyInput(
    id, class = "histoslider",
    dependencies = htmlDependency(
      name = "histoslider-input",
      version = "1.0.0",
      src = "www/histoslider/histoslider",
      package = "histoslider",
      script = "histoslider.js",
      stylesheet = "histoslider.css"
    ),
    default = config$selection,
    configuration = config,
    container = function(...) {
      div(
        style = css(
          height = validateCssUnit(height),
          width = validateCssUnit(width)
        ),
        `data-value-type` = value_type,
        ...
      )
    }
  )
}

#' Update a histogram slider
#'
#' Change the value of a [input_histoslider()] on the client (must be called
#' inside a currently active user `session`). See
#' [here](https://github.com/cpsievert/histoslider/blob/main/inst/examples/update/app.R)
#' for an example.
#'
#' @details Any arguments with `NULL` values will be ignored; they will not
#'   result in any changes to the input object on the client.
#'
#' @inheritParams input_histoslider
#' @param session The shiny user `session` object.
#'
#' @returns Nothing.
#' @seealso [input_histoslider]
#'
#' @export
update_histoslider <- function(id, label = NULL, values = NULL, start = NULL, end = NULL, breaks = rlang::missing_arg(), options = NULL, session = shiny::getDefaultReactiveDomain()) {

  config <- if (!is.null(values)) {

    compute_bin_config(values, breaks, start, end)

  } else if (!is.null(start) || !is.null(end)) {

    list(selection = c(
      start %||% shiny::isolate(session$input[[id]][1]),
      end %||% shiny::isolate(session$input[[id]][2])
    ))

  } else {

    list()

  }

  if (!is.null(label)) {
    config$label <- label
  }

  if (length(options)) {
    config <- c(config, options)
  }

  msg <- list()
  if (length(config) > 0) {
    msg$configuration <- config

    if (!is.null(config$selection)) {
      msg$value <- config$selection
    }
  }

  session$sendInputMessage(id, msg)
}



compute_bin_config <- function(values, breaks = rlang::missing_arg(), start = NULL, end = NULL) {

  isDate <- is_date_time(values)

  if (isDate) {
    # hist.Date() will actually error with missing breaks
    if (rlang::is_missing(breaks)) {
      breaks <- 30
      rlang::inform(
        'Defaulting to `breaks = 30`. See `help("hist.Date", "graphics")` for more options.'
      )
    }
  }

  x <- if (rlang::is_missing(breaks)) {
    graphics::hist(values, plot = FALSE)
  } else {
    graphics::hist(values, plot = FALSE, breaks = breaks)
  }

  if (isDate) {
    C <- if (inherits(values, "Date")) 86400000 else 1000
    x$breaks <- x$breaks * C
  }

  dat <- lapply(seq_along(x$counts), function(i) {
    list(
      y = x$counts[[i]],
      x0 = x$breaks[[i]],
      x = x$breaks[[i + 1]]
    )
  })

  rng <- range(x$breaks)
  selection <- c(
    as_numeric(start) %||% rng[1],
    as_numeric(end) %||% rng[2]
  )

  res <- list(
    data = dat,
    selection = selection,
    isDate = isDate
  )

  if (isDate) {
    res$handleLabelFormat <- if (inherits(values, "Date")) {
      "%b %e %Y"
    } else {
      "%b %e %Y %H:%M:%S"
    }

    rlang::inform(
      paste0(
        'Defaulting to `options = list(handleLabelFormat = "',
        res$handleLabelFormat, '")`. See https://github.com/d3/d3-time-format#locale_format for more options'
      )
    )
  }

  res
}

# also converts dates/date-time to milliseconds (since EPOCH)
as_numeric <- function(x) {
  if (length(x) == 0) return(x)
  res <- as.numeric(x)
  if (is_date_time(x)) {
    res <- res * if (inherits(x, "Date")) 86400000 else 1000
  }
  res
}

is_date_time <- function(x) {
  inherits(x, c("Date", "POSIXt"))
}


"%||%" <- function(x, y) {
  if (is.null(x)) y else x
}
