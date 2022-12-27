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

#Load components
source('ui.R')
source('server.R')

#Load files
taxa_temp <- read.csv("data/taxa_temp.csv", header = FALSE)
gene_temp <- read.csv("data/genes_temp.csv", header = FALSE)
samp_temp <- read.csv("data/sampling_temp.csv")

#Run the app
shinyApp(ui, server)
