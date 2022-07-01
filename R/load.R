.onLoad <- function(libname, pkgname) {
  if ("shiny" %in% loadedNamespaces()) {
    register_input_hander()
  } else {
    setHook(packageEvent("shiny", "onLoad"), register_input_hander)
  }
}


register_input_hander <- function() {
  shiny::registerInputHandler("histoslider.histoslider", function(x, shinysession, name) {
    sort(as.numeric(x))
  })
}

