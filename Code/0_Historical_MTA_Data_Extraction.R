#################################################
####### 0b. Historical Data Extraction ##########
#################################################

# NOTE: This code takes a very long time to run.
# If you want to use the extracted data, please
# see the folders Data/Raw/ and Data/Clean/

# Set path
path <-"Data/Raw/"

suppressPackageStartupMessages(require(httr))
suppressPackageStartupMessages(require(gtfsway))
suppressPackageStartupMessages(require(lubridate))
suppressPackageStartupMessages(require(tidyr))


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
  raw <- GET(link, timeout = 240)
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
    if(dim(dat[[i]]$dt_stop_time_update)[1] != 0){
      
      temp <- as.data.frame(as.matrix(dat[[i]]$dt_trip_info))
      onetrain_info <- rbind(onetrain_info, temp)
 
      temp2 <- as.data.frame(as.matrix(dat[[i]]$dt_stop_time_update))
      # Add in train id
      temp2$train_id <- temp$trip_id
      onetrain_stoptime <- rbind(onetrain_stoptime, temp2) 
    } else if (dim(dat[[i]]$dt_stop_time_update)[1] == 0) {
      
      onetrain_stoptime <- as.data.frame(matrix(ncol = 7, nrow = 1, NA))
      colnames(onetrain_stoptime) <- c("stop_sequence","stop_id","arrival_time","arrival_delay","departure_time","departure_delay","train_id")
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
remove_pred <- function(data, linkpos, links){
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
  data.jan[[k]] <- remove_pred(clean_historical(extract_historical(links.jan[[k]])), linkpos = k, links = links.jan)
}
# Save the results
save(data.jan, file = paste(path,"jan2018.RData", sep = ""))

###### EXTRACT DATA: FEBRUARY ######
links.feb<- links[links < "2018-03-01" & links > "2018-01-31-23-56"]
data.feb <- list()
for(k in 1:length(links.feb)){
  data.feb[[k]] <- remove_pred(clean_historical(extract_historical(links.feb[[k]])), linkpos = k, links = links.feb)
}
# Save the results
save(data.feb, file = paste(path,"feb2018.RData", sep = ""))

###### EXTRACT DATA: March ######
links.march<- links[links < "2018-04-01" & links > "2018-02-28-23-56"]
data.march <- list()
for(k in 1:length(links.march)){
  data.march[[k]] <- remove_pred(clean_historical(extract_historical(links.march[[k]])), linkpos = k, links = links.march)
}
# Save the results
save(data.march, file = paste(path,"march2018.RData", sep = ""))

###### EXTRACT DATA: April ######
links.april <- links[links < "2018-05-01" & links > "2018-03-31-23-56"]
data.april <- list()
for(k in 1:length(links.april)){
  data.april[[k]] <- remove_pred(clean_historical(extract_historical(links.april[[k]])), linkpos = k, links = links.april)
}
# Save the results
save(data.april, file = paste(path,"april2018.RData", sep = ""))


###### EXTRACT DATA: May ######
links.may <- links[links < "2018-06-01" & links > "2018-04-30-23-56"]
data.may <- list()
for(k in 1:length(links.may)){
  data.may[[k]] <- remove_pred(clean_historical(extract_historical(links.may[[k]])), linkpos = k, links = links.may)
}
# Save the results
save(data.may, file = paste(path,"may2018.RData", sep = ""))

###### EXTRACT DATA: June ######
links.june <- links[links < "2018-07-01" & links > "2018-05-31-23-56"]
data.june <- list()
for(k in 1:length(links.june)){
  data.june[[k]] <- remove_pred(clean_historical(extract_historical(links.june[[k]])), linkpos = k, links = links.june)
}
# Save the results
save(data.june, file = paste(path,"june2018.RData", sep = ""))

###### EXTRACT DATA: July ######
links.july <- links[links < "2018-08-01" & links > "2018-06-30-23-56"]
data.july <- list()
for(k in 1:length(links.july)){
  # MTA missing link at k = 4416, skipping ahead
  if(k = 4416){
      
    } else {
    data.july[[k]] <- remove_pred(clean_historical(extract_historical(links.july[[k]])), linkpos = k, links = links.july)
    }
}


###### EXTRACT DATA: August ######
links.aug <- links[links < "2018-09-01" & links > "2018-07-31-23-56"]
data.aug <- list()
for(k in 1:length(links.aug)){
  # MTA missing file for the following links, skip ahead
  if(k == 3677 | k == 4840 | k == 4996 | k == 5334 | k == 5573 | k == 5664){
    
  } else {
    data.aug[[k]] <- remove_pred(clean_historical(extract_historical(links.aug[[k]])), linkpos = k, links = links.aug)
  }
}
# Save the results
save(data.aug, file = paste(path,"aug2018.RData", sep = ""))

