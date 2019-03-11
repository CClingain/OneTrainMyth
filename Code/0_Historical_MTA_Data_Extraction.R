#################################################
####### 0b. Historical Data Extraction ##########
#################################################



require(gtfsway)
require(httr)

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

for(i in 1:length(links)){
  
  link <- paste("https://datamine-history.s3.amazonaws.com/gtfs-",links[i], sep = "")
  # Get the raw data
  raw <- GET(link)
  # Convert it from gtfs format
  feed.message <- gtfs_realtime(raw)
  dat <- gtfs_tripUpdates(feed.message) 
  
  # Initiate storage
  onetrain_info <- NULL
  onetrain_stoptime <- NULL
}


# Extract from lists
for(i in 1:length(dat)) {
  temp <- as.data.frame(as.matrix(dat[[i]]$dt_trip_info))
  onetrain_info <- rbind(onetrain_info, temp)
  
  temp2 <- as.data.frame(as.matrix(dat[[i]]$dt_stop_time_update))
  # Add in train id
  temp2$train_id <- temp$trip_id
  onetrain_stoptime <- rbind(onetrain_stoptime, temp2)
  
}


# Function to extract historical data
extract_historical <- function(url){
  link <- paste("https://datamine-history.s3.amazonaws.com/gtfs-",url, sep = "")
  # Get the raw data
  raw <- GET(link)
  # Convert it from gtfs format
  feed.message <- gtfs_realtime(raw)
  dat <- gtfs_tripUpdates(feed.message) 
  
  # Initiate storage
  onetrain_info <- NULL
  onetrain_stoptime <- NULL
  
  
  # Extract from lists
  for(i in 1:length(dat)) {
    temp <- as.data.frame(as.matrix(dat[[i]]$dt_trip_info))
    onetrain_info <- rbind(onetrain_info, temp)
    
    temp2 <- as.data.frame(as.matrix(dat[[i]]$dt_stop_time_update))
    # Add in train id
    temp2$train_id <- temp$trip_id
    onetrain_stoptime <- rbind(onetrain_stoptime, temp2)
    
  
  }
  return(onetrain_stoptime)
}

# Function to clean historical data
clean_historical <- function(data){
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
  
  return(data_sub)
}

# Function to subset out predicted times
remove_pred <- function(data, linkpos){
  # get the date from current link
   date <- links[[linkpos]]
  # remove cases after that date
   data2 <- data[data$arrival_time <= date,]
   return(data2)
}

# Get data for all date/times
for(i in 1:length(links)){
  dat <- extract_historical(links[i])
  
  dat_clean <- remove_pred(clean_historical(dat), linkpos = i)
  
}
# Run for all links
# Test:
start <- Sys.time()
mini <- as.list(mini)
testfun <- lapply(1:length(mini), function(i) remove_pred(clean_historical(extract_historical(mini[i])),linkpos = i) )
end <- Sys.time()
end - start
# how long will this take to run?
timefor1 <- (end-start)/10
fulltime <- as.numeric(timefor1*length(links))
fulltime <- (fulltime/60)/60 #divide by 60 for sec/min, divide by 60 for min/hr
fulltime # in hours
# Full: 
links <- as.list(links)
data <- lapply(1:length(links), function(i) remove_pred(clean_historical(extract_historical(links[i])),linkpos = i) )
# breaks after 161

# try with loop?
data <- list()
for(k in 1:length(links)){
  data <- remove_pred(clean_historical(extract_historical(links[[k]])), linkpos = k)
}
# also breaks at 161
# looks like error comes at extract_historical function
# as.matrix(dat[[i]]$dt_trip_info) returns subscript out of bounds