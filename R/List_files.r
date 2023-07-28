# vector of file names
files <- list.files(path = "data/deq/", pattern = ".XLS", full.names = T)
files


# load packages
library(tidyverse)
library(lubridate)
library(hms)
library(readxl)

# read the function from another R script
source("R/read_shirley.r")
# test read
# read_shirley(files[[1]])

# read multiple files at once
shirley = lapply(files,read_shirley)
str(shirley)
lapply(shirley, head)


# let's combine all list elements into a single data.frame
shirley.long = do.call( rbind, shirley )


## write to disk
write_csv(shirley.long, "output/deq_data_merge.csv")


