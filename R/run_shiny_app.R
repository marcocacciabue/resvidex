
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
#' resvidex::run_shiny_app()
#' }
#'

run_shiny_app <- function() {

  # find and launch the app
  appDir <- system.file("myapp", "app.R", package = "resvidex")
  shiny::runApp(appDir, display.mode = "normal")
}
