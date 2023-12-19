library("resvidex")

file_path<-system.file("extdata","test_dataset.fasta",package="resvidex")
Classification<-Classify(inputFile=file_path,model=FULL_GENOME)

test_that("A dataframe is produced with the corresponding results ", {
  expect_true(is.data.frame(Classification))
  expect_true(length(colnames(Classification))==8)
  expect_true("Label" %in% colnames(Classification))
})

test_that("Checking if the values of the classification are correct",{
  expect_true(Classification$Length == 15147)
  expect_true(Classification$Clade == "A.2.1")
  expect_true(Classification$N==0)
})
