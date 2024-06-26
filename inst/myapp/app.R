
library(shiny)
#library(ranger)
#library(kmer)
#library(ape)
library(DT)
#library(RColorBrewer)
#library(plotly)
library(shinyjs)
options(shiny.maxRequestSize = 5*1024^2)
#library(rintrojs)
library(shinythemes)
#library(magrittr)
#library(dplyr)
#library(shinyjs)
#for mac, without this Rstudio crashes
Sys.setenv(LIBGL_ALWAYS_SOFTWARE=1)
#library(tibble)
library(shinyWidgets)

#library(parallel)

# library(msa)
# library(shinylogs)



ui <-   fluidPage(title = "ReSVidex whole genome version",
  useShinyjs(),
  theme = shinythemes::shinytheme("spacelab"),
  includeScript("www/script.js"),
  includeCSS("www/style.css"),

  div( id="logo",
       img(src="ReSVidex.png",class="logo"),

       ),
  div(id="app_title2","Molecular classification of Respiratory Syncytial Virus sequences"),
    # introjsUI(), # must include in UI
  br(),
  br(),

  div(id="banner_main",
      div( id= "container",
      div( id="row_d_flex",
           div(id= "text-bg", "ReSVidex was developed by Marco Cacciabue and Stephanie Goya. Based on a machine learning classification model,
          it allows the user to identify the RSV lineage for each query sequence."))
           )

      ),

     # div(id="boton_start",actionButton("start", "Start",class = "btn-info")),


     br(),

   div(id="all",

      column(6,   align = "left",
             conditionalPanel(
               condition = '!input.FilePrueba',
               textAreaInput('SequenceData', 'You can paste your sequences in FASTA format into the field below',
                             value = "", placeholder = "",
                             width = "100%"))),
      column(6,  align = "left",
             conditionalPanel(
               condition = '!input.FilePrueba',
             fileInput("file", label = ("Or you can load a query file (multi-fasta format)"),
                         accept = c(".text",".fasta",".fas",".fasta"),width = "100%"))),

      column(12,  align = "center",
             checkboxInput("FilePrueba", "You can also use an example file.", FALSE,
                           width = "100%")),

      column(12, align = "center",
             radioGroupButtons(
               inputId = "select",
               label = "Choose the model according to the length of your sequences
               (FULL_GENOME = 15000 nt, G = 900 nt)",
               choices = c("FULL_GENOME", "G"),
               status = "primary")),
      column(12, align = "center",
             div(id="advanced",
                 checkboxInput("advanceOptions", "Advanced options", FALSE)),
      column(12, align = "center",
        div(
               id="testeo",
               textInput("user", "User name (optional)", "anonymous"),
               checkboxInput("qualityfilter", "classify even if quality of sequence is low? (Not recommended)", FALSE),
               sliderInput("QC_value", "Probability threshold (default 0.4):",
                           min = 0.3, max = 1,
                           value = 0.4, step = 0.05),
               sliderInput("N_value", "Percentage of acceptable ambiguous bases (default 2):",
                           min = 0.1, max = 10,
                           value = 2, step = 0.05),
               sliderInput("Length_value", "Proportion of difference to the expected sequence length (default 0.5): :",
                           min = 0.1, max = 1,
                           value = 0.5, step = 0.05)))),
      column(12, align = "center",
             textOutput("model")),
      column(12, align = "center",
             actionButton("go", "RUN",class = "btn-info")),
      column(4, align = "right",uiOutput("step_button_1")),
      column(4, align = "center",uiOutput("step_button_2")),
      column(4, align = "left",uiOutput("step_button_3")),

      column(6, align = "right",
             actionButton("prv", "Prev", class = "btn-info")),
      div(id="hola",
          column(6, align = "left",
             actionButton("nxt", "Next", class = "btn-info"))),

      br(),

      fluidRow(),
      conditionalPanel(
        condition='output.table!=null && output.table!="A"',
        div(strong("The following sequences have passed the quality test"))),
      div(id="Classification",DT::dataTableOutput("table"),
      conditionalPanel(
        condition='output.table_reject!=null && output.table_reject!=""',
        div(strong("The following sequences have"),strong("NOT",style="color:red"),strong(" passed the quality test"))),
      DT::dataTableOutput("table_reject"),
      conditionalPanel(
          condition='output.table!=null && output.table!=""',
          downloadButton('report',"Generate report (ENG)")),


  )),
  HTML("<hr>"),
  #TODO change repository link and add links to Melina´s and Nahuel´s repositories.
 div(
   id = "footer",
   "Created & Maintained by",
   a("Marco Cacciabue", href = "https://sourceforge.net/u/marcocacciabue/profile/"),
   " Melina Obregón and Nahuel Fenoglio",
 ))



server <- shinyServer(function(input, output, session) {

  values <- reactiveValues(SequenceData_FILE = NULL,
                           step = 1)


  observeEvent(input$advanceOptions,{
    if (input$advanceOptions==FALSE){
      shinyjs::hide(id = "testeo")
    }else{
      shinyjs::show(id = "testeo")
    }
  })

  observeEvent(input$nxt, {
    if (values$step < 3){
      values$step <- values$step + 1}

  })


  observeEvent(input$prv, {
    if (values$step > 1) {
      values$step <- values$step - 1}

  })
 observe({

  if(values$step > 1){
    shinyjs::hide(id = "SequenceData")
   shinyjs::hide(id = "file")
   shinyjs::hide(id = "FilePrueba")

  }else{
   shinyjs::show(id = "SequenceData")
  shinyjs::show(id = "file")
  shinyjs::show(id = "FilePrueba")

  }
   if(values$step == 1){
     shinyjs::hide(id = "select")
     shinyjs::hide(id = "advanced")
     shinyjs::hide(id = "prv")
     shinyjs::hide(id = "model")

   }
   if(values$step == 2){
     shinyjs::show(id = "select")
     shinyjs::show(id = "advanced")
     shinyjs::show(id = "prv")
     shinyjs::show(id = "nxt")
     shinyjs::hide(id = "model")
   }


   if(values$step == 3){
     shinyjs::show(id = "model")
     shinyjs::show(id = "go")
     shinyjs::hide(id = "select")
     shinyjs::hide(id = "advanced")
     shinyjs::hide(id = "testeo")
     shinyjs::hide(id = "nxt")
   }else{
     shinyjs::hide(id = "go")

   }


 })



  observeEvent(input$go, {
    if(length(input$file)==0&(input$SequenceData=="")&(input$FilePrueba==FALSE)){
      showModal(modalDialog(
       title = "Important message", easyClose = TRUE,
        "Please load the fasta file first and then press RUN.
Also, remember that the file must NOT exceed 5 MB in size. Optionally, you can paste the
sequence in the textbox or you use the example file."
     ))}})

  SequenceData_data<- observeEvent(input$SequenceData,{

    req(input$SequenceData)
    #gather input and set up temp file
    SequenceData_tmp <- input$SequenceData
    tmp <- tempfile(fileext = ".fa")


    #this makes sure the fasta is formatted properly
    if (startsWith(SequenceData_tmp, ">")){
      writeLines(SequenceData_tmp, tmp)
    } else {
      writeLines(paste0(">SequenceData\n",SequenceData_tmp), tmp)
    }
    values$SequenceData_FILE<-tmp
  })

  SequenceData_data<- observeEvent(input$file,{
    req(input$file)

    values$SequenceData_FILE<-input$file[1,4]

  })


  data_reactive<- eventReactive(input$go,{
    if (input$FilePrueba==TRUE){
      values$SequenceData_FILE <-  system.file("extdata","test_dataset.fasta",
                                        package = "resvidex", mustWork = TRUE)
    }
    req(values$SequenceData_FILE)
    progress <- shiny::Progress$new()
    on.exit(progress$close())
    progress$set(message = "processing data", value = 0)
    progress$inc(0.2, detail = paste("Reading fasta"))


    tmp<-values$SequenceData_FILE

    SequenceData<-ape::read.FASTA(tmp,type = "DNA")

    model <- model_reactive()$model


    #Calculate k-mer counts from SequenceData sequences
    progress$inc(0.4, detail = paste("Counting kmers"))

    NormalizeData<-resvidex::kcounter(SequenceData,
                                      model)


    data_out <-  resvidex::prediction_caller(NormalizeData,
                                            model=model)
    # data_out<-resvidex::quality_control(model=model,
    #                                    data=data_out)
    list(message="Done!",data_out=data_out)
                })
  output$text <- renderText({
    data_reactive()$message
  })


  data_predicted<-reactive({
    # req(values$SequenceData_FILE)
    model <- model_reactive()$model
    data_out<-data_reactive()$data_out

    data_out<-resvidex::quality_control(model=model,
                                       data=data_out,
                                       QC_value=input$QC_value,
                                       N_value=input$N_value,
                                       Length_value=input$Length_value)
    if(input$qualityfilter==FALSE){
      data_out_filtered<-resvidex::quality_filter(data=data_out)
    }else{
      data_out_filtered<-data_out
    }

    data_out_filtered
  })




  table<-reactive({

    data_out<-data_predicted()

    data_out

  })

  table_pass<-reactive({

    table<-table()
    # table<-table %>% filter(Probability_QC == 1 & N_QC == 1 & Length_QC == 1)
    filter<-(table$Probability_QC == 1 & table$N_QC == 1 & table$Length_QC == 1)
    table<-table[filter,]

    # table<-table[table$Probability_QC == 1,]
  })

  table_reject<-reactive({

    table<-table()
    # table<-table %>% filter(Probability_QC == 0 | N_QC == 0 | Length_QC == 0)

    # table<-table[table$Probability_QC == 0,]
    filter<-(table$Probability_QC == 0 | table$N_QC == 0 | table$Length_QC == 0)
    table<-table[filter,]

  })

  output$table <- DT::renderDataTable({

    col<-"#7AC5CD"
      col2<-"#FF8C00"

      table<-table_pass()


      datatable(table,selection = 'single',
                style = 'bootstrap',
                extensions = 'Buttons',
                options = list(
                  columnDefs = list(list(targets = c(5,7,8), visible = FALSE)),
                  dom = 'Bfrtip',
                  lengthMenu = list(c(5, 15, -1), c('5', '15', 'All')),
                  pageLength = 15,
                  buttons =
                    list('copy', 'print', list(
                      extend = 'collection',
                      buttons = list(
                        list(extend = 'csv', filename = paste(input$file[1,1],"resvidex_results"),sep=""),
                        list(extend = 'excel', filename = paste(input$file[1,1],"resvidex_results"),sep=""),
                        list(extend = 'pdf', filename = paste(input$file[1,1],"resvidex_results"),sep="")),
                      text = 'Download'
                    ),
                    list(
                      extend = "collection",
                      text = 'Show All',
                      action = DT::JS("function ( e, dt, node, config ) {
                                    dt.page.len(-1);
                                    dt.ajax.reload();
                                }")
                    ))
                ))%>%formatStyle("Length","Length_QC",backgroundColor = styleEqual(c(0, 1), c(col2, col)))%>%
        formatStyle("N","N_QC",backgroundColor = styleEqual(c(0, 1), c(col2, col)))%>%
        formatStyle("Probability","Probability_QC",backgroundColor = styleEqual(c(0, 1), c(col2, col)))


  })

  output$table_reject <- DT::renderDataTable({

      col<-"#7AC5CD"
      col2<-"#FF8C00"

      table<-table_reject()


      datatable(table,selection = 'single',
                style = 'bootstrap',
                extensions = 'Buttons',
                options = list(
                  columnDefs = list(list(targets = c(5,7,8), visible = FALSE)),
                  dom = 'Bfrtip',
                  lengthMenu = list(c(5, 15, -1), c('5', '15', 'All')),
                  pageLength = 15,
                  buttons =
                    list('copy', 'print', list(
                      extend = 'collection',
                      buttons = list(
                        list(extend = 'csv', filename = paste(input$file[1,1],"resvidex_results"),sep=""),
                        list(extend = 'excel', filename = paste(input$file[1,1],"resvidex_results"),sep=""),
                        list(extend = 'pdf', filename = paste(input$file[1,1],"resvidex_results"),sep="")),
                      text = 'Download'
                    ),
                    list(
                      extend = "collection",
                      text = 'Show All',
                      action = DT::JS("function ( e, dt, node, config ) {
                                    dt.page.len(-1);
                                    dt.ajax.reload();
                                }")
                    ))
                ))%>%formatStyle("Length","Length_QC",backgroundColor = styleEqual(c(0, 1), c(col2, col)))%>%
        formatStyle("N","N_QC",backgroundColor = styleEqual(c(0, 1), c(col2, col)))%>%
        formatStyle("Probability","Probability_QC",backgroundColor = styleEqual(c(0, 1), c(col2, col)))
  })

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

info_model<-reactive({
  req(input$select)
  model_data<-  model_reactive()$model
  model1_data<-data.frame(Model=model_data$info,
                          date=model_data$date,
                          trees=model_data$num.trees,
                          length=model_data$genome_size,
                          Oob= round(model_data$prediction.error,4))
  return(model1_data)

})
output$model <- renderText({

  model_data<-  model_reactive()$model
  text<- paste0("You have selected the ",
         model_data$info,
         " model, version ",
         model_data$date,
         " designed for sequences close to ",
         model_data$genome_size,
         " nt long. Please press run to continue.")
})

model_reactive <- eventReactive(input$select,{
  if (input$select=="FULL_GENOME"){
    model <- resvidex::FULL_GENOME}
  else{
      model <- resvidex::G
    }
  list(model=model)
})

count_parallel<-function(x,kmer) ({


  library(kmer)
  kcount(x,k= kmer)})

output$report <- downloadHandler(
  # For PDF output, change this to "report.pdf"
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


})



shinyApp(ui, server)
