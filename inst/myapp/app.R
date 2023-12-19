
library(shiny)
library(ranger)
library(kmer)
library(ape)
library(DT)
library(RColorBrewer)
library(plotly)
library(shinyjs)
options(shiny.maxRequestSize = 5*1024^2)
library(rintrojs)
library(shinythemes)
library(magrittr)
library(dplyr)
library(shinyjs)
#for mac, without this Rstudio crashes
Sys.setenv(LIBGL_ALWAYS_SOFTWARE=1)
library(tibble)

library(parallel)

# library(msa)
# library(shinylogs)



ui <-   fluidPage(title = "ReSVidex whole genome version",
  useShinyjs(),
  theme = shinytheme("spacelab"),
  includeScript("www/script.js"),
  includeCSS("www/style.css"),
  div( id="logo",
       img(src="ReSVidex.png",class="logo"),

       ),
  div(id="app_title2","Molecular classification of Respiratory Syncytial Virus sequences (whole genome version)"),
    # introjsUI(), # must include in UI
  br(),
  br(),

  div(id="banner_main",
      div( id= "container",
      div( id="row_d_flex",
           div(id= "text-bg", "ReSVidex was developed by Marco Cacciabue and Stephanie Goya. Based on a machine learning classification model,
          it allows the user to identify the RSV subtype, genotype,
          subgenotype and genetic lineage for each query sequence. This version of the app is for whole genome sequences only"))

           )

      ),

     # div(id="boton_start",actionButton("start", "Start",class = "btn-info")),


     br(),

   div(id="all",

      column(12, align = "center",
             fileInput("file", label = ("Query file (multi-fasta format)"),
                       accept = c(".text",".fasta",".fas",".fasta"))),
      column(12, align = "center",
             textInput("user", "User name (optional)", "anonymous")),
      column(12, align = "center",
             actionButton("go", "RUN",class = "btn-info")),
      fluidRow(),
      div(id="Classification",DT::dataTableOutput("table"),

   hidden(div(id="Results",align = "center",
       downloadButton('report',"Generate report (ENG)"))),


  )),
  HTML("<hr>"),
 div(
   id = "footer",
   "Created & Maintained by",
   a("Marco Cacciabue", href = "https://sourceforge.net/u/marcocacciabue/profile/"),
   " and Stephanie Goya",
 ))



server <- shinyServer(function(input, output, session) {

  observeEvent(input$go, {
    req(input$file)
    shinyjs::showElement(id= "Results")
  })


  observeEvent(input$go, {
    if(length(input$file)==0){
      showModal(modalDialog(
        title = "Important message", easyClose = TRUE,
        "Please load the fasta file first and then press RUN.
Also, remember that the file must NOT exceed 5 MB in size.
"
      ))}})


  data_reactive<- eventReactive(input$go,{
    req(input$file)
    progress <- shiny::Progress$new()
    on.exit(progress$close())
    progress$set(message = "processing data", value = 0)
    progress$inc(0.2, detail = paste("Reading fasta"))



    #Read input file in fasta format
    query <- read.FASTA(input$file[1,4], type = "DNA")

    model <- readRDS("models/FULL_GENOME.rds")
    if (length(query)>1000){

      progress$inc(0.4, detail = paste("Counting kmers in multithread mode"))
      cores<-detectCores()-1

      step<-ceiling(length(query)/cores)
      last<-step
      first<-1
      query_split<-0
      #split query sequences
      for (j in 1:cores) {
        #check to get the correct number of sequences at the end
        if ((first+step)<length(query)){
          query_split[j]<-list(query[first:last])
          first<-first+step
          last<-last+step}else{
            query_split[j]<-list(query[first:length(query)])

          }

      }
      #create core cluster
      cl <- makeCluster(detectCores()-1)
      # progress$inc(0.6, detail = paste("Kmer counting in multithread mode"))

      #Use parallel function to send each split dataset to a different thread.
      query_count_split<-parLapply(cl,query_split,count_parallel,model$kmer)
      stopCluster(cl)
      progress$inc(0.8, detail = paste("merging outputs"))

      #Combine the results from the different threads in a single dataset
      query_count<-as.numeric()
      for (i in 1:length(query_count_split))  {
        query_count<-rbind(query_count, query_count_split[[i]])
      }


      #normalize Kmer counts acording to kmer size and sequence length
      genome_length<-0
      n_length<-0
      for(H in 1:length(query_count[,1])){

        k<-query[H]
        k<-as.matrix(k)
        query_count[H,]<- query_count[H,]*model$kmer/(length(k))
        genome_length[H]<-length(k)
        n_length[H]<-round(100*base.freq(k,all = TRUE)[15],2)
      }}
    else{

      #Calculate k-mer counts from query sequences
      # progress$inc(0.4, detail = paste("Runing in Single-thread mode"))
      progress$inc(0.4, detail = paste("Counting kmers in single-thread mode"))
      query_count<-kcount(query , k=model$kmer)
      genome_length<-0
      n_length<-0
      for(i in 1:length(query_count[,1])){

        k<-query[i]
        k<-as.matrix(k)
        query_count[i,]<- query_count[i,]*model$kmer/(length(k))
        genome_length[i]<-length(k)
        n_length[i]<-round(100*base.freq(k,all = TRUE)[15],2)
      }

    }

    progress$inc(0.9, detail = paste("Predicting"))


    calling<-predict(model,query_count)
    #Run the predict method from de Ranger package, retaining the classification result from each tree in the model (to calculate a probability value for each classification)
    calling_all<-predict(model,query_count,predict.all = TRUE)
    probability <- rep(0, length(calling_all$predictions[,1]))

    for (i in 1:length(calling_all$predictions[,1])) { #El siguiente paso parece largo pero guarda el nombre de la clase con mas probabilidad
      #extract predictions for each query sample in temp vector,
      #count the number of correct predictions and divide by number of trees to get a probability.
      temp<-calling_all$predictions[i,]
      probability[i] <- sum(temp==which(model$forest$levels==calling$predictions[i]))/model$num.trees

    }




    N_QC<-(n_length<0.5)
    Length_QC<-(genome_length<16500)&(genome_length>14000)

    temp1<-strsplit(as.character(calling$prediction), split="[.]")

    Subtype = unlist(lapply(temp1, function(l) l[[1]]))
    # Subtype = calling$prediction
    #
    Clade = calling$prediction
    #
    # temp1<-strsplit(as.character(Subtype), split="G")
    #
    # Subtype = unlist(lapply(temp1, function(l) l[[2]]))






    data_out <- data.frame(Label= row.names(query_count),Subtype=Subtype,Clade=Clade, Probability=probability,Length=genome_length,Length_QC=Length_QC,N=n_length,N_QC=N_QC)

  list(message="Done!",data_out=data_out)
                })
  output$text <- renderText({
    data_reactive()$message
  })

  table<-reactive({

    data_out<-data_reactive()$data_out

    data_out

    })

  output$table <- DT::renderDataTable({

    col<-brewer.pal(5,"Blues")
    col2<-brewer.pal(5,"Reds")

    table<-table()
    datatable(table,selection = 'single',
              options = list(
                columnDefs = list(list(targets = c(6,8), visible = FALSE)),
                dom = 'Bfrtip',
                lengthMenu = list(c(5, 15, -1), c('5', '15', 'All')),
                pageLength = 15,
                buttons =
                  list('copy', 'print', list(
                    extend = 'collection',
                    buttons = list(
                      list(extend = 'csv', filename = paste(input$file[1,1],"ReSVidex_results"),sep=""),
                      list(extend = 'excel', filename = paste(input$file[1,1],"ReSVidex_results"),sep=""),
                      list(extend = 'pdf', filename = paste(input$file[1,1],"ReSVidex_results"),sep="")),
                    text = 'Download'
                  ))))%>%
      formatStyle("Length","Length_QC",
                  backgroundColor = styleEqual(c(0, 1), c(col2[3], col2[1])))%>%
      formatStyle("N","N_QC",backgroundColor = styleEqual(c(0, 1), c(col2[3], col2[1])))
    })

  # output$plot2 <- renderPlotly({
  #   Fast_tree_reactive()
  #
  # })



# model_table<-reactive({
#   model1<-model_reactive()$model
#   model1_data<-data.frame(Model=model1$info,date=model1$date,trees=model1$num.trees,Oob= round(model1$prediction.error,4))
#
#   model_data
# })
#
# output$table2 <- DT::renderDataTable({
#   col<-brewer.pal(5,"Blues")
#   col2<-brewer.pal(5,"Reds")
#
#   table<-model_table()
#   datatable(table,selection = 'single',
#             options = list(
#               columnDefs = list(list(targets = c(5,7), visible = FALSE)),
#               dom = 'Bfrtip',
#               lengthMenu = list(c(5, 15, -1), c('5', '15', 'All')),
#               pageLength = 15,
#               buttons =
#                 list('copy', 'print', list(
#                   extend = 'collection',
#                   buttons = list(
#                     list(extend = 'csv', filename = paste(input$file[1,1],"ReSVidex_results"),sep=""),
#                     list(extend = 'excel', filename = paste(input$file[1,1],"ReSVidex_results"),sep=""),
#                     list(extend = 'pdf', filename = paste(input$file[1,1],"ReSVidex_results"),sep="")),
#                   text = 'Download'
#                 )
#                 )
#             ))%>% formatStyle("Rambaut","FLAG",
#                               backgroundColor = styleEqual(c(0, 1), c(col[1], col[3])))%>%
#                             formatStyle("Length","Length_QC",
#                              backgroundColor = styleEqual(c(0, 1), c(col2[3], col2[1])))%>%
#                             formatStyle("N","N_QC",backgroundColor = styleEqual(c(0, 1), c(col2[3], col2[1])))
#
#
# })

output$report <- downloadHandler(


  filename = "report.html",
  content = function(file) {
    # Copy the report file to a temporary directory before processing it, in
    # case we don't have write permissions to the current working dir (which
    # can happen when deployed).
    tempReport <- file.path(tempdir(), "report.rmd")
    file.copy("report.rmd", tempReport, overwrite = TRUE)

    # Set up parameters to pass to Rmd document

    # Knit the document, passing in the `params` list, and eval it in a
    # child of the global environment (this isolates the code in the document
    # from the code in this app).
    rmarkdown::render(tempReport, output_file = file)

  }
)
version<-reactive({
  version<-0.2
  return(version)})

count_parallel<-function(x,kmer) ({


  library(kmer)
  kcount(x,k= kmer)})

})



shinyApp(ui, server)
