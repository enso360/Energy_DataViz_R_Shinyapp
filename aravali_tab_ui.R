
tabPanel("Aravali",
       fluidRow(
         column(4,
                # selectizeInput('coll_name', label = 'Choose Meter', 
                #   choices = collection_list,
                #   # selected = "power_k_m"),
                #   selected = "test data"),
                uiOutput('a_listSelector'),   #uiOutput() is used in conjunction with
                                            # renderUI() on server side
                #for debugging
                p(textOutput('a_meter_name')),                                                  

                # selectInput('meter', "Choose Meter",
                #             multiple = TRUE,
                #             choices = meters
                # ),

                # selectInput('params', "Choose Data Parameters",
                #             multiple = TRUE,
                #             choices = params,
                #             selected = "Power" 
                # ),
                uiOutput('a_parameterSelector'),
                
                
                selectInput('a_res', "Select Day/Month/Week",
                            choices = c("Day","Week","Month")
                ),
                
                conditionalPanel(condition='input.a_res == "Day"',
                                 dateInput('a_selected_day',"Select a Day"),
                                 #for debugging
                                 # p(textOutput('dynamic_selected_day'))
                                p(textOutput('a_out_selected_day')),
                                # p(textOutput('debug_selected_day'))
                                # verbatimTextOutput('selected_day'), #output variable consumed once can be consumed again
                                # verbatimTextOutput('debug1')
                                sliderInput("a_selected_hour", "Select an Hour:", 
                                min=0, max=23, value=0, step = 1),
                                p(textOutput('a_out_selected_hour')),
                                actionButton("a_redraw", "Plot now")
                ),
                
                conditionalPanel(condition='input.a_res == "Month"',
                                 selectInput('a_month',"Choose a Month",
                                             choices = month
                                 ),
                                 textInput('a_year',"Input a Year")
                ),
                
                conditionalPanel(condition='input.a_res == "Week"',
                                 selectInput('a_week',"Choose a Week",
                                             choices = week),
                                 textInput('a_year',"Input a Year")
                )
                
         ),

         column(8,                                     
            plotlyOutput("a_lineplot1")
            #)
          )
       )
)