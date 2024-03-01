Marco Cacciabue, Nahuel Fenoglio, Melina Obregón

<!-- README.md is generated from README.Rmd. Please edit that file -->

# **ReSVidex**: <img src='man/figures/hex.png' style="float:right; height:200px;" /> Molecular classification of Respiratory Syncytial Virus sequences

<!-- badges: start -->

[![DOI](https://zenodo.org/badge/COMPLETE!!)](https://zenodo.org/badge/latestdoi/COMPLETE!!)
[![](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)

[![R-CMD-check](https://github.com/marcocacciabue/resvidex/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/marcocacciabue/resvidex/actions/workflows/R-CMD-check.yaml)
<!-- badges: end --> If you have a working R and Rstudio setup you can
install the released version of **ReSVidex** from
[GitHub](https://github.com/) with:

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
## :whale: Docker images available

### **resvidex** as a shiny app in docker

Another way to run **resvidex** as a shiny app is to use the docker
image. Follow these steps:

1.  If you don´t already have it, install docker:
    <https://www.docker.com/get-started>.

2.  Open a terminal and run the following:

``` bash
docker pull cacciabue/resvidex:shiny
```

and wait for the image to download. You only have to run this command
the first time, or whenever you want to check for updates.

3.  Once the downloading is complete run the following:

``` bash
docker run -d --rm -p 3838:3838 cacciabue/resvidex:shiny
```

4.  Finally, open your favorite browser and go to
    <http://localhost:3838/>
5.  The app should be up and running in your browser. Load the fasta
    file and press RUN.
6.  You can save a report using the corresponding button.

### **resvidex** in a docker image with all dependecies allready installed

For more reproducibility a fully operational environment is available to
work directly in docker:

1.  If you don´t already have it, install docker:
    <https://www.docker.com/get-started>.

2.  Open a terminal, go to the directory where the fasta files are
    stored and run the following:

``` bash
docker pull cacciabue/resvidex:cli
```

3.  Once the downloading is complete run the following:

``` bash
#for WINDOWS 
docker run -it --rm --volume %cd%:/nexus cacciabue/resvidex:cli

#for unix/MAC
docker run -it --rm --volume $(pwd):/nexus cacciabue/resvidex:cli
```

4.  Now you can run

``` bash
setwd('nexus')

#Call the 'resvidex' library
library(resvidex)

# Indicate the file path to the fasta file to use.If your file is in your working directory you need to simply indicate the file name. In this case, we use a test file provided with the package itself. 

file_path<-system.file("extdata","test_dataset.fasta",package="resvidex")

# Use the wrapper function. You can pass other arguments
Classification<-Classify(inputFile=file_path,model=FULL_GENOME)
Classification

#if you want to export the prediction
utils::write.csv2(Classification,'Classification_file.csv')

# This command saves a file in the working directory as "Results.csv" by default. You can change the name file setting the "outputFile" parameter.

# To exit the container just run

q()
```

5.  Alternatively you can perform step 3 and 4 in one command like this:

``` bash

#for WINDOWS 

docker run --rm --volume %cd%:/nexus cacciabue/resvidex:cli R -e "setwd('nexus');library('resvidex');Classification<-Classify(inputFile='test_dataset.fasta',model=FULL_GENOME);utils::write.csv2(Classification,'Classification_file.csv')"

#for unix/MAC

docker run --rm --volume $(pwd):/nexus cacciabue/resvidex:cli R -e "setwd('nexus');library('resvidex');Classification<-Classify(inputFile='test_dataset.fasta',model=FULL_GENOME);utils::write.csv2(Classification,'Classification_file.csv')"


# USER SHOULD CHANGE test_dataset.fasta for the correct file name
