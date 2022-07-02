library(shiny)
library(tablerDash)
library(shinyWidgets)
library(DT)

profileCard <- tablerProfileCard(
  width = 12,
  title = "SALPHYCON",
  subtitle = "Basic phylogenetics with phruta.",
  background = "https://cromanpa94.github.io/cromanpa/images/FrogMain_right_up.jpg",
  src = "https://raw.githubusercontent.com/cromanpa94/phruta/main/vignettes/logo.png",
  tablerSocialLinks(
    tablerSocialLink(
      name = "repo",
      href = "https://www.facebook.com",
      icon = "github"
    ),
    tablerSocialLink(
      name = "twitter",
      href = "https://www.twitter.com",
      icon = "twitter"
    ),
    tablerSocialLink(
      name = "twitter",
      href = "https://www.twitter.com",
      icon = "glass"
    ),
    tablerSocialLink(
      name = "twitter",
      href = "https://www.twitter.com",
      icon = "mail"
    ),
    tablerSocialLink(
      name = "twitter",
      href = "https://www.twitter.com",
      icon = "head"
    )
  )
)


plotCard <- tablerCard(
  title = "Sequence alignments",
  zoomable = TRUE,
  closable = FALSE,
  #overflow = TRUE,
  options = tagList(
    switchInput(
      inputId = "enable_distPlot",
      label = "Show alignments",
      value = TRUE,
      onStatus = "success",
      offStatus = "danger"
    )
  ),
  plotOutput("distPlot"),
  status = "info",
  statusSide = "left",
  width = 12
)


tableCard <- tablerCard(
  title = "Accession numbers",
  zoomable = TRUE,
  closable = FALSE,
  overflow = TRUE,
  # options = tagList(
  #   switchInput(
  #     inputId = "enable_distTable",
  #     label = "Show table?",
  #     value = TRUE,
  #     onStatus = "success",
  #     offStatus = "danger"
  #   )
  # ),
  DT::dataTableOutput("distTable"),
  status = "info",
  statusSide = "left",
  width = 12
)

  ui = fluidPage(
    #setBackgroundColor("DodgerBlue"),
    useTablerDash(),
    chooseSliderSkin("Modern"),
    #h1(" ", align = "center"),
    #h1(" ", align = "center"),
    #h1(" ", align = "center"),
    div(style = "height:30px"),
    fluidRow(
      column(
        width = 3,
        profileCard,
        tablerCard(
          status = "yellow",
          statusSide = "left",
          width = 12,
          h3("1. Groups"),
          h5("Please input your target species and clades below"),
          textInput("text", h6("Clades"), 
                    value = "Enter text..."),
          textInput("text", h6("Species"), 
                    value = "Enter text..."),
          
          dropdown(
            tags$h3("List of Input"),
            fileInput("file", h5("List of taxa"), width = '80%'),
            style = "unite", icon = icon("gear"),
            status = "warning", width = "300px",
            tooltip = tooltipOptions(title = "Click to see inputs !"),
            animate = animateOptions(
              enter = animations$fading_entrances$fadeInLeftBig,
              exit = animations$fading_exits$fadeOutRightBig
            )
          )
        )
      ),
      column(
        width = 3,
        tablerCard(
          status = "yellow",
          statusSide = "left",
          width = 12,
          h3("2. Genes"),
          h5("Please input your target species and clades below"),
          materialSwitch(
            inputId = "Id079",
            label = "Find genes?", 
            value = TRUE,
            status = "success"
          ),
          sliderInput("slider1", h3("Threshold find genes"),
                      min = 0, max = 100, value = 50),
          textInput("text", h6("Target genes"), 
                    value = "Enter text..."),
          dropdown(
            tags$h3("List of Input"),
            fileInput("file", h5("Select additional genes"), multiple = TRUE),
            style = "unite", icon = icon("gear"),
            status = "warning", width = "300px",
            tooltip = tooltipOptions(title = "Click to see inputs !"),
            animate = animateOptions(
              enter = animations$fading_entrances$fadeInLeftBig,
              exit = animations$fading_exits$fadeOutRightBig
            )
          )
        ),
        tablerCard(
          status = "yellow",
          statusSide = "left",
          width = 12,
          h3("3. Pipeline"),
          awesomeCheckboxGroup("Process", 
                             h5(""), 
                             choices = list("Retrieve" = 0,
                                            "Curate" = 1, 
                                            "Align" = 2, 
                                            "Mask" = 3, 
                                            "RAxML" = 4),
                             selected = 0),
          dropdown(
            tags$h3("List of Input"),
            awesomeCheckbox("checkbox", "Arg1", value = TRUE),
            awesomeCheckbox("checkbox", "Arg2", value = TRUE),
            awesomeCheckbox("checkbox", "Arg3", value = TRUE),
            style = "unite", icon = icon("gear"),
            status = "warning", width = "300px",
            tooltip = tooltipOptions(title = "Click to see inputs !"),
            animate = animateOptions(
              enter = animations$fading_entrances$fadeInLeftBig,
              exit = animations$fading_exits$fadeOutRightBig
            )
          )
          
        ),
        tablerCard(
          status = "yellow",
          statusSide = "left",
          width = 12,
          h3("Run"),
          actionButton("action", "Action", icon = icon("check"))
        )
        #,uiOutput("info"),
        
      ),
      column(
        width = 6,
        tableCard,
        plotCard
      )
    )
  )
  

  
  