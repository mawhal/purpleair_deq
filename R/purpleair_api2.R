#the purpose of this script is to pull the most recent 2 weeks of data from a list of sensors
#and then compile it over time
#requirement: maintain sensorindex_name csv as new sensors are deployed


#to be usable within this file
library(readr) 
library(lubridate) 
library(httr) 

#contact purpleair support at contact@purpleair.com to request your API keys
#they are typically very speedy
#the historical endpoint was recently restricted, so you may specifically need 
#to ask for access to it
read_key <- "023A8F99-2BC6-11EE-A77F-42010A800009"
write_key <- "9846ED2B-2BC8-11EE-A77F-42010A800009"

#getting the list of sensor indexes
#this needs to be manually updated as new sensors are brought online
#the sensor index can be found by clicking the sensor on the live map after select= in the URL
#this is pulling from a simple table with column headers "sensor_index" and "name_on_map"
sensorindex_name <- read.csv("data/sensorindex_name.csv", fileEncoding="UTF-8-BOM")
sensor_list <- as.list(sensorindex_name$sensor_index)

#manipulating the URL
#the URL is customizable, you can test how adding and removing elements looks at https://api.purpleair.com/
#i have included only the fields I thought were necessary for the scope of my data review
#this code makes the end time the current time and the start time 2 weeks before the end time
#2 weeks is the max time period you can request at one time for hourly data
URL <- "https://api.purpleair.com/v1/sensors/sensor_index/history/csv?start_timestamp=starttime&end_timestamp=endtime&average=60&fields=pm2.5_cf_1_a%2Chumidity%2Ctemperature"
endtime <- as.integer(Sys.time())
twoweeks <- 1209600 #604800 is the number of units the unix timestamp elapses in two weeks
starttime <- endtime-twoweeks
URL <- sub('starttime', starttime, URL)
URL <- sub('endtime', endtime, URL)

#looping sensor_index over the URL, writing output to text files
#not sure if there is a better way to parse out the data
#this does preserve each request as a unique text file, which is partially what I wanted
#PurpleAir support has asked that you send no more than one request every 1-10 minutes
#hence the forced pause in the code
for (i in sensor_list)
{
  request_URL <- sub('sensor_index', i, URL)
  data <- GET(request_URL,add_headers('X-API-Key'=read_key))
  data <- content(data, "raw")
  writeBin(data, paste(i,starttime,endtime,".txt", sep="_"))
  flush.console() #this makes sys.sleep work in a loop?
  Sys.sleep(60) 
}

#reading in the files
filepath = getwd()
outputdata_list <- list.files(path=filepath, pattern=".txt")
for (i in 1:length(outputdata_list)){
  assign(outputdata_list[i], 
         read.table(outputdata_list[i], sep=",", header=TRUE)
  )}

#merging the imported data frames
#the time conversion automatically makes it the current timezone according to R
#in my script, I adjust R's timezone to EST so it matches our regulatory monitors
#don't have to worry about converting from UTC (default time zone in PA data)
sensor_history <- do.call(rbind.data.frame, mget(ls(pattern = ".txt")))
row.names(sensor_history) <- NULL #row labels were from original files and ugly
sensor_history$time_stamp <- as.POSIXct(sensor_history$time_stamp, origin="1970-01-01") #better datetime format
sensor_history <- unique(sensor_history) #removes overlapping days, don't have to worry about getting data exactly once every 2 weeks
sensor_history <- merge(sensor_history, sensorindex_name[, c("sensor_index", "name_on_map")], by="sensor_index") #adds name on map to merged df
sensor_history <- sensor_history[c("time_stamp", "sensor_index", "name_on_map", "rssi", "uptime", "pa_latency", "memory", "humidity", "temperature", "pressure", "pm2.5_atm_a", "pm2.5_atm_b", "pm2.5_cf_1_a", "pm2.5_cf_1_b", "pm2.5_alt_a", "pm2.5_alt_b")]

#saving the merged file for further analysis
write.csv(sensor_history, file="sensor_history.csv")