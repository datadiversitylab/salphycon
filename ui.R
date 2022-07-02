library(shiny)
library(tablerDash)
library(shinyWidgets)


profileCard <- tablerProfileCard(
  width = 12,
  title = "SALPICON",
  subtitle = "Basic phylogenetics with phruta.",
  background = "https://preview.tabler.io/demo/photos/ilnur-kalimullin-218996-500.jpg",
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
  title = "Plots",
  zoomable = TRUE,
  closable = TRUE,
  options = tagList(
    switchInput(
      inputId = "enable_distPlot",
      label = "Plot?",
      value = TRUE,
      onStatus = "success",
      offStatus = "danger"
    )
  ),
  plotOutput("distPlot"),
  status = "info",
  statusSide = "left",
  width = 12,
  footer = tagList(
    column(
      width = 12,
      align = "center",
      sliderInput(
        "obs",
        "Number of observations:",
        min = 0,
        max = 1000,
        value = 500
      )
    )
  )
)


  ui = fluidPage(
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
        tablerStatCard(
          value = 1,
          title = "Historical users",
          #trend = -10,
          width = 12
        ),
        tablerAvatarList(
          stacked = TRUE,
          tablerAvatar(
            name = "CRP",
            size = "xl",
            color = "blue",
            url = "https://raw.githubusercontent.com/cromanpa94/phruta/main/vignettes/logo.png"
          ),
          tablerAvatar(
            name = "WY",
            color = "orange",
            size = "m",
            url = "https://raw.githubusercontent.com/cromanpa94/phruta/main/vignettes/logo.png"
          )
        )
      ),
      column(
        width = 6,
        plotCard
      ),
      column(
        width = 3,
        tablerCard(
          width = 12,
          tablerTimeline(
            tablerTimelineItem(
              title = "Item 1",
              status = "green",
              date = "now"
            ),
            tablerTimelineItem(
              title = "Item 2",
              status = NULL,
              date = "yesterday",
              "Lorem ipsum dolor sit amet,
                  consectetur adipisicing elit."
            )
          )
        ),
        tablerInfoCard(
          value = "132 sales",
          status = "danger",
          icon = "dollar-sign",
          description = "12 waiting payments",
          width = 12
        ),
        numericInput(
          inputId = "totalStorage",
          label = "Enter storage capacity",
          value = 1000),
        uiOutput("info"),
        knobInput(
          inputId = "knob",
          width = "50%",
          label = "Progress value:",
          value = 10,
          min = 0,
          max = 100,
          skin = "tron",
          displayPrevious = TRUE,
          fgColor = "#428BCA",
          inputColor = "#428BCA"
        ),
        uiOutput("progress")
      )
    )
  )
  
