#################################################
####### 0b. Historical Data Extraction ##########
#################################################

suppressPackageStartupMessages(require(httr))
suppressPackageStartupMessages(require(gtfsway))
suppressPackageStartupMessages(require(lubridate))



# time stamps to cycle through
minstamps <- c("01","06","11","16","21","26","31","36","41","46","51","56")
hourstamps <- c("00","01","02","03","04","05","06","07","08","09","10","11",
                "12","13","14","15","16","17","18","19","20","21","22","23")
timestamps <- matrix(ncol = length(hourstamps), nrow = length(minstamps))
for(i in 1:length(hourstamps)){
  for(j in 1:length(minstamps)){
  timestamps[j,i] <- paste(hourstamps[i],minstamps[j], sep = "-")
  }
}
timestamps <- as.vector(timestamps)
# Dates
as.Date("2018-09-30") - as.Date("2018-01-01") 
dates <- seq(as.Date("2018-01-01"), by = "day", length.out = 272)

# All possible date-times
date.times <- expand.grid(timestamps, dates)
# All possible links
require(tidyr)
require(lubridate)
links <- unite(date.times, links, c("Var2","Var1"), sep = "-")
links <- links$links
#class(links$links) <- c("POSIXt", "POSIXct")
#links <- parse_date_time(links$links, order = '%Y %m %d %H %M')

# Function to extract historical data
extract_historical <- function(url){
  # show current position
  print(url)
  link <- paste("https://datamine-history.s3.amazonaws.com/gtfs-",url, sep = "")
  # Get the raw data
  raw <- GET(link, timeout = 60)
  # Convert it from gtfs format
  feed.message <- gtfs_realtime(raw)
  dat <- gtfs_tripUpdates(feed.message) 
  
  # Initiate storage
  onetrain_info <- NULL
  onetrain_stoptime <- NULL
  
  if(length(dat)==0){
    onetrain_stoptime <- as.data.frame(matrix(ncol = 7, nrow = 1, NA))
    colnames(onetrain_stoptime) <- c("stop_sequence","stop_id","arrival_time","arrival_delay","departure_time","departure_delay","train_id")
  } else if(length(dat)!=0){
  # Extract from lists
  for(i in 1:length(dat)) {
    
    # if there was a live update, extract
    if(dim (dat[[i]]$dt_stop_time_update)[1] != 0){
      
    temp <- as.data.frame(as.matrix(dat[[i]]$dt_trip_info))
    onetrain_info <- rbind(onetrain_info, temp)
 
    temp2 <- as.data.frame(as.matrix(dat[[i]]$dt_stop_time_update))
    # Add in train id
    temp2$train_id <- temp$trip_id
    onetrain_stoptime <- rbind(onetrain_stoptime, temp2) 
    } else {
      onetrain_stoptime <- as.data.frame(matrix(ncol = 7, nrow = 1, NA))
      
    }
  }
  
  }
  return(onetrain_stoptime)
}

# Function to clean historical data
clean_historical <- function(data){
  
  # If the data was empty to begin with, just return the NAs
  if(dim(data)[1]==1){
    data_sub <- as.data.frame(matrix(ncol = 7, nrow = 1, NA))
    colnames(data_sub) <- c("stop_sequence","stop_id","arrival_time","arrival_delay","departure_time","departure_delay","train_id")
    
  } else { 
  
  # Convert data classes
  data$arrival_time <- as.numeric(as.character(data$arrival_time))
  data$arrival_delay <- as.numeric(as.character(data$arrival_delay))
  data$departure_time <- as.numeric(as.character(data$departure_time))
  data$departure_delay <- as.numeric(as.character(data$departure_delay))
  
  # Convert times from # of seconds since POSIX time (1970-01-01 00:00:00)
  class(data$arrival_time) <- c('POSIXt','POSIXct')
  class(data$departure_time) <- c('POSIXt', 'POSIXct')
  
  # Fix 0 cells to be NA (not sure if this best approach?)
  arrivalsNA <- which(data$arrival_time < "2017-12-31")
  data$arrival_time[arrivalsNA] <- NA
  departNA <- which(data$departure_time < "2017-12-31")
  data$departure_time[departNA] <- NA
  
  # Subset South Ferry trains only
  data_sub <- data[data$stop_id=="142S",]
  
  # Put the rows in order of time
  data_sub[order(data_sub$arrival_time),]
  }
  return(data_sub)
}

# Function to subset out predicted times
remove_pred <- function(data, linkpos){
  # get the date from current link
   date <- links[[linkpos]]
   # convert to date object
   date <- parse_date_time(date, "%Y %m %d %H %M", tz = "EST")
  # remove cases after that date
   data2 <- data[data$arrival_time <= date,]
   return(data2)
}

###### EXTRACT DATA: JANUARY######
# test with week 1 of jan
links.jan <- links[links < "2018-02-01-00-01"]
data.jan <- list()
for(k in 1:length(links.jan)){
  data.jan[[k]] <- remove_pred(clean_historical(extract_historical(links.jan[[k]])), linkpos = k)
}
# Save the results
save(data.jan, file = "Data/Raw/jan2018.Rdata")
# 3/11/2019 - 4:37pm save out where loop stopped at 01-03-16-16
#save(data.jan,file="Data/Raw/jan2018_1_through_break.Rdata")

###### EXTRACT DATA: FEBRUARY ######
links.feb<- links[links < "2018-03-01" & links > "2018-01-31-23-56"]
data.feb <- list()
for(k in 1:length(links)){
  data.feb[[k]] <- remove_pred(clean_historical(extract_historical(links[[k]])), linkpos = k)
}
# Save the results
save(data.feb, file = "Data/Raw/feb2018.Rdata")

###### EXTRACT DATA: March ######
links.march<- links[links < "2018-04-01" & links > "2018-02-28-23-56"]
data.march <- list()
for(k in 1:length(links)){
  data.march[[k]] <- remove_pred(clean_historical(extract_historical(links[[k]])), linkpos = k)
}
# Save the results
save(data.march, file = "Data/Raw/march2018.Rdata")
