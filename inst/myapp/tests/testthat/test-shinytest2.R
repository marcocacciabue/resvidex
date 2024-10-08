library(shinytest2)

test_that("{shinytest2} recording: myapp", {
  app <- AppDriver$new(variant = platform_variant(), name = "myapp", height = 593, 
      width = 979)
  app$set_inputs(FilePrueba = TRUE)
  app$expect_screenshot()
})
