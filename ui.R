library(shiny)
library(tablerDash)
library(shinyWidgets)
library(DT)
library(phruta)
library(shiny.i18n)

profileCard <- tablerProfileCard(
  width = 12,
  title = "SALPHYCON",
  subtitle = "Basic phylogenetics with phruta",
  background = "https://cromanpa94.github.io/cromanpa/images/FrogMain_right_up.jpg",
  src = "img/salphycon_full.png",
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

i18n <- Translator$new(translation_csvs_path = "translations/")
i18n$set_translation_language("English")

ui = tablerDashPage(
  title = "Salphycon",
  enable_preloader = FALSE,
  loading_duration = 2,
  navbar = tablerDashNav(
    h3(code("Salphycon"), "- phylogentics with", code("phruta")),
    id = "mymenu",
    src = "https://raw.githubusercontent.com/cromanpa94/phruta/main/vignettes/logo.png",
    navMenu = tablerNavMenu(
      tablerNavMenuItem(
        tabName = i18n$t("Home"),
        icon = "home",
        "Home"
      ),
      tablerNavMenuItem(
        tabName = "Settings",
        icon = "check",
        "Settings"
      ),
      tablerNavMenuItem(
        tabName = "Sampling",
        icon = "box",
        "Sampling"
      ),
      tablerNavMenuItem(
        tabName = "Sequences",
        icon = "box",
        "Sequences"
      ),
      tablerNavMenuItem(
        tabName = "Phylogenetics",
        icon = "box",
        "Phylogenetics"
      ),
      tablerNavMenuItem(
        tabName = "TimeDating",
        icon = "box",
        "Time-dating"
      ),
      tablerNavMenuItem(
        tabName = "About",
        icon = "box",
        "About"
      )
    )
  ),
  
  footer = tablerDashFooter(
    copyrights = "NOTE"
  ),
  
  body = tablerDashBody( 
    tablerTabItems(
      tablerTabItem(
        tabName = i18n$t("Home"),
        fluidPage(
          shiny.i18n::usei18n(i18n),
          fluidRow(
            column(
              width = 3,
              profileCard,
              tablerBlogCard(
                #title = "Blog Card",
                #author = "David",
                #date = "Today",
                #href = "https://www.google.com",
                #src = "https://preview.tabler.io/demo/photos/matt-barrett-339981-500.jpg",
                #avatarUrl = "https://image.flaticon.com/icons/svg/145/145842.svg",
                width = 12,
                prettyRadioButtons(
                  width = 12,
                  inputId = "selected_language",
                  label = i18n$t("Language:"), 
                  choices = i18n$get_languages(),
                  selected = i18n$get_key_translation(),
                  icon = icon("check"), 
                  bigger = TRUE,
                  status = "info",
                  animation = "jelly"
                )
              )
              
              #,
              # pickerInput('selected_language',
              #             i18n$t("Change language"),
              #             choices = i18n$get_languages(),
              #             selected = i18n$get_key_translation())
            ),
            column(
              h6(i18n$t("Under construction")),
              width = 3,
              #h6(i18n$t("Under construction..."))#,
              # selectInput('selected_language',
              #             i18n$t("Change language"),
              #             choices = i18n$get_languages(),
              #             selected = i18n$get_key_translation())
            )
          )
        ),
      ),
      tablerTabItem(
        tabName = "Settings",
        fluidPage(
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
              profileCard
            ),
            column(
              width = 3,
              tablerCard(
                status = "yellow",
                statusSide = "left",
                width = 12,
                h3("1. Taxa"),
                h5(i18n$t("Please input your target species and clades below")),
                
                # Add Clades or Species text
                textInput("addTaxa", "Add clades or species", value = "", width = NULL, placeholder = "Taxa"),
                uiOutput("filterPage1"),
                
                # textInput("text", h6(i18n$t("Clades or Species")), 
                #           value = "Enter text..."),
                # textInput("text", h6(i18n$t("Species")), 
                #           value = "Enter text..."),
                
                dropdown(
                  tags$h3("List of Input"),
                  fileInput("fileTaxa", h5("List of taxa"), width = '80%',
                            accept = c(
                                      "text/csv",
                                      "text/comma-separated-values,text/plain",
                                       ".csv")),
                  style = "unite", icon = icon("cogs"),
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
              fluidRow(
                tablerCard(
                  status = "yellow",
                  statusSide = "left",
                  width = 12,
                  h3("2. Genes"),
                  # h5(i18n$t("Please input your target genes below")),
                  # materialSwitch(
                  #   inputId = "findGenes",
                  #   label = i18n$t("Find genes?"), 
                  #   value = TRUE,
                  #   status = "success"
                  # ),
                  sliderInput("sliderGenes", h6(i18n$t("Threshold find genes")),
                              min = 0, max = 100, value = 50),
                 # textInput("genesText", h6(i18n$t("Target genes")), 
                  #          placeholder = "Genes"),
                  # dropdown(
                  #   tags$h3("List of Input"),
                  #   fileInput("fileGenes", h5("Select additional genes"), multiple = TRUE),
                  #   style = "unite", icon = icon("cogs"),
                  #   status = "warning", width = "300px",
                  #   tooltip = tooltipOptions(title = "Click to see inputs !"),
                  #   animate = animateOptions(
                  #     enter = animations$fading_entrances$fadeInLeftBig,
                  #     exit = animations$fading_exits$fadeOutRightBig
                  #   )
                  # )
                )
              )
              
            ),
            
            column(
              width = 3,
              fluidRow(
                tablerCard(
                  status = "yellow",
                  statusSide = "left",
                  width = 12,
                  h3(i18n$t("3. Tasks")),
                  awesomeCheckboxGroup("Process", 
                                       h5(""), 
                                       choices = list("Retrieve" = 0,
                                                      "Curate" = 1, 
                                                      "Align" = 2, 
                                                      "Mask" = 3, 
                                                      "RAxML" = 4),
                                       selected = 0)
                  #,
                  # dropdown(
                  #   tags$h3("List of Input"),
                  #   awesomeCheckbox("checkbox", "Arg1", value = TRUE),
                  #   awesomeCheckbox("checkbox", "Arg2", value = TRUE),
                  #   awesomeCheckbox("checkbox", "Arg3", value = TRUE),
                  #   style = "unite", icon = icon("cogs"),
                  #   status = "warning", width = "300px",
                  #   tooltip = tooltipOptions(title = "Click to see inputs !"),
                  #   animate = animateOptions(
                  #     enter = animations$fading_entrances$fadeInLeftBig,
                  #     exit = animations$fading_exits$fadeOutRightBig
                  #   )
                  # )
                  
                ),
                tablerCard(
                  status = "yellow",
                  statusSide = "left",
                  width = 12,
                  h3("Run"),
                  actionButton("action", "Action", icon = icon("check"))
                )
              )
              
            )
            
          )
          
        )
      ),
      tablerTabItem(
        tabName = "Sampling",
        fluidPage(
          useTablerDash(),
          chooseSliderSkin("Modern"),
          div(style = "height:30px"),
          fluidRow(
            column(
              width = 3,
              profileCard
            ),
            column(
              width = 3,
              tablerStatCard(
                value = 1,
                title = "Species",
                #trend = -10,
                width = 12
              ),
              tablerStatCard(
                value = 1,
                title = "Sequences",
                #trend = -10,
                width = 12
              ),
              tablerStatCard(
                value = 1,
                title = "Gene regions",
                #trend = -10,
                width = 12
              )
            ),
            column(
              width = 6,
              tableCard,
            )
          )
        )
        #fluidPage(plotCard)
      ),
      tablerTabItem(
        tabName = "Sequences",
        fluidPage(
          useTablerDash(),
          chooseSliderSkin("Modern"),
          div(style = "height:30px"),
          fluidRow(
            column(
              width = 3,
              profileCard
            ),
            column(
              width = 3,
              tablerStatCard(
                value = 1,
                title = "Species",
                #trend = -10,
                width = 12
              ),
              tablerStatCard(
                value = 1,
                title = "Sequences",
                #trend = -10,
                width = 12
              ),
              tablerStatCard(
                value = 1,
                title = "Gene regions",
                #trend = -10,
                width = 12
              )
            ),
            column(
              width = 6,
              plotCard,
            )
          )
        )
        #fluidPage(plotCard)
      ),
      tablerTabItem(
        tabName = "Phylogenetics",
        fluidPage(
          useTablerDash(),
          chooseSliderSkin("Modern"),
          div(style = "height:30px"),
          fluidRow(
            column(
              width = 3,
              profileCard
            ),
            column(
              width = 3,
              h6("Under construction...")
            )
          )
        )
      ),
      tablerTabItem(
        tabName = "TimeDating",
        fluidPage(
          useTablerDash(),
          chooseSliderSkin("Modern"),
          div(style = "height:30px"),
          fluidRow(
            column(
              width = 3,
              profileCard
            ),
            column(
              width = 3,
              h6("Under construction...")
            )
          )
        )
      ),
      tablerTabItem(
        tabName = "About",
        fluidPage(
          useTablerDash(),
          chooseSliderSkin("Modern"),
          div(style = "height:30px"),
          fluidRow(
            column(
              width = 3,
              profileCard
            ),
            column(
              width = 6,
              tablerProfileCard(
                width = 6,
                title = "Cristian Roman Palacios",
                subtitle = "Asistant Professor of Practice, UArizona",
                background = "https://preview.tabler.io/demo/photos/ilnur-kalimullin-218996-500.jpg",
                src = "https://cromanpa94.github.io/cromanpa/contact/2019-11-21%2010.51.14.jpg",
                tablerSocialLinks(
                  tablerSocialLink(
                    name = "facebook",
                    href = "https://www.facebook.com",
                    icon = "facebook"
                  ),
                  tablerSocialLink(
                    name = "twitter",
                    href = "https://www.twitter.com",
                    icon = "twitter"
                  )
                )
              )
            )
          )
        )
      )
    )
  )
)

