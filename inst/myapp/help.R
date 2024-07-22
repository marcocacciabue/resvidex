####This code handles the modals and some functionality of the app


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

#### Handle help modals for the model selection step
observeEvent(input$model_action_link, {

  showModal(modalDialog(
    title = "Choose model help", easyClose = TRUE,
    "Resvidex comes with two classification models. If you have sequences that span
      the whole viral genome then select the FULL_GENOME model. Sequences are expected to have a length close to 15000 nt.
      If you have sequences that only cover the G gene then select the G model.
      Sequences are expected to have a length close to 900 nt.
      The selected model will be used for all the sequences.
      If you think other gene models would be usefull, please contact the developers."
  ))})


#### Handle help modals for the advance options
observeEvent(input$QC_value_action_link, {

  showModal(modalDialog(
    title = "Advanced options help", easyClose = TRUE,
    "Each classification comes with a probability value, which is the proportion of trees
        that assign the informed clade. The closer this number is to 1 the better the classification is.
        The probability threshold parameter allows to set the mininum probability value to
        consider a classification as valid (proportion). Any classification with a lower value will be set
        as low quality.
        Results below 0.2 will be flagged as unknown, regardless of the probability threshold
        (meaning that the sequences are probably not RSV related)."
  ))})
observeEvent(input$N_value_action_link, {

  showModal(modalDialog(
    title = "Advanced options help", easyClose = TRUE,
    "The number of ambiguous bases present in a sequence can have a negative impact on the
      classification result.
      This parameter controls how many bases of the sequence are allowed to be ambiguous.
      Sequences with more ambiguous bases will be set as low quality.
      The larger the number the more ambiguous bases would be accepted (percentage)."
  ))})

observeEvent(input$Length_value_action_link, {

  showModal(modalDialog(
    title = "Advanced options help", easyClose = TRUE,
    "This parameter controls how much the sequence length can differ
      from the expected sequence length according to the classification model selected (proportion).
      The larger the value the more difference in size would be acceptable."))})

observeEvent(input$qualityfilter_action_link, {

  showModal(modalDialog(
    title = "Advanced options help", easyClose = TRUE,
    "This option forces to show the classification result for all sequences, even those that
      do not meet the quality criteria.
      Have in mind that classification with a probability below 0.2 will be flagged as unknown
      nonetheless (meaning that the sequences are probably not RSV related)."))})
