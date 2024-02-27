
#' Run Resvidex shiny app
#'
#' Deploys a server that runs the Resvidex app locally
#'
#'
#' @return a shiny app
#' @export
#'
#' @examples
#' \dontrun{
#' resvidex::runResvidexApp()
#' }
#'

runApp <- function() {

  # find and launch the app
  appDir <- system.file("myapp", "app.R", package = "resvidex")
  resvidex::runApp(appDir, display.mode = "normal")
}
