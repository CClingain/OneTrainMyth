########################################
####### 1b. Historical Import ##########
########################################


require(gtfsway)
require(httr)

link <- "https://datamine-history.s3.amazonaws.com/gtfs-2018-01-01-09-31"
raw <- GET(link)

feed.message <- gtfs_realtime(raw)
dat <- gtfs_tripUpdates(feed.message) 
