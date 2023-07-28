# this script takes output from data processing scripts for DEQ and PurpleAir
# it combines the data sources and analyzes them
# identify correlations between sensors


# load libraries
library(tidyverse)

# read the data and rename columns
deq  <- read_csv("output/deq_data_merge.csv")
names(deq)  <- c("time","pm10deq","pm25deq","time_stamp")
# deq$sensor.id = "DEQ"
deq$pm10deq <- as.numeric(deq$pm10deq)
deq$pm25deq <- as.numeric(deq$pm25deq)

purp <- read_csv("output/purpleair_clean.csv")
names(purp) <- c("time_stamp","humidity","temperature","pm25purp","pm10purp","sensor.id")
purp$sensor.id <- as.character(purp$sensor.id)


## issue 1
# DEQ data recorded every minute, while PurpleAir recorded every ten minutes
# solution?
#   - 1) reduce DEQ dataset to only show data collected on the hour and in ten-minute increments
#   - 2) average DEQ data every ten minutes
#   

# option 1
# let's try to merge the dataset based on time_stamp
dcombine <- left_join( deq, purp )
dcombine$sensor.id[ is.na(dcombine$sensor.id) ] <- "DEQ"



## plot the correlations


# look for correlations among purpleair monitors
purp.wide <- purp %>% 
  group_by(time_stamp, sensor.id) %>% 
  summarize( pm10purp = mean(pm10purp)) %>% 
  select(time_stamp,sensor.id,pm10purp) %>% 
  pivot_wider( names_from = sensor.id, values_from = pm10purp )
library(psych)
pairs.panels(purp.wide[2:4])


### let's graph time series together
dlong10 <- dcombine %>% 
  select(time_stamp, pm10deq, pm10purp, sensor.id) %>% 
  pivot_longer( cols = pm10deq:pm10purp )
dlong10 <- dlong10[ !is.na(dlong10$value), ]


ggplot( data = dlong10, aes(x = time_stamp, y = value, col = sensor.id)) +
  facet_wrap(~sensor.id) + geom_line( alpha = 0.5)


# between DEQ and PurpleAir
dlong10$method <- ifelse(dlong10$sensor.id == "DEQ", "DEQ", "PurpleAir")
dlong10.mean <- dlong10 %>% 
  group_by(time_stamp, method) %>% 
  summarize( pm10 = mean(value))
dwide10 <- dlong10.mean %>% 
  pivot_wider( names_from = method, values_from = pm10)
plot(dcombine$pm10deq, dcombine$pm10purp )
abline(a = 0, b = 1)
plot(dcombine$pm25deq, dcombine$pm25purp )
abline(a = 0, b = 1)



