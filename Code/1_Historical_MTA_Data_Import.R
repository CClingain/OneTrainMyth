########################################
####### 1b. Historical Import ##########
########################################


require(gtfsway)
require(httr)

link <- "https://datamine-history.s3.amazonaws.com/gtfs-2018-03-01-06-51"
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

# Save the current data
# save(onetrain_stoptime_sub, file = paste("Data/Clean/onetrain_stoptime",Sys.Date(),"_clean",".RData", sep = ""))
