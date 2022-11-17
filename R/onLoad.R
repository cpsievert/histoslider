.onLoad <- function(libname, pkgname) {
  register_input_handler(default_handler)
  register_input_handler(date_handler, type = "date")
  register_input_handler(datetime_handler, type = "datetime")
}


default_handler <- function(x, shinysession, name) {
  sort(as.numeric(x))
}

date_handler <- function(x, shinysession, name) {
  x <- sort(as.numeric(x))
  as.Date(x / 86400000, origin = "1970-01-01", tz = "UTC")
}

datetime_handler <- function(x, shinysession, name) {
  x <- sort(as.numeric(x))
  as.POSIXct(x / 1000, origin = "1970-01-01", tz = "UTC")
}


register_input_handler <- function(func, type = c("default", "date", "datetime")) {
  type <- match.arg(type)

  name <- "histoslider.histoslider"
  if (type != "default") {
    name <- paste0(name, type)
  }

  shiny::registerInputHandler(name, func, force = TRUE)
}
