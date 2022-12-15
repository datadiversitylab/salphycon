library(shiny)
library(tablerDash)
library(shinyWidgets)
library(DT)
library(phruta)
library(shiny.i18n)
library(ggmsa)
library(zip)
library(ape)

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
        shiny.i18n::usei18n(i18n),
        tabName = "Home",
        icon = "home",
        i18n$t("Home")
      ),
      tablerNavMenuItem(
        tabName = "Settings",
        icon = "lock",
        i18n$t("Settings")
      ),
      tablerNavMenuItem(
        tabName = "Sampling",
        icon = "box",
        i18n$t("Sampling")
      ),
      tablerNavMenuItem(
        tabName = "Alignments",
        icon = "layers",
        i18n$t("Alignments")
      ),
      tablerNavMenuItem(
        tabName = "Phylogenetics",
        icon = "activity",
        i18n$t("Phylogenetics")
      ),
      tablerNavMenuItem(
        tabName = "GeneFinder",
        icon = "map",
        i18n$t("Gene finder")
      ),
      tablerNavMenuItem(
        tabName = "About",
        icon = "info",
        i18n$t("About")
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
              tablerCard(
                title = "Language/Idioma",
                width = 12,
                column(width = 12,
                prettyRadioButtons(
                  inline = TRUE,
                  inputId = "selected_language",
                  label = i18n$t(""), 
                  choices = i18n$get_languages(),
                  selected = i18n$get_key_translation(),
                  bigger = FALSE,
                  status = "info",
                  animation = "jelly"
                ), align = "center"),
                collapsed = FALSE,
                closable = FALSE, 
                zoomable = FALSE
              ),
              tablerProfileCard(
                width = 12,
                title = i18n$t("Welcome to SALPHYCON!"),
                subtitle = i18n$t("{Salphycon} is a shiny app that extends the functionalities of the {phruta} R package. {Salphycon} is able to (1) find potentially (phylogenetically) relevant gene regions for a given set of taxa based on GenBank, (2) retrieve gene sequences and curate taxonomic information from the same database, (3) combine downloaded and local gene sequences, and (4) perform sequence alignment, phylogenetic inference, and basic tree dating tasks. Both {phruta} and {salphycon} are focused on species-level analyses."),
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
              ), 
              fluidRow(
              column(
                width = 4,
                tablerBlogCard(
                  title = i18n$t("Settings"),
                  width = 12,
                  i18n$t("Select the species-, gene-level sampling and tasks that you would like to execute in {salphycon}.")
                )
              ),
              column(
                width = 4,
                tablerBlogCard(
                  title = i18n$t("Sampling"),
                  width = 12,
                  i18n$t("Once you have run the analyses under {Settings}, use this tab to edit and examine the species-, gene-level sampling.")
                )
              ),
              column(
                width = 4,
                tablerBlogCard(
                  title = i18n$t("Alignments"),
                  width = 12,
                  i18n$t("Interested in visualizing the alignments assembled using {salphycon}? Check out the visuals in this tab.")
                )
              )
              ),fluidRow(
                column(
                  width = 4,
                  tablerBlogCard(
                    title = i18n$t("Phylogenetics"),
                    width = 12,
                    i18n$t("If you decided to run some phylogenetic analyses on your dataset, use this tab to examine and retrieve the resulting trees.")
                  )
                ),
                column(
                  width = 4,
                  tablerBlogCard(
                    title = i18n$t("Gene finder"),
                    width = 12,
                    i18n$t("Find genes for a target taxon or set of taxa using {salphycon}.")
                  )
                ),
                column(
                  width = 4,
                  tablerBlogCard(
                    title = i18n$t("About"),
                    width = 12,
                    i18n$t("Find more information about the author and get details on how to cite {salphycon}.")
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
          useTablerDash(),
          chooseSliderSkin("Modern"),
          div(style = "height:30px"),
          tablerCard(
            width = 12,
            title = h3(i18n$t("SETTINGS")),
            i18n$t("Select the species-, gene-level sampling and tasks that you would like to execute in {salphycon}. First, start by choosing the taxonomic makeup of your analyses. You can either provide a comma-separated list of taxa (e.g. species, clades) or upload a {.csv} file with a single column taxa in rows. Second, select the genetic makeup of your analyses. In the current release of {salphycon}, users are only able to select what is the minimum species-level sampling percentage per gene (e.g. only genes sampled in 20% of the species). Third, select the tasks that you are interested in running. Finally, run the analyses!"),
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
                h3(i18n$t("1 - Taxa")),
                i18n$t("Please define the taxonomic makeup of your analyses. You can either provide a comma-separated list of taxa in the box below or upload a csv file with taxa in rows."),
                
                # Add Clades or Species text
                textInput("addTaxa", "", value = "", width = NULL, placeholder = "Halobates, Metrocoris, ..."),
                uiOutput("filterPage1"),
                
                dropdown(
                  i18n$t("Select a file in {csv} format that includes taxonomic names in the rows and a single column. Please do not include column names."),
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
                  h3(i18n$t("2 - Genes")),
                  i18n$t("Please define the genetic makeup of your analyses. For now, you will be able to indicate what is the minimum percetage of species that genes should include in order to be included in the analyses."),
                  h3(""),
                  h3(""),

                  sliderInput("sliderGenes", h6(i18n$t("Threshold to find genes")),
                              min = 0, max = 100, value = 20),
                  dropdown(
                    i18n$t("Select a file in {csv} format that includes gene names in the rows and a single column. Please do not include column names."),
                    fileInput("fileGenes", h5(""), width = '80%',
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
                ),
                tablerCard(
                  status = "yellow",
                  statusSide = "left",
                  width = 12,
                  h3(i18n$t(" 4 - Run analyses")),
                  i18n$t("Please make sure that all your settings are correct and run {salphycon}!"), h3(""),
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
                                       selected = c(0, 1)), align = "center")
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
            title = h3(i18n$t("SAMPLING")),
            i18n$t("Once you have run the analyses under {Settings}, use this tab to edit and examine the species-, gene-level sampling. In this tab, you will get basic information on the sampling you retrieved from the basic settings defined in the previous tab. You will be able to make changes on the taxonomic and genetic makeup of the analyses."),
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
              uiOutput("geneRegions"),
              uiOutput("Refresh")
            ),
            column(
              width = 6,
              uiOutput("tableAccN")
            )
          )
        )
        #fluidPage(plotCard)
      ),
      tablerTabItem(
        tabName = "Alignments",
        fluidPage(
          useTablerDash(),
          chooseSliderSkin("Modern"),
          div(style = "height:30px"),
          tablerCard(
            width = 12,
            title = h3(i18n$t("ALIGNMENTS")),
            i18n$t("Once you have defined the species- and gene-level makeup of your analyses in the previous two tabs, you will be able to visualize the resulting alignments. For now, the app will only display the masked alignments. You will be able to retrieve the alignments at this point and will be provided with information described each of the alignments."),
            closable = FALSE
          ),
          fluidRow(
            column(
              width = 3,
              profileCard
            ),
            column(
              width = 3,
              uiOutput("dropGenes"),
              uiOutput("nGaps"),
              uiOutput("SpeciesRegion"),
              uiOutput("alnDownload")
            ),
            column(
              width = 6,
              uiOutput("seqPlots")
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
            title = h3(i18n$t("PHYLOGENETICS")),
            i18n$t("If you decided to run some phylogenetic analyses on your dataset, this tab will allow you to examine and retrieve the resulting trees. This tab includes a basic visualizer, with the additional option of downloading the trees constructed in {salphycon}."),
            closable = FALSE
          ),
          fluidRow(
            column(
              width = 3,
              profileCard
            ),
            
            column(
              width = 9,
              uiOutput("phyloPlots"),
              uiOutput("phyloDownload")
            )
          )
        )
      ),
      tablerTabItem(
        tabName = "GeneFinder",
        fluidPage(
          useTablerDash(),
          chooseSliderSkin("Modern"),
          div(style = "height:30px"),
          tablerCard(
            width = 12,
            title = h3(i18n$t("Gene finder")),
            i18n$t("Find the distribution of sampled genes in GenBank for a target taxon or set of taxa."),
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
                h3(i18n$t("Taxa")),
                i18n$t("Please define the taxonomic makeup of your analyses. You can either provide a comma-separated list of taxa in the box below or upload a csv file with taxa in rows."),
                
                # Add Clades or Species text
                textInput("genesearch", "", value = "", width = NULL, placeholder = "Halobates, Metrocoris, ..."),
                column(
                  12,
                dropdown(
                  i18n$t("Select a file in {csv} format that includes taxonomic names in the rows and a single column. Please do not include column names."),
                  fileInput("fileTaxaGenes", h5(""), width = '80%',
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
                ), align = "center"
                ),
                br(),
                column(
                  12,
                  actionButton("action2", i18n$t("Find genes!"), icon = icon("check"),
                               style = "color: #fff; background-color: #27ae60; border-color: #fff"), align = "center"
                  )
              )
            ),
            column(
              width = 6,
              uiOutput("tableGenes")
            )
          )
        )
      ),
      # tablerTabItem(
      #   tabName = "TimeDating",
      #   fluidPage(
      #     useTablerDash(),
      #     chooseSliderSkin("Modern"),
      #     div(style = "height:30px"),
      #     tablerCard(
      #       width = 12,
      #       title = h3("TIME DATING"),
      #       "Configure and analyze time-calibrated phylogenies based on phylogenies constructed using {salphycon}.",
      #       closable = FALSE
      #     ),
      #     fluidRow(
      #       column(
      #         width = 3,
      #         profileCard
      #       ),
      #       column(
      #         width = 3,
      #         h6("Under construction...")
      #       )
      #     )
      #   )
      # ),
      tablerTabItem(
        tabName = "About",
        fluidPage(
          useTablerDash(),
          chooseSliderSkin("Modern"),
          div(style = "height:30px"),
          tablerCard(
            width = 12,
            title = h3(i18n$t("ABOUT")),
            i18n$t("Find more information about the author and get details on how to cite {salphycon}."),
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
                subtitle = i18n$t("Asistant Professor of Practice, UArizona"),
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

