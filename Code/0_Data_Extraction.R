#################################
####### 1. Data Import ##########
#################################


# devtools::install_github("SymbolixAU/gtfsway")
# require(taskscheduleR)
require(gtfsway)
require(httr)
require(jsonlite)

# Get data
url <- "http://datamine.mta.info/mta_esi.php?key=51469dd0902e2edb2e1a327a2c413334&feed_id=1"
test <- GET(url)
FeedMessage <- gtfs_realtime(test)
lst <- gtfs_tripUpdates(FeedMessage) 

# Initiate storage
onetrain_info <- NULL
onetrain_stoptime <- NULL

# Extract data into dataframes
for(i in 1:length(lst)) {
  temp <- as.data.frame(as.matrix(lst[[i]]$dt_trip_info))
  onetrain_info <- rbind(onetrain_info, temp)
  
  temp2 <- as.data.frame(as.matrix(lst[[i]]$dt_stop_time_update))
  onetrain_stoptime <- rbind(onetrain_stoptime, temp2)
}

# Set time that will be used to label all files
time <- Sys.time()

# Save Raw data
save(onetrain_info, file = paste("C:/Users/Clare/Documents/Spring 2019 Educaton Data Science Practicum/edsp2019project-CClingain/Data/Raw/onetrain_info",time,".RData", sep = ""))
save(onetrain_stoptime, file = paste("C:/Users/Clare/Documents/Spring 2019 Educaton Data Science Practicum/edsp2019project-CClingain/Data/Raw/onetrain_stoptime",time,".RData", sep = ""))

# Load Raw data
load(paste("C:/Users/Clare/Documents/Spring 2019 Educaton Data Science Practicum/edsp2019project-CClingain/Data/Raw/onetrain_stoptime",time,".RData", sep = ""))

# Convert data classes
onetrain_stoptime$arrival_time <- as.numeric(as.character(onetrain_stoptime$arrival_time))
onetrain_stoptime$arrival_delay <- as.numeric(as.character(onetrain_stoptime$arrival_delay))
onetrain_stoptime$departure_time <- as.numeric(as.character(onetrain_stoptime$departure_time))
onetrain_stoptime$departure_delay <- as.numeric(as.character(onetrain_stoptime$departure_delay))

# Convert times from # of seconds since POSIX time (1970-01-01 00:00:00)
class(onetrain_stoptime$arrival_time) = c('POSIXt','POSIXct')
class(onetrain_stoptime$departure_time) = c('POSIXt', 'POSIXct')

# Fix 0 cells to be NA (not sure if this best approach?)
arrivalsNA <- which(onetrain_stoptime$arrival_time < "2019-01-01")
onetrain_stoptime$arrival_time[arrivalsNA] <- NA
departNA <- which(onetrain_stoptime$departure_time < "2019-01-01")
onetrain_stoptime$departure_time[departNA] <- NA

# Subset South Ferry trains only
onetrain_stoptime_sub <- onetrain_stoptime[onetrain_stoptime$stop_id=="142S",]

# Save the clean data
save(onetrain_stoptime_sub, file = paste("C:/Users/Clare/Documents/Spring 2019 Educaton Data Science Practicum/edsp2019project-CClingain/Data/Clean/onetrain_stoptime",time,"_clean",".RData", sep = ""))