
# summary_ <- function(input, output, session){
  # get the data corresponding to the mentioned date from the database
  # data required -> per hour energy, comparison with other similar days, pie chart of main meter, avg. power consumption and
  # voltage information for that day ...
  
  source('helper_functions.R', local=TRUE)$value #sourcing few utility fnctions

  output$currentTime <- renderText({
    invalidateLater(1000, session)
    paste("The current date and time is", Sys.time())
  })

  output$mains_barplot <- renderPlotly({

    selected_day <- as.Date(input$summary_date)
    start_time <- paste0(selected_day, " ", 00, ":", 00, ":", 00) #day's start
    end_time <- paste0(selected_day, " ", 23, ":", 59, ":", 59) #day's end

    energy_k_m <- get_energy_data(dbName, "power_k_m", start_time, end_time)
    # print(energy_k_m)
    energy_k_a <- get_energy_data(dbName, "power_k_a", start_time, end_time)
    energy_k_p <- get_energy_data(dbName, "power_k_p", start_time, end_time)

    energy_k_LF <- energy_k_m - (energy_k_a + energy_k_p) #using parent child relation between nodes

    # mydf <- data.frame(60,40,45)
    mydf <- data.frame(energy_k_a, energy_k_p, energy_k_LF)
    colnames(mydf) = c("HVACs", "Plugs", "Lights & Fans")
    # slices <- c(mydf$HVACs, mydf$Lights, mydf$Plugs)
    slices <- c(mydf[[1]], mydf[[2]], mydf[[3]])
    # slices <- c(10,10,10)
    # lbls <- c("HVACs","Lights & Fans", "Plugs")
    lbls <- colnames(mydf)
    df <- data.frame(
      x = lbls,
      y = slices
    )
    # ggbar <- ggplot(data=df, aes(x=x, y=y, fill=x)) +
    #            geom_bar(stat="identity") + labs(x="Appliance type",y="Energy") +
    #            ggtitle("Energy Contribution in KReSIT Mains") + guides(fill=FALSE)#no lname besides legends
    # p_bar <- ggplotly(ggbar) 
    p_bar <- plot_ly(df,
          x = df$x,
          y = df$y,
          name = "Energy",
          type = "bar",
          marker = list(color = brewer.pal(3, "Pastel1")) #RBrewer color package
          )   %>%
          layout(title = "Energy Contribution in KReSIT Mains",
                       xaxis = list(title = "Appliance type"),
                       yaxis = list (title = "Energy")
          )
  })

  output$comparison <- renderText({
    
    date_ <- input$summary_date
    day_ <- weekdays(as.Date(date_))
    
    text_ <- paste('The day according to the date is ', day_)
  })
  

  output$agg_energy_plot <- renderPlotly({
    selected_day <- "2017-02-25"
    # selected_day <- as.Date(input$summary_date)
    start_time <- paste0(selected_day, " ", 00, ":", 00, ":", 00) #day's start
    end_time <- paste0(selected_day, " ", 23, ":", 59, ":", 59) #day's end

    df_agg = get_agg_data(dbAgg, "power_k_m_agg", start_time, end_time, agg_param = "FwdWh", agg_func = "sum")
    # print(df_agg)

    # barplot(df_agg[,2],
            # names.arg=c(seq(0:23)),
            # main='KReSIT Per Hour Total Energy Consumption',
            # ylab="Energy",
            # xlab="Hour")    
    # ggbar <- ggplot(data=df_agg, aes(x=c(seq(0:23)), y=df_agg[,2])) +
    #            geom_bar(stat="identity") + labs(x="Hour of the Day",y="Energy") +
    #            ggtitle("KReSIT Hourly Energy Consumption") + guides(fill=FALSE)#no lname besides legends
    # p <- ggplotly(ggbar) 
    p_bar <- plot_ly(
          x = c(seq(0:23)),
          y = df_agg[,2],
          name = "Energy",
          type = "bar",
          # marker = list(color = 'rgb(255, 168, 48)'), #light orange
          marker = list(color = 'rgb(156, 244, 97)'), #light green
          )   %>%
          layout(title = "KReSIT Hourly Energy Consumption",
                       xaxis = list(title = "Hour of the Day"),
                       yaxis = list (title = "Energy")
          ) #%>%
          #config(showLink = FALSE)

    # g <- ggplot(df_agg,aes(x=df_agg[,1],y=df_agg[,2]))+geom_line() + labs(x="Timestamp",y="Energy")
    # g <- g + theme(axis.text.x = element_text(angle = 45,hjust = 1, vjust= -20)) + scale_x_datetime(labels = date_format("%d %H:%M",tz="Asia/Kolkata")) # use scales package
    # g <- g + theme(legend.title=element_blank()) #Turn off the legend title
    # p <- ggplotly(g)

  })


  output$agg_power_plot <- renderPlotly({
    selected_day <- "2017-02-25"
    # selected_day <- as.Date(input$summary_date)
    start_time <- paste0(selected_day, " ", 00, ":", 00, ":", 00) #day's start
    end_time <- paste0(selected_day, " ", 23, ":", 59, ":", 59) #day's end

    df_agg = get_agg_data(dbAgg, "power_k_m_agg", start_time, end_time, agg_param = "W", agg_func = "mean")
    # print(df_agg)

    # barplot(df_agg[,2],
    #         names.arg=c(seq(0:23)),  
    #         main='KReSIT Per Hour Total Power Consumption',
    #         ylab="Power",
    #         xlab="Hour") 
    # ggbar <- ggplot(data=df_agg, aes(x=c(seq(0:23)), y=df_agg[,2])) +
    #            geom_bar(stat="identity") + labs(x="Appliance type",y="Power") +
    #            ggtitle("Power Contribution in KReSIT Mains") + guides(fill=FALSE)#no lname besides legends
    # p <- ggplotly(ggbar) 
    # g <- ggplot(df_agg,aes(x=df_agg[,1],y=df_agg[,2]))+geom_line() + labs(x="Timestamp",y="Power")
  
    # g <- g + theme(axis.text.x = element_text(angle = 45,hjust = 1, vjust= -20)) + scale_x_datetime(labels = date_format("%d %H:%M",tz="Asia/Kolkata")) # use scales package
    # g <- g + theme(legend.title=element_blank()) #Turn off the legend title
    # p <- ggplotly(g)
    p <- plot_ly(df_agg, 
                x=df_agg[,1], y=df_agg[,2], 
                type = 'scatter', mode = 'lines+markers', line = list(shape = "spline") ) %>%
                # Hover text:
                # text = ~paste("Power: ", df_agg[,2], 'Time', df_agg[,1])
                # ) %>%
                layout(title = "Power Profile of KReSIT Mains",
                       xaxis = list(title = "Hour of the Day"),
                       yaxis = list (title = "Average Power"))
  })
