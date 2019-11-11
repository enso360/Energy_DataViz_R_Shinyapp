
library(shiny)
#library(plotly)

# global variables 
# Objects in this file are shared across all sessions
source('config.R', local=TRUE)$value

# Define UI
# shinyUI(pageWithSidebar(
shinyUI(
  navbarPage("Viz!", 

      #summary tab
      source('summary_tab_ui.R', local=TRUE)$value,                   

      # navbarMenu("Historical",
        #archival tab
        source('archival_tab_ui.R', local=TRUE)$value,          

      #   #comparison tab
      #   tabPanel("Comparison")                
      # ),
     
      # tabPanel("Clustering"),
      # tabPanel("Threshold"),
      # tabPanel("Correlations"),

      #upload tab
      # tabPanel("Upload", source('upload_tab_ui.R', local=TRUE)$value)

      tabPanel("Aravali", source('aravali_tab_ui.R', local=TRUE)$value)

  )
)
