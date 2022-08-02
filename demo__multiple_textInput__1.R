library(shiny)
library(shiny.i18n)

i18n <- Translator$new(translation_csvs_path = "translations/")
i18n$set_translation_language("English")

ui <- shinyUI(
  fluidPage(
    
    actionButton("addFilter", "Add Clades", icon=icon("plus", class=NULL, lib="font-awesome")),
    
    uiOutput("filterPage1")
  )
)

server <- function(input, output){
  i <- 0
  
  observeEvent(input$addFilter, {
    i <<- i + 1
    output[[paste("filterPage",i,sep="")]] = renderUI({
      list(
        fluidPage(
          fluidRow(
            column(3, textInput("text", h6(i18n$t("Clades")), 
                                value = "Enter text..."),),
            column(3, actionButton(paste("removeFactor",i,sep=""), "",
                                   icon=icon("times", class = NULL, lib = "font-awesome"),
                                   onclick = paste0("Shiny.onInputChange('remove', ", i, ")")))
          )
        ),
        uiOutput(paste("filterPage",i + 1,sep=""))
      )
    })
  })
  
  observeEvent(input$remove, {
    i <- input$remove
    
    output[[paste("filterPage",i,sep="")]] <- renderUI({uiOutput(paste("filterPage",i + 1,sep=""))})
  })
}

shinyApp(ui, server)