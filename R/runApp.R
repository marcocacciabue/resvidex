
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
#' resvidex::runShinyApp()
#' }
#'

runShinyApp <- function() {

  # find and launch the app
  appDir <- system.file("myapp", "app.R", package = "resvidex")
  shiny::runApp(appDir, display.mode = "normal")
}
