
tabPanel("KReSIT",
       fluidRow(
         column(4,
                # selectizeInput('coll_name', label = 'Choose Meter', 
                #   choices = collection_list,
                #   # selected = "power_k_m"),
                #   selected = "test data"),
                uiOutput('listSelector'),   #uiOutput() is used in conjunction with
                                            # renderUI() on server side
                #for debugging
                p(textOutput('meter_name')),                                                  

                # selectInput('meter', "Choose Meter",
                #             multiple = TRUE,
                #             choices = meters
                # ),

                # selectInput('params', "Choose Data Parameters",
                #             multiple = TRUE,
                #             choices = params,
                #             selected = "Power" 
                # ),
                uiOutput('parameterSelector'),
                
                
                selectInput('res', "Select Day/Month/Week",
                            choices = c("Day","Week","Month")
                ),
                
                conditionalPanel(condition='input.res == "Day"',
                                 dateInput('selected_day',"Select a Day"),
                                 #for debugging
                                 # p(textOutput('dynamic_selected_day'))
                                p(textOutput('out_selected_day')),
                                # p(textOutput('debug_selected_day'))
                                # verbatimTextOutput('selected_day'), #output variable consumed once can be consumed again
                                # verbatimTextOutput('debug1')
                                sliderInput("selected_hour", "Select an Hour:", 
                                min=0, max=23, value=0, step = 1),
                                p(textOutput('out_selected_hour')),
                                actionButton("redraw", "Plot now")
                ),
                
                conditionalPanel(condition='input.res == "Month"',
                                 selectInput('month',"Choose a Month",
                                             choices = month
                                 ),
                                 textInput('year',"Input a Year")
                ),
                
                conditionalPanel(condition='input.res == "Week"',
                                 selectInput('week',"Choose a Week",
                                             choices = week),
                                 textInput('year',"Input a Year")
                )
                
         ),

         column(8,                                     
            plotlyOutput("lineplot1")
            #)
          )
       )
)