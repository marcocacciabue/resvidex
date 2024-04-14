# library("ranger")
library("resvidex")


file_path<-system.file("extdata","test_dataset.fasta",package="resvidex")

sequence<-ape::read.FASTA(file_path,type = "DNA")

NormalizedData<-kcounter(SequenceData=sequence,model=FULL_GENOME)

calling_null<-ranger::predictions(FULL_GENOME)


PredictedData <- prediction_caller(NormalizedData=NormalizedData,model=FULL_GENOME)


test_that("A dataframe is produced with the corresponding results ", {
  expect_true(is.data.frame(PredictedData))
  expect_true(length(colnames(PredictedData))==8)
  expect_true("Label" %in% colnames(PredictedData))

})

test_that("The number of results in dataframe is equal to number of test sequences", {
  expect_true(length(sequence)==length(PredictedData$Label))

})



test_that("The number of results in dataframe is equal to number of test sequences", {
  expect_true(length(sequence)==length(PredictedData$Label))

})

test_that("stops when QC_value is not a numeric",{
  expect_error(quality_control(PredictedData,model=FULL_GENOME,QC_value = "error"))
})

test_that("stops when Length_value is not a numeric",{
  expect_error(quality_control(PredictedData,model=FULL_GENOME, Length_value = "error"))
})

test_that("stops when N_value is not a numeric",{
  expect_error(quality_control(PredictedData,model=FULL_GENOME, N_value = "error"))
})

test_that("stops if QC_value is not in the correct range",{
  expect_error(quality_control(PredictedData,model=FULL_GENOME, QC_value = 0.1))
  expect_error(quality_control(PredictedData,model=FULL_GENOME, QC_value = 2))
})

test_that("stops if N_value is not in the correct range",{
  expect_error(quality_control(PredictedData,model=FULL_GENOME, N_value = 11))
  expect_error(quality_control(PredictedData,model=FULL_GENOME, N_value = -11))
})

test_that("stops if Length_value is not in the correct range",{
  expect_error(quality_control(PredictedData,model=FULL_GENOME, Length_value = 11))
  expect_error(quality_control(PredictedData,model=FULL_GENOME, Length_value = -11))
})

test_that("stops if NormalizedData is null or missing",{
  expect_error(prediction_caller(NormalizedData = NULL,model=FULL_GENOME))
  expect_error(prediction_caller(model=FULL_GENOME))
})
