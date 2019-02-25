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
links <- unite(date.times, links, c("Var2","Var1"), sep = "-")


link <- "https://datamine-history.s3.amazonaws.com/gtfs-2018-01-01-09-41"



raw <- GET(link)

feed.message <- gtfs_realtime(raw)
dat <- gtfs_tripUpdates(feed.message) 

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


# Convert data classes
onetrain_stoptime$arrival_time <- as.numeric(as.character(onetrain_stoptime$arrival_time))
onetrain_stoptime$arrival_delay <- as.numeric(as.character(onetrain_stoptime$arrival_delay))
onetrain_stoptime$departure_time <- as.numeric(as.character(onetrain_stoptime$departure_time))
onetrain_stoptime$departure_delay <- as.numeric(as.character(onetrain_stoptime$departure_delay))

# Convert times from # of seconds since POSIX time (1970-01-01 00:00:00)
class(onetrain_stoptime$arrival_time) <- c('POSIXt','POSIXct')
class(onetrain_stoptime$departure_time) <- c('POSIXt', 'POSIXct')

# Fix 0 cells to be NA (not sure if this best approach?)
arrivalsNA <- which(onetrain_stoptime$arrival_time < "2017-12-31")
onetrain_stoptime$arrival_time[arrivalsNA] <- NA
departNA <- which(onetrain_stoptime$departure_time < "2017-12-31")
onetrain_stoptime$departure_time[departNA] <- NA

# Subset South Ferry trains only
onetrain_stoptime_sub <- onetrain_stoptime[onetrain_stoptime$stop_id=="142S",]

# Put the rows in order of time
onetrain_stoptime_sub[order(onetrain_stoptime_sub$arrival_time),]
