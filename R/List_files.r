# vector of file names
files <- list.files(path = "data/deq/", pattern = ".XLS")
files



library(tidyverse)
library(lubridate)
library(readxl)


source("R/read_shirley.r")
read_shirley(files[[1]])

str(files)
files
shirley = lapply(files,read_shirley)
str(shirley)
lapply(shirley, head)
