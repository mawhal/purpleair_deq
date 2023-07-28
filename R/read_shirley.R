read_shirley = function(data){
  
# test data
# data = "data/deq/Shirley PM minute report202307050601.XLS"

# grab date information from the file
shirley <- read_excel(data, sheet =1)
  #extract date
  shirley[3,12]
  date = mdy( shirley[3,12] )

#extract data 
shirley = read_excel(data, skip = 11, sheet = 1)
#select columns with data
shirley = shirley[,c(1,4,7)]


# rename columns 
colnames(shirley) = c("time","PM10","PM25")

# delete statistic rows 
shirley = shirley[1:1440,]
# tail(shirley)

# replace date information
shirley$time = as_hms(shirley$time)
# paste the date
shirley$time_stamp <- ymd_hms( paste( date, shirley$time ) )

return(shirley)
}