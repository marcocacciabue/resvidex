

#' ModelControl
#' Utility function to check the classification model object
#'
#' @param model  random forest classification model. Must be FULL_GENOME. See [FULL_GENOME].
#'
#' @return warnings
#'
#' @export
#'
#' @examples
#' ModelControl(FULL_GENOME)
ModelControl<- function(model){

  if (is.null(model)){
    stop("Model argument must be indicated and cannot be null. Try model=FULL_GENOME")
  }

  if (!"ranger" %in% methods::is(model)){
    stop("Model must be a ranger object. Try model=FULL_GENOME")
  }

  if (!"info" %in% names(model)){
    stop("Model must include the info object. Try model=FULL_GENOME")
  }
  if (!"date" %in% names(model)){
    stop("Model must include the date object. Try model=FULL_GENOME")
  }


}


#' Ignore unused imports
#'
#' @return nothing
#'
#'
ignore_unused_imports <- function() {
  # elminate NOTE y R CMD CHECK as suggested in https://r-pkgs.org/dependencies-in-practice.html
  DT::dataTableOutput
  bslib::bootstrap
  shinyWidgets::actionGroupButtons
  shinyjs::click
  tibble::add_row
  rmarkdown::clean_site
  shiny::actionButton
  shinythemes::shinytheme
  rintrojs::introjs
  }
