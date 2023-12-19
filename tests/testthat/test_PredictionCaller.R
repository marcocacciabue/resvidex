# library("ranger")
library("resvidex")


file_path<-system.file("extdata","test_dataset.fasta",package="resvidex")

sequence<-ape::read.FASTA(file_path,type = "DNA")

NormalizedData<-Kcounter(SequenceData=sequence,model=FULL_GENOME)

calling_null<-ranger::predictions(FULL_GENOME)


PredictedData <- PredictionCaller(NormalizedData=NormalizedData,model=FULL_GENOME)


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

