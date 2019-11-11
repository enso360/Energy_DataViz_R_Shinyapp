
#summary tab
tabPanel("KReSIT Summary", 
          
    fluidRow(
    column(4, textOutput("currentTime")),
    column(6, dateInput('summary_date',"Choose a Day"))    
    # column(5, offset=4, dateInput('summary_date',"Choose a Day"))
    ),

    hr(),

    fluidRow(

    # column(6, plotOutput('piechart')),    
    column(6, plotlyOutput('mains_barplot')),    
    column(6, textOutput('comparison'))
    ),

    hr(),

    fluidRow(
    # column(6, plotOutput('energy')),
    column(6, plotlyOutput('agg_energy_plot')),
    # column(6, plotOutput('power'))
    column(6, plotlyOutput('agg_power_plot'))

    )
)