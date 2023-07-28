# this script takes downloaded PurpleAir data and prepares it for analysis

# load packages
library(tidyverse)


#### read data
# list files in the directory, keep the file path
purpledata <- list.files("data/purpleair/PurpleAir Download 7-27-2023", pattern = ".csv", full.names = F)
# grab the sensor ids from the file names
ids = unlist(lapply( strsplit(purpledata, split = " "), function(z) z[[1]]))
# read each file and add an id column
df = NULL
for( i in 1:length(purpledata) ){
  dat = read_csv( paste("data/purpleair/PurpleAir Download 7-27-2023",purpledata[[i]], sep = "/")  )
  dat$id = ids[i]
  df <- rbind(df,dat)
}


#### write to disk
write_csv(df, "output/purpleair_clean.csv")



### visualize
ggplot(df, aes(x = time_stamp, y = temperature, col = id)) +
  geom_line()
