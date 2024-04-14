
#' prediction_caller
#'
#' Performs the prediction and computes probability values.
#'
#' @param NormalizedData A list of 3 elements: normalized k-mer counts, genome length and contents of undefined bases.Produced by the [kcounter()] function
#' @inheritParams kcounter
#' @param QC_unknown numeric value from 0 to 1. Stringent filter, do not classify below this probability score (default = 0.2)
#' @return Data.frame with the classification results and quality checks.
#' The output has the following properties:
#' * Each row corresponds to one sample sequence.
#' * `Label` is the name of the sequence.
#' * `Clade` is the corresponding prediction.
#' * `Probability` is the proportions of trees that agreed with the Clade result. Values between 0 to 1.
#' * `Probability_QC` a logical value. If `TRUE` the sequence passed the quality filter for probability. Run [quality_control()] to fill this column.
#' * `Length` Sequence length.
#' * `Length_QC` a logical value. If `TRUE` the sequence passed the quality filter for length.Run [quality_control()] to fill this column
#' * `N` proportions of undefined bases in the sequence. The lower the better.
#' * `N_QC` a logical value. If `TRUE` the sequence passed the quality filter for undefined bases. Run [quality_control()] to fill this column
#'
#' @export
#' @importFrom ranger predictions
#' @importFrom stats predict
#' @examples
#'
#'
#'
#' file_path<-system.file("extdata","test_dataset.fasta",package="resvidex")
#'
#' sequence<-ape::read.FASTA(file_path,type = "DNA")
#'
#' NormalizedData <- kcounter(SequenceData=sequence,model=FULL_GENOME)
#'
#' PredictedData <- prediction_caller(NormalizedData=NormalizedData,model=FULL_GENOME)
#'

prediction_caller<-function(NormalizedData,
                           model,
                           QC_unknown=0.3){

   if (is.null(NormalizedData) | missing(NormalizedData)){
    stop("'NormalizedData' must be indicated")
  }

  model_control(model)

  calling<-predict(model,
                               NormalizedData$DataCount)
  #Run the predict method from de Ranger package, retaining the classification result from each tree in the model (to calculate a probability value for each classification)
  calling_all<-predict(model,
                                   NormalizedData$DataCount,
                                   predict.all = TRUE)
  probability <- rep(0, length(calling_all$predictions[,1]))

  for (i in 1:length(calling_all$predictions[,1])) {
    #extract predictions for each SequenceData sample in temp vector,
    #count the number of correct predictions and divide by number of trees to get a probability.
    temp<-calling_all$predictions[i,]
    probability[i] <- sum(temp==which(model$forest$levels==calling$predictions[i]))/model$num.trees

  }


  # QualityList<-quality_control(n_length=NormalizedData$n_length,
  #                          genome_length=NormalizedData$genome_length,
  #                          probability,
  #                          model)
  samples<-rep(0,length(row.names(NormalizedData$DataCount)))
  data<-data.frame(Label= row.names(NormalizedData$DataCount),
             Clade=calling$prediction,
             Probability=probability,
             Length=NormalizedData$genome_length,
             Length_QC=samples,
             N=NormalizedData$n_length,
             N_QC=samples,
             Probability_QC=samples)


  filter<-data$Probability<QC_unknown
  data$Clade <- as.character(data$Clade)
  data$Clade[filter]<-"unknown"


  return(data)
}



#' quality_control
#'
#' @param data data.frame obtained with [prediction_caller()]
#' @param QC_value numeric value from 0.3 to 1. (default = 0.4)
#' @param Length_value numeric value from 0 to 1. Proportion of difference to the expected sequence length. (default = 0.5)
#' @param N_value numeric value from 0 to 100. Percentage of acceptable ambiguous bases. (default = 2)
#' @inheritParams kcounter
#' @return A list with three logical vectors. In each case TRUE means pass.
#'
#' @export
#'
#' @examples
#'
#' file_path<-system.file("extdata","test_dataset.fasta",package="resvidex")
#'
#' sequence<-ape::read.FASTA(file_path,type = "DNA")
#'
#' NormalizedData <- kcounter(SequenceData=sequence,model=FULL_GENOME)
#'
#' PredictedData <- prediction_caller(NormalizedData=NormalizedData,model=FULL_GENOME)
#'
#' quality_control(PredictedData,model=FULL_GENOME)
#'
#'
quality_control<-function(data,
                         QC_value=0.4,
                         Length_value=0.5,
                         N_value=2,
                         model){
  model_control(model)

  if(!is.numeric(QC_value)){
    stop("`QC_value` must be numeric")
  }
  if(!is.numeric(Length_value)){
    stop("`Length_value` must be numeric")
  }
  if(!is.numeric(N_value)){
    stop("`N_value` must be numeric")
  }

  if(QC_value>1 | QC_value<0.2){
    stop("`QC_value` must be numeric and between 0.2 to 1")
  }

  if(N_value>10 | N_value<0){
    stop("`N_value` must be numeric and between 0 to 10")
  }

  if(Length_value>1 | Length_value<0){
    stop("`Length_value` must be numeric and between 0 to 1")
  }

  data$N_QC<-(data$N<N_value)

  if ("RSV_full_genome"==model$info){
    data$Length_QC<-(data$Length>(1-Length_value)*model$genome_size)&(data$Length<(1+Length_value)*model$genome_size)
  }

  data$Probability_QC<-data$Probability>QC_value


  return(data)

}








#' quality_filter
#'
#' Change Clade definition to "LowQuality" in samples with at least one FLAG from [quality_control()].
#'
#' @param data data.frame obtained with [quality_control()]
#'
#' @return data.frame
#' @export
#'
#' @examples
#'
#' file_path<-system.file("extdata","test_dataset.fasta",package="resvidex")
#'
#' sequence<-ape::read.FASTA(file_path,type = "DNA")
#'
#' NormalizedData <- kcounter(SequenceData=sequence,model=FULL_GENOME)
#'
#' PredictedData <- prediction_caller(NormalizedData=NormalizedData,model=FULL_GENOME)
#'
#' PredictedData <- quality_control(PredictedData,model=FULL_GENOME)
#'
#' PredictedData <- quality_filter(PredictedData)
#'
quality_filter<- function(data){

  filter<-!(data$Length_QC & data$N_QC & data$Probability_QC)
  filter<- filter & (data$Clade!="unknown")
  data$Clade <- as.character(data$Clade)
  data$Clade[filter]<-"LowQuality"


  return(data)
}


