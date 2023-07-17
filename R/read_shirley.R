library(tidyverse)
library(lubridate)

#read exel sheet
shirley = read_csv("/Users/Jazlyn/Downloads/shirley.csv")


#extract date
class(shirley)
dim(shirley)
shirley[3,12]
date = shirley[3,12]
mdy(date)


#extract data 
shirley = read_csv("/Users/Jazlyn/Downloads/shirley.csv",skip = 11)
shirley
#select columns with data
shirley=shirley[,c(1,4,7)]


#rename columns 

colnames(shirley) = c("time","PM10","PM25")

#delete statistic rows 

shirley = shirley[1:1440,]
tail(shirley)


#combine date and time 

shirley$time=paste(date,shirley$time)
class(shirley$time)
shirley$time = mdy_hm(shirley$time)


#plot time series 

ggplot(shirley,aes(x=time,y=PM10))+geom_path

ggplot(shirley,aes(x=time,y=PM25))+geom_path()

library(readxl)

shirley <- read_excel("Shirley PM minute report202307050601.xls", sheet =1)
