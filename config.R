
#for server.R
dbName = "data"  #main db
dbAgg = "aggregation"  #aggregation db
host = "10.129.23.41"
# localhost = "127.0.0.1"
port = "27017"
# coll = "power_k_a"

params = c("Energy","Power","Current","Voltage","Power Factor")   

keys = '{"TS":1, "W":1, "_id": 0}' #for kresit

a_keys = '{"TS":1, "AvgW":1, "_id": 0}' #for aravali


# start_time = "2017-02-28 7:00:00"
# end_time = "2017-02-28 7:01:00"
# start_hr <- 0; 
start_min <- 00
# end_hr <- 1; 
end_min <- 59


#for ui.R
#for kresit meters
df_meter <- read.csv(file="meter_list.csv", header=TRUE, sep=",") #alternate options: json file/sqlite db
# meter_names <- df_meter[,2] #returns a factor #works but not as expected
meter_names <- as.vector(df_meter[,2]) #select the column containing the 
											   #meter names, returns a character vector
# collection_names <- as.vector(df_meter[,3]) #select the column containing the 
											   #collection names, returns a character vector
#for aravali meters
a_df_meter <- read.csv(file="aravali_meter_list.csv", header=TRUE, sep=",")
a_meter_names <- as.vector(a_df_meter[,2])

meters = c("KReSIT Mains","KReSIT HVAC","KReSIT Plugs",
           "Classroom ODU1","Classroom ODU2","Classroom ODU3",
           "Lab ODU1","Lab ODU2","Lab ODU3")

month =c("Jan","Feb","Mar","Apr","May","June","July","Aug","Sep","Oct","Nov","Dec")
week = 1:52
