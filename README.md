Marco Cacciabue, Nahuel Fenoglio, Melina Obregón

<!-- README.md is generated from README.Rmd. Please edit that file -->

# **ReSVidex**: <img src='man/figures/hex.png' style="float:right; height:200px;" /> Molecular classification of Respiratory Syncytial Virus sequences

<!-- badges: start -->

[![DOI](https://zenodo.org/badge/COMPLETE!!)](https://zenodo.org/badge/latestdoi/COMPLETE!!)
[![](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)

<!-- badges: end -->

If you have a working R and Rstudio setup you can install the released
version of **ReSVidex** from [GitHub](https://github.com/) with:

``` r
if (!require("remotes", quietly = TRUE))
  install.packages("remotes")
  
remotes::install_github("marcocacciabue/resvidex")
```

This could take several minutes depending on your system and
installation. Only the first time it runs.

Alternatively, you can download the repository as a .zip file and
install it manually with Rstudio.

## **ReSVidex** is an R package

This means that users that prefer working directly in an R console can
use some of the exported functions. The easiest way is to use the
wrapper funtion “Classify()”

``` r
#load the library
library(resvidex)

# Indicate the file path to the fasta file to use.If your file is in your working directory you need to simply indicate the file name. In this case, we use a test file provided with the package itself. 

file_path<-system.file("extdata","test_dataset.fasta",package="resvidex")

# Use the wrapper function. You can change the classification model and pass other arguments
Classify(inputFile=file_path,model=FULL_GENOME)

#If you want to save the results in a file in your working directory, you can run the pipeline and
#save it as a variable to export
Classification_Print<-Classify(inputFile=file_path,model=FULL_GENOME)
utils::write.csv2(Classification_Print,"Classification_file.csv")
```

For a more detailed workflow the user can use the exported functions of
the package.

``` r
# First we indicate the location of the fasta file. In this case, we use a test file provided with the package itself.
file_path<-system.file("extdata","test_dataset.fasta",package="resvidex")

# We load the sequences
sequence<-ape::read.FASTA(file_path,type = "DNA")

# We the count and normalize the k-mers
NormalizedData <- Kcounter(SequenceData=sequence,model=FULL_GENOME)

# We perform the classification
PredictedData <- PredictionCaller(NormalizedData=NormalizedData,model=FULL_GENOME)

# We add the quality FLAGs
PredictedData <- QualityControl(PredictedData,model=FULL_GENOME)

# We adjust the classification according to the FLAGs present for each sample:
PredictedData <- Quality_filter(PredictedData)

# The PredictedData dataframe contains the classifications

PredictedData
```
