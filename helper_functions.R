
connect_mongo <- function(db, coll_local){
  #create mongodb connection handle
  URI = sprintf("mongodb://%s:%s", host, port)
  con <- mongo(url = URI, db = db, collection = coll_local) #collection name is required  
  return (con)
}

get_energy_data <- function(db = dbName, coll_local = "power_k_m", start_time, end_time){
  # Fetches data from mongodb server if available 
  # else returns test data saved locally
  #
  # Args:
  #   coll_local: collection name
  #   start_time: date, time in the format "2017-03-09 00:02:00"
  #   end_time: date, time in the format "2017-03-09 00:02:00"
  #
  # Returns: dataframe
  
  if(coll_local == "test_data"){
    # data <- read.csv("./Data/offline_SM_data.csv")
    data <- data.frame(99)
    print("using test data")     #debug
    # print(data)     #debug
    return (data)
  }
  else{

    mo_con <- connect_mongo(db, coll_local)
    
    print("inside energy")
    print(paste(start_time, end_time)) #debug
    #convert ASCII time to epochtime
    start_epoch = as.numeric(as.POSIXct(start_time, tz = "Asia/Kolkata"))
    end_epoch = as.numeric(as.POSIXct(end_time, tz = "Asia/Kolkata"))
    
    #construct the query
    # query = paste0("{'TS':{'$gt':",start_epoch,", '$lt':",end_epoch, "}}")
    # query1 = paste0("{'TS':{'$gt':",start_epoch,"} }")
    query1 = paste0('{ "TS": { "$gt":', start_epoch, '} }')
    query2 = paste0('{ "TS": { "$lt":', end_epoch, '} }')
  
    #parameters to fetch
    # params = '{"TS": 1, "FwdWh": 1, "_id": 0}'
    params = '{"FwdWh": 1, "_id": 0}'
    
    #fetch only specific parameters
    start_enery_df <- mo_con$find(query = query1, fields = params, sort = '{"TS": 1 }', limit = 1)
    end_energy_df <- mo_con$find(query = query2, fields = params, sort = '{"TS": -1 }', limit = 1)
    
    energy_consumption_df <- end_energy_df - start_enery_df
    #disconnect before exiting
    rm(mo_con) # Automatically disconnects when connection is removed
    
    message(sprintf("energy of collection %s is ", coll_local))
    #print("energy of collection") #for debugging
    print(energy_consumption_df[,1])
    return (energy_consumption_df)
  }
}

get_agg_data <- function(db, coll_local, start_time, end_time, agg_param = "FwdWh", agg_func = "sum"){
  # Fetches data from mongodb server if available 
  # else returns test data saved locally
  #
  # Args:
  #   coll_local: collection name
  #   start_time: date, time in the format "2017-03-09 00:02:00"
  #   end_time: date, time in the format "2017-03-09 00:02:00"
  #
  # Returns: dataframe
  
  if(coll_local == "test_data"){
    # data <- read.csv("./Data/offline_SM_data.csv")
    data <- data.frame(99)
    print("using test data")     #debug
    # print(data)     #debug
    return (data)
  }
  else{
    
    mo_con <- connect_mongo(db, coll_local)
    print("inside agg")
    print(paste(start_time, end_time)) #debug
    #convert ASCII time to epochtime
    start_epoch = as.numeric(as.POSIXct(start_time, tz = "Asia/Kolkata"))
    end_epoch = as.numeric(as.POSIXct(end_time, tz = "Asia/Kolkata"))
    
    #construct the query
    query = paste0('{"TS":{"$gte":',start_epoch,', "$lte":',end_epoch, '}}')
    
    #parameters to fetch
    # keys = '{"TS": 1, "FwdWh": 1, "_id": 0}'
    keys = paste0('{"TS": 1, "_id": 0, "', agg_param, '":1', '}')
    
    
    #fetch the data
    df <- mo_con$find(query = query, fields = keys, sort = '{"TS": -1 }')
    #TO-DO: do we check for NaN and fill missing data ?
    
    #convert epoch dataframe to ASCII dataframe
    df$TS <- as.POSIXct(df$TS, origin='1970-01-01', tz='Asia/Kolkata')

    xts_data1 = as.xts(x = df[agg_param], order.by = df$TS) 
    ep_offset = 3600*0.5 #offset in secs to resolve endpoint half hour offset issue
    # endpoints = endpoints(xts_data1, on = "hours", k =1) #does not work as expected
    ep = endpoints(index(xts_data1) - ep_offset, on = "hours", k=1)
    #to work around the endpoint half hour offset issue
    #http://stackoverflow.com/questions/33229992/convert-time-series-data-from-seconds-to-hourly-means-in-r
    #http://stackoverflow.com/questions/14141537/change-timezone-in-a-posixct-object
    xts_data1 = period.apply(xts_data1, INDEX = ep, FUN = agg_func) #works
    # df2 = data.frame(TS = index(xts_data1), value = coredata(xts_data1)) #better    
    df = data.frame(TS = trunc(index(xts_data1), "hours"), value = coredata(xts_data1)) #better   
    
    #disconnect before exiting
    rm(mo_con) # Automatically disconnects when connection is removed
    
    print(head(df, n=2))   #for debugging
    return (df)
  }
}

#fetch data, default collection name is "power_k_m"
get_data <- function(db = "data", coll_local = "power_k_m", keys, start_time, end_time){
  # Fetches data from mongodb server if available 
  # else returns test data saved locally
  #
  # Args:
  #   db: db name
  #   coll_local: collection name
  #   keys: keys/fields/parameters to fetch
  #   start_time: date, time in the format "2017-03-09 00:02:00"
  #   end_time: date, time in the format "2017-03-09 00:02:00"
  #
  # Returns: dataframe
  
  if(coll_local == "test_data"){
    data <- read.csv("./Data/offline_SM_data.csv")
    print("using test data")     #debug
    # print(data)     #debug
    return (data)
  }
  else{
    #create mongodb connection handle
    mo_con <- connect_mongo(db, coll_local)
    
    print(paste(start_time, end_time)) #debug
    #convert ASCII time to epochtime
    start_epoch = as.numeric(as.POSIXct(start_time, tz = "Asia/Kolkata"))
    end_epoch = as.numeric(as.POSIXct(end_time, tz = "Asia/Kolkata"))
    
    #construct the query
    # query = paste0("{'TS':{'$gt':",start_epoch,", '$lt':",end_epoch, "}}")
    query = paste0('{"TS":{"$gt":',start_epoch,', "$lt":',end_epoch, '}}')
    
    #fetch the data
    data <- mo_con$find(query = query, fields = keys, sort = '{"TS": -1 }')
    #disconnect before exiting
    rm(mo_con) # Automatically disconnects when connection is removed

    print(head(data, n=2))   #for debugging
    return (data)
  }
}


plot_data <- function(df , coll_local = "power_k_m"){
  # Fetches data from mongodb server if available 
  # else returns test data saved locally
  #
  # Args:
  #   df : dataframe to be plotted
  #   coll_local: collection name used for labelling the plot
  #
  # Returns: ggplot/plotly obj
  
  # sensor = coll_local
  # sensor <- paste(coll_local,":","Power", sep="") #equivalent of paste0   
  # Key <- paste(coll_local,":","Power", sep="") #equivalent of paste0
  # g <- ggplot(df,aes(x=timestamp,y=temperature,group=sensor, color=sensor, color=sensor))+geom_line() + labs(x="Timestamp",y="Temperature")
  # g <- ggplot(df,aes(x=timestamp,y=power,color=Key))+geom_line() + labs(x="Timestamp",y="Power")
  
  # g <- g + theme(axis.text.x = element_text(angle = 45,hjust = 1, vjust= -20)) + scale_x_datetime(labels = date_format("%d %H:%M",tz="Asia/Kolkata")) # use scales package
  # g <- g + theme(legend.title=element_blank()) #Turn off the legend title
  # ggplotly(g)     

  # TODO: add option to show label in the form <coll_name:param>
          #grouping the individual data series

  p <- plot_ly(df, 
            x=df[,1], y=df[,2], 
            type = 'scatter', mode = 'lines' ) %>%
        layout(title = "",
                       xaxis = list(title = "Time"),
                       yaxis = list (title = "Power"))
}

meter_to_collection_map <- function(df_meter_list_tmp, meter_tmp){
  # Returns collection name corresponding to meter name 
  #
  # Args:
  #   df_meter_list_tmp: meter list containing both meter name and collection name, global - defined in config
  #   meter_tmp: meter name
  #
  # Returns: collection name

  #check for valid meter name  
  if(!is.null(meter_tmp) && !is.na(meter_tmp) && length(meter_tmp) == 1){
    # return corresponding collection name if meter name is valid
    coll_local <- as.vector(df_meter_list_tmp[df_meter_list_tmp[,2] == meter_tmp, 3]) #df_meter is global
    # coll_local <- as.vector(df_meter[df_meter$meter_name == meter_tmp, 3]) #logical subsetting, select element 
                                                            #from 3rd column where 2nd cloumn matches the condition      
    return (coll_local)
  }
  else {
    print ("My Custom Warning: the value of meter_name is not valid")
    # for invalid meter_name let us use a default meter_name
    # meter_tmp <- "Test Data"
    coll_local <- "test_data"
    return (coll_local)
  }

}