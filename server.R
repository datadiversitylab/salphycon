

server = function(input, output, session) {
  tan <- read.csv("data/go.csv")
  
  observeEvent(input$selected_language, {
    # This print is just for demonstration
    print(paste("Language change!", input$selected_language))
    # Here is where we update language in session
    shiny.i18n::update_lang(session, input$selected_language)
  })
  
  ## Tables need to be editable
  ## https://stackoverflow.com/questions/70155520/how-to-make-datatable-editable-in-r-shiny
  
  output$distTable <-
    DT::renderDataTable(tan,
                        extensions = 'Buttons',
        options = list(scrollX = TRUE,
                       pageLength = 10,
                       searching = FALSE,
                       dom = 'Bfrtip',
                       buttons = c('csv', 'excel')),
        rownames = FALSE)
  
  
  output$distPlot <- renderPlot({
    if (input$enable_distPlot) hist(rnorm(100))
  })
  
  output$info <- renderUI({
    tablerInfoCard(
      width = 12,
      value = paste0(input$totalStorage, "GB"),
      status = "success",
      icon = "database",
      description = "Total Storage Capacity"
    )
  })
  
  
  output$progress <- renderUI({
    tagList(
      tablerProgress(value = input$knob, size = "xs", status = "yellow"),
      tablerProgress(value = input$knob, status = "red", size = "sm")
    )
  })
  
}
