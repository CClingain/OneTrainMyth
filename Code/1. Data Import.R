#################################
####### 1. Data Import ##########
#################################


devtools::install_github("SymbolixAU/gtfsway")
library(gtfsway)
library(httr)
library(jsonlite)

url <- "http://datamine.mta.info/mta_esi.php?key=51469dd0902e2edb2e1a327a2c413334&feed_id=1"

test <- GET(url)

# Check request went through (200 = good)
test$status_code

head(test$content)

# Process API request content
test_content <- content(test)

# Now, when we check the content type, we see that it's application 
test
# This suggests we need something specialized to handle the data, which is gtfs

# Try the gtfsway package approach
FeedMessage <- gtfs_realtime(test)
lst <- gtfs_tripUpdates(FeedMessage) 

# Check data
lst[[1]]

# We have two data frames! However it looks like we may have other train data as well.
# We'll need to filter out the 1 train data, specifically the South Ferry stops.
# Based on the documentation, appears stops have a code. S = Southbound, 
# first digit may be train line, middle digits TBD


# Unlisting data

onetrain_info <- NULL
onetrain_stoptime <- NULL

# Code idea
for(i in 1:length(lst)) {
  temp <- as.data.frame(as.matrix(lst[[i]]$dt_trip_info))
  onetrain_info <- rbind(onetrain_info, temp)
  
  temp2 <- as.data.frame(as.matrix(lst[[i]]$dt_stop_time_update))
  onetrain_stoptime <- rbind(onetrain_stoptime, temp2)
}

# Based on MTA website, South Ferry is stop 142
# See: http://web.mta.info/developers/data/nyct/subway/Stations.csv

# Export current data
save(onetrain_info, file = "Data/onetrain_infoJan31.RData")
save(onetrain_stoptime, file = "Data/onetrain_stoptimeJan31.RData")
