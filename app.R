###################
# app.R
# 
# Main controller. 
# Used to import your ui and server components; initializes the app.
###################

library(shiny)
library(tablerDash)
library(shinyWidgets)
library(DT)
library(phruta)
library(shiny.i18n)
library(ggmsa)
library(zip)
library(ape)

source('ui.R')
source('server.R')

shinyApp(ui, server)
