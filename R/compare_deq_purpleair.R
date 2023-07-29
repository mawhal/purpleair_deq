# this script takes output from data processing scripts for DEQ and PurpleAir
# it combines the data sources and analyzes them
# identify correlations between sensors


# load libraries
library(tidyverse)
library(psych)

# read the data and rename columns
deq  <- read_csv("output/deq_data_merge.csv")
names(deq)  <- c("time","pm10deq","pm25deq","time_stamp")
# deq$sensor.id = "DEQ"
deq$pm10deq <- as.numeric(deq$pm10deq)
deq$pm25deq <- as.numeric(deq$pm25deq)
unique(date(deq$time_stamp))

purp <- read_csv("output/purpleair_clean.csv")
names(purp) <- c("time_stamp","humidity","temperature","pm25purp","pm10purp","sensor.id")
purp$sensor.id <- as.character(purp$sensor.id)


# look for correlations among purpleair monitors
purp.wide <- purp %>% 
  group_by(time_stamp, sensor.id) %>% 
  summarize( pm10purp = mean(pm10purp)) %>% 
  select(time_stamp,sensor.id,pm10purp) %>% 
  pivot_wider( names_from = sensor.id, values_from = pm10purp )

pairs.panels(purp.wide[2:4])
# highly correlated
# take the mean across all sensors and use this for comparison to DEQ
purp.mean <- purp %>% 
  group_by(time_stamp) %>% 
  summarize( pm10purp = mean(pm10purp))


## issue 1
# DEQ data recorded every minute, while PurpleAir recorded every ten minutes
# solution?
#   - 1) reduce DEQ dataset to only show data collected on the hour and in ten-minute increments
#   - 2) average DEQ data every ten minutes
#   

# option 1
# let's try to merge the dataset based on time_stamp
dcombine <- left_join( deq, purp.mean )



## plot the correlations

# remove NA
dcomplete <- dcombine[ complete.cases(dcombine), ]
dcomplete$pm10deqlog <- log(dcomplete$pm10deq)
dcomplete$pm10purplog <- log(dcomplete$pm10purp)
# correlation test
cor.deq.purple <- cor.test( dcomplete$pm10deq, dcomplete$pm10purp )
cor.deq.purple$estimate
cor.deq.purple$conf.int
lm.deq.purple <- lm(pm10purp ~ pm10deq, data = dcomplete)

# set x and y limits
xylim <- range( c(dcomplete$pm10deq, dcomplete$pm10purp), na.rm = T )
svg("output/correlation_deq_purplemean.svg", width = 3, height = 3)
par(mar = c(5,4,2,2)+0.1, pty = "s", las = 1  )
plot(dcomplete$pm10deqlog, dcomplete$pm10purplog, 
     # cex = 0.5, xlim = c(0,xylim[2]), ylim = c(0,xylim[2]),
     xlab = expression(paste("PM10 DEQ (", mu, "g/",m^3,")")),
     ylab = expression(paste("PM10 PurpleAir (", mu, "g/",m^3,")")),
     type = "n" )
points( dcomplete$pm10deqlog, dcomplete$pm10purplog, col = "slateblue")
abline(a = 0, b = 1, col = 'red')
abline(lm.deq.purple)
text( x = 50, y = 140,
      labels = paste0("r = ", round(cor.deq.purple$estimate,3)), 
     adj = 0, cex = 0.75 )
text(125,125,labels = "1:1", adj = 0.5, pos = 3, 
     cex = 0.75, srt = 45, col = "red" )
dev.off()
# slope is the Estimate for pm10deq
summary(lm.deq.purple)$coefficients # slope is ~1.3 and is highly significant
# 

####
# Log-log transform
lm.deq.purple.log <- lm(pm10purplog ~ pm10deqlog, data = dcomplete)
xylim <- range( c(dcomplete$pm10deqlog, dcomplete$pm10purplog), na.rm = T )
svg("output/correlation_deq_purplemean_log.svg", width = 3, height = 3)
par(mar = c(5,4,2,2)+0.1, pty = "s", las = 1  )
plot(dcomplete$pm10deqlog, dcomplete$pm10purplog, 
     cex = 0.5, xlim = xylim, ylim = xylim,
     xlab = expression(paste("PM10 DEQ (", mu, "g/",m^3,")")),
     ylab = expression(paste("PM10 PurpleAir (", mu, "g/",m^3,")")),
     type = "n" )
points( dcomplete$pm10deqlog, dcomplete$pm10purplog, col = "slateblue")
abline(a = 0, b = 1, col = 'red')
abline(lm.deq.purple.log)
text( x = 50, y = 140,
      labels = paste0("r = ", round(cor.deq.purple$estimate,3)), 
      adj = 0, cex = 0.75 )
text(125,125,labels = "1:1", adj = 0.5, pos = 3, 
     cex = 0.75, srt = 45, col = "red" )
dev.off()

# plot time series together
svg("output/time_series_deq_purplemean.svg", width = 6, height = 3)
par(mar = c(5,5,2,2)+0.1, pty = "m", las = 1  )
plot( y = dcomplete$pm10deq, x = dcomplete$time_stamp, type = "n", 
     xlab = "Time",
     ylab = expression(paste("PM10 (", mu, "g/",m^3,")"))  )
points(y = dcomplete$pm10purp, x = dcomplete$time_stamp, pch = 16, cex = 0.5,  col = "purple" )
lines( x = dcomplete$time_stamp, y = dcomplete$pm10deq )
dev.off()



# detemine which dates are represented
unique(date(dcomplete$time_stamp))
