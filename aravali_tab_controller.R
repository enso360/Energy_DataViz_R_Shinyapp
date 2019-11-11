aravali_tab_controller <- function(input, output, session){
  source('helper_functions.R', local=TRUE)$value #sourcing few utility functions
  # using renderUI() to pass UI paramters from server to client
  # renderUI() is used in conjunction with uiOutput() on client side
  output$a_listSelector <- renderUI({
    selectizeInput('a_meter_name', label = 'Choose Meter',
    choices = a_meter_names,
    selected = "Test Data")
  })

  output$a_parameterSelector <- renderUI({
    selectInput('a_params', "Choose Data Parameters",
                multiple = TRUE,
                choices = params,
                selected = "Power"
    )
  })

  # for debugging
  # multiple assignments can be used if same input variable is to be used 
  # by different output components
  output$a_out_selected_day <-  output$a_debug_selected_day <- renderText({
    sprintf('Selected day: %s', input$a_selected_day)
  })
  output$a_out_selected_hour <- renderText({
  sprintf('Selected hour: %s', input$a_selected_hour)
  })

  output$a_debug1 <- renderPrint({
    sprintf('%s', input$a_selected_day)
  })

  #using delayed execution
  a_reac <- reactiveValues(redraw = TRUE,
    selected_day = isolate(input$a_selected_day),
    selected_hour = isolate(input$a_selected_hour)
    )

  # If the observed inputs are changed, set the redraw parameter to FALSE
  observe({
    input$a_selected_day
    input$a_selected_hour
    # input$meter_name
    a_reac$redraw <- FALSE
  })
  # This event will also fire for any inputs, but will also fire for
  # a timer and with the 'redraw now' button.
  # The net effect is that when an input is changed, a 5 second timer
  # is started. This will be reset any time that a further input is
  # changed. If it is allowed to lapse (or if the button is pressed)
  # then the inputs are copied into the reactiveValues which in turn
  # trigger the plot to be redrawn.
  observe({
    execution_delay <- 3000 #delay of 3 secs
    invalidateLater(millis=execution_delay, session)
    input$a_selected_day
    input$a_selected_hour
    # input$meter_name
    input$a_redraw
    # isolate(cat(reac$redraw, input$selected_day "\n")) #for debugging
    if (isolate(a_reac$redraw)) {
      a_reac$selected_day <- input$a_selected_day
      a_reac$selected_hour <- input$a_selected_hour
      # reac$meter_name <- input$meter_name
    } else {
      isolate(a_reac$redraw <- TRUE)
    }
  })


  output$a_meter_name <- renderText({
    # sprintf('You have selected %s', reac$meter_name)
    sprintf('You have selected %s', input$a_meter_name)
  })

  #get collection name from UI
  a_get_coll <- reactive({
    # coll_local <- meter_to_collection_map(reac$meter_name)
    coll_local <- meter_to_collection_map(a_df_meter, input$a_meter_name)
    return (coll_local)
  })

  #'we wrap the data loading in a reactive block, and
  #'in the plotting refer to dataInput().
  #'The advantage of this is that for a reactive expression
  #'Shiny first checks if the data actually needs to be updated or not.
  #'reactive functions are re-run only when necessary
  #'Only call a reactive expression from within a reactive or a render*function
  a_dataInput <- reactive( {
      # selected_day <- as.Date(input$selected_day)
      selected_day <- as.Date(a_reac$selected_day) #using reactiveValue for delayed execution
      # start_hr <- as.numeric(reac$selected_hour)
      # end_hr <- as.numeric(reac$selected_hour)
      start_hr <- as.numeric(input$a_selected_hour)
      end_hr <- as.numeric(input$a_selected_hour)
      print (start_hr)
      start_min = 00
      end_min = 59
      # start_time <- fastPOSIXct(paste0(selected_day,' ',"00:00:00"))
      # end_time <- fastPOSIXct(paste0(selected_day,' ',"00:00:00"))
      # start_time <- as.numeric(as.POSIXct(paste0(selected_day,' ',"00:02:00")))
      # end_time <- as.numeric(as.POSIXct(paste0(selected_day,' ',"00:03:00")))
      start_time <- paste0(selected_day, " ", start_hr, ":", start_min, ":", 00)
      end_time <- paste0(selected_day, " ", end_hr, ":", end_min, ":", 59)
    # dframe <- get_data()
    # dframe <- get_data(input$meter_name)
    dframe <- get_data(db = "data" , a_get_coll(), a_keys, start_time, end_time)
    # dframe
  })


  #render* functions are re-run whenever there is ANY change in UI
  output$a_lineplot1 <- renderPlotly({

    data <- a_dataInput()
    # data <- get_data(get_coll())
    #convert epoch dataframe to ASCII dataframe
    timestamp <- as.POSIXct(data$TS, origin='1970-01-01', tz='Asia/Kolkata')

    #creating the final df to be plotted
    # df <- data.frame(timestamp,sensor,power=data2$W)
    # df <- data.frame(timestamp,Key,power=data2$W)
    df <- data.frame(timestamp,power=data$AvgW)

    p <- plot_data(df, a_get_coll())
    p
  })
}
