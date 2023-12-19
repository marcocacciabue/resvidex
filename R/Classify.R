
#' Resvidex pipeline
#'
#' Wrapper function that performs all the recommended step. This includes
#' \describe{
#'   \item{Kcounter}{# Count Kmers and normalize data}
#'   \item{PredictionCaller}{Run prediction pipeline}
#'   \item{QualityControl}{Check Quality of the input data and classification results}
#'   \item{Quality_filter}{For sequences with any FLAG present set result Clade to LowQuality}
#' }
#'
#' @param inputFile string path relative to the working directory of the input file. Must be in fasta format.
#' @inheritParams QualityControl
#'
#' @return a dataframe
#' @export
#'
#' @examples
#'
#'
#' file_path<-system.file("extdata","test_dataset.fasta",package="resvidex")
#'
#'
#' Classification<-Classify(inputFile=file_path,model=FULL_GENOME)
#'
#' #the variable Classification has now all the sequences classified
#' Classification
#'
#' \dontrun{
#' #if you want to export the prediction
#' utils::write.csv2(Classification,"Classification_file.csv")
#' }
Classify<-function(inputFile,
                           model,
                           QC_value=0.4,
                           Length_value=0.5,
                           N_value=2){

  sequence<-ape::read.FASTA(inputFile,type = "DNA")

  # Count Kmers and normalize data

  NormalizedData <- Kcounter(SequenceData=sequence,model=model)
  #  Run prediction pipeline

  PredictedData <- PredictionCaller(NormalizedData=NormalizedData,model=model)

  #  Check Quality of the input data and classification results
  PredictedData <- QualityControl(PredictedData,
                                  model=model,
                                  QC_value=QC_value,
                                  Length_value=Length_value,
                                  N_value=N_value)
  # For sequences with any FLAG present set result Clade to LowQuality

  PredictedData <- Quality_filter(PredictedData)

  return(PredictedData)

}
