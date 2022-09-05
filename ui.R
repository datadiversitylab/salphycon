library(shiny)
library(tablerDash)
library(shinyWidgets)
library(DT)
library(phruta)
library(shiny.i18n)


profileCard <- tablerProfileCard(
  width = 12,
  title = "SALPHYCON",
  subtitle = "Basic phylogenetics in R",
  background = "https://cromanpa94.github.io/cromanpa/images/FrogMain_right_up.jpg",
  src = "img/salphycon_full.png",
  tablerSocialLinks(
    tablerSocialLink(
      name = "salphycon",
      href = "https://www.facebook.com",
      icon = "github"
    ),
    tablerSocialLink(
      name = "twitter",
      href = "https://www.twitter.com",
      icon = "twitter"
    ),
    tablerSocialLink(
      name = "phruta",
      href = "https://www.twitter.com",
      icon = "github"
    ),
    tablerSocialLink(
      name = "email",
      href = "cromanpa94@arizona.edu",
      icon = "gear"
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


# tableCard <- tablerCard(
#   title = "Accession numbers",
#   zoomable = TRUE,
#   closable = FALSE,
#   overflow = TRUE,
#   DT::dataTableOutput("distTable"),
#   status = "info",
#   statusSide = "left",
#   width = 12
# )

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
              width = 2
            ),
            column(
              tablerProfileCard(
                width = 12,
                title = "Welcome to SALPHYCON!",
                subtitle = "{Salphycon} is a shiny app that extends the functionalities of the {phruta} R package. {Salphycon} is able to (1) find potentially (phylogenetically) relevant gene regions for a given set of taxa based on GenBank, (2) retrieve gene sequences and curate taxonomic information from the same database, (3) combine downloaded and local gene sequences, and (4) perform sequence alignment, phylogenetic inference, and basic tree dating tasks. Both {phruta} and {salphycon} are focused on species-level analyses.",
                background = "https://cromanpa94.github.io/cromanpa/images/FrogMain_right_up.jpg",
                src = "img/salphycon_full.png",
                tablerSocialLinks(
                  tablerSocialLink(
                    name = "salphycon",
                    href = "https://www.facebook.com",
                    icon = "github"
                  ),
                  tablerSocialLink(
                    name = "twitter",
                    href = "https://www.twitter.com",
                    icon = "twitter"
                  ),
                  tablerSocialLink(
                    name = "phruta",
                    href = "https://www.twitter.com",
                    icon = "github"
                  ),
                  tablerSocialLink(
                    name = "email",
                    href = "cromanpa94@arizona.edu",
                    icon = "gear"
                  )
                )
              ), tablerCard(
                title = "Language/Idioma",
                width = 12,
                prettyRadioButtons(
                  inline = TRUE,
                  inputId = "selected_language",
                  label = i18n$t(""), 
                  choices = i18n$get_languages(),
                  selected = i18n$get_key_translation(),
                  bigger = FALSE,
                  status = "info",
                  animation = "jelly"
                ),
                collapsed = TRUE,
                closable = FALSE, 
                zoomable = FALSE
              ),
              fluidRow(
              column(
                width = 4,
                tablerBlogCard(
                  title = "Settings",
                  width = 12,
                  "Select the species-, gene-level sampling and tasks that you would like to execute in {salphycon}."
                )
              ),
              column(
                width = 4,
                tablerBlogCard(
                  title = "Sampling",
                  width = 12,
                  "Once you have run the analyses under {Settings}, use this tab to edit and examine the species-, gene-level sampling."
                )
              ),
              column(
                width = 4,
                tablerBlogCard(
                  title = "Sequences",
                  width = 12,
                  "Interested in visualizing the alignments assembled using {salphycon}? Check out the visuals in this tab."
                )
              )
              ),fluidRow(
                column(
                  width = 4,
                  tablerBlogCard(
                    title = "Phylogenetics",
                    width = 12,
                    "If you decided to run some phylogenetic analyses on your dataset, use this tab to examine and retrieve the resulting trees."
                  )
                ),
                column(
                  width = 4,
                  tablerBlogCard(
                    title = "Tree dating",
                    width = 12,
                    "Configure and analyze time-calibrated phylogenies based on phylogenies constructed using {salphycon}."
                  )
                ),
                column(
                  width = 4,
                  tablerBlogCard(
                    title = "About",
                    width = 12,
                    "Find more information about the author and get details on how to cite {salphycon}."
                  )
                )
              ),
              width = 9
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
          tablerCard(
            width = 12,
            title = h3("SETTINGS"),
            "Select the species-, gene-level sampling and tasks that you would like to execute in {salphycon}. First, start by choosing the taxonomic makeup of your analyses. You can either provide a comma-separated list of taxa (e.g. species, clades) or upload a {.csv} file with a single column taxa in rows. Second, select the genetic makeup of your analyses. In the current release of {salphycon}, users are only able to select what is the minimum species-level sampling percentage per gene (e.g. only genes sampled in 20% of the species). Third, select the tasks that you are interested in running. Finally, run the analyses!",
            closable = FALSE
          ),
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
                h3("1 - Taxa"),
                i18n$t("Please define the taxonomic makeup of your analuses. You can either provide a comma-separated list of taxa in the box below or upload a csv file with taxa in rows."),
                
                # Add Clades or Species text
                textInput("addTaxa", "", value = "", width = NULL, placeholder = "Halobates, Metrocoris, ..."),
                uiOutput("filterPage1"),
                
                # textInput("text", h6(i18n$t("Clades or Species")), 
                #           value = "Enter text..."),
                # textInput("text", h6(i18n$t("Species")), 
                #           value = "Enter text..."),
                
                dropdown(
                  "Select a file in {csv} format that includes taxonomic names in the rows and a single column. Please do not include column names.",
                  fileInput("fileTaxa", h5(""), width = '80%',
                            accept = c(
                              "text/csv",
                              "text/comma-separated-values,text/plain",
                              ".csv")),
                  style = "unite", icon = icon("cogs"),
                  status = "warning", width = "300px",
                  tooltip = tooltipOptions(title = "Upload a file!"),
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
                  h3("2 - Genes"),
                  i18n$t("Please define the genetic makeup of your analyses. For now, you will be able to indicate what is the minimum percetage of species that genes should include in order to be included in the analyses."),
                  h3(""),
                  h3(""),
                  # h5(i18n$t("Please input your target genes below")),
                  # materialSwitch(
                  #   inputId = "findGenes",
                  #   label = i18n$t("Find genes?"), 
                  #   value = TRUE,
                  #   status = "success"
                  # ),
                  sliderInput("sliderGenes", h6(i18n$t("Threshold to find genes")),
                              min = 0, max = 100, value = 20),
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
                ),
                tablerCard(
                  status = "yellow",
                  statusSide = "left",
                  width = 12,
                  h3(" 4 - Run analyses"),
                  i18n$t("Please make sure that all your settings are correct and run {salphycon}! "), h3(""),
                  column(
                    12,
                    actionButton("action", "Run analyses!", icon = icon("check"),
                                 style = "color: #fff; background-color: #27ae60; border-color: #fff"), align = "center")
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
                  h3(i18n$t("3 - Tasks")),
                  i18n$t("Select all the tasks that you would like to perform in {salphycon}. Sequence retrieval is requiered in the current release of the app. However, we will include compatibility for using local sequences in future releases."),
                  column(
                    12,
                    awesomeCheckboxGroup("Process", 
                                       h5(""), 
                                       
                                       choices = list("Retrieve" = 0,
                                                      "Curate" = 1, 
                                                      "Align" = 2, 
                                                      "RAxML" = 3),
                                       inline = TRUE,
                                       selected = 0), align = "center")
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
          tablerCard(
            width = 12,
            title = h3("SAMPLING"),
            "Once you have run the analyses under {Settings}, use this tab to edit and examine the species-, gene-level sampling. In this tab, you will get basic information on the sampling you retrieved from the basic settings defined in the previous tab. You will be able to make changes on the taxonomic and genetic makeup of the analyses.",
            closable = FALSE
          ),
          fluidRow(
            column(
              width = 3,
              profileCard
            ),
            column(
              width = 3,
              uiOutput("nTaxa"),
              uiOutput("nSeqs"),
              uiOutput("geneRegions")
            ),
            column(
              width = 6,
              uiOutput("tableAccN"),
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
          tablerCard(
            width = 12,
            title = h3("SEQUENCES"),
            "Once you have defined the species- and gene-level make up of your analyses in the previous two tabs, you will be able to visualize the resulting alignments. You will be able to retrieve the alignments at this point and will be provided with information described each of the alignments.",
            closable = FALSE
          ),
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
          tablerCard(
            width = 12,
            title = h3("PHYLOGENETICS"),
            "If you decided to run some phylogenetic analyses on your dataset, this tab will allow you to examine and retrieve the resulting trees. This tab includes a basic visualizer, with the additional option of downloading the trees constructed in {salphycon}.",
            closable = FALSE
          ),
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
          tablerCard(
            width = 12,
            title = h3("TIME DATING"),
            "Configure and analyze time-calibrated phylogenies based on phylogenies constructed using {salphycon}.",
            closable = FALSE
          ),
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
          tablerCard(
            width = 12,
            title = h3("ABOUT"),
            "Find more information about the author and get details on how to cite {salphycon}.",
            closable = FALSE
          ),
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

