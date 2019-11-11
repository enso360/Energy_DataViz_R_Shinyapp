
library(mongolite)
library(ggplot2)
library(plotly)
# suppressWarnings(library(plotly))
library(data.table)
library(xts)
library(fasttime) #for fastPosixct
library(scales)
library(shiny)
library(RColorBrewer)

options(shiny.maxRequestSize=100*1024^2) #size limit for file uploads, default 5MB
Sys.setenv(TZ="Asia/Kolkata")

# global variables 
# Objects in this file are shared across all sessions
source('config.R', local=TRUE)$value

# Define server logic
shinyServer(function(input, output, session){

  source('summary_tab_controller.R', local=TRUE)$value
  # summary_(input, output, session)

  source('archival_tab_controller.R', local=TRUE)$value  
  archival_tab_controller(input, output, session)

  source('upload_tab_controller.R', local=TRUE)$value  
  upload_data(input, output, session)

  source('aravali_tab_controller.R', local=TRUE)$value  
  aravali_tab_controller(input, output, session)
  
})



  





