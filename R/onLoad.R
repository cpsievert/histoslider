.onLoad <- function(libname, pkgname) {
  shiny::registerInputHandler("histoslider.histoslider", function(x, shinysession, name) {
    sort(as.numeric(x))
  }, force = TRUE)
}
