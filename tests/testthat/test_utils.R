library(resvidex)


test_that("Control that the checks steps for the model perform as expected",{
  expect_error(model_control(model = NULL))
  expect_error(model_control(model = "FULL_GENOME"))
  MOCKUP_MODEL<-FULL_GENOME
  names(MOCKUP_MODEL)<- rep("A",18)
  expect_error(model_control(model = MOCKUP_MODEL))
  names(MOCKUP_MODEL)<- c(rep("A",17),"info")
  expect_error(model_control(model = MOCKUP_MODEL))

  })



