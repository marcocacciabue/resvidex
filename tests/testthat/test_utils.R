library(resvidex)

test_that("stops when model is null",{
  expect_error(ModelControl(model = NULL))
})

