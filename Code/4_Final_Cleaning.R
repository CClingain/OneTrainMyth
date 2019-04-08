########################################
####### 4. Final Data Cleaning #########
########################################

# I noticed through the extract/clean process that not all of the predicted
# arrival times were removed for April-August. I think this may be due to 
# daylights saving time. Time zone changes. This script will fix that. 


# Set path
path <-"Data/Clean/"

suppressPackageStartupMessages(require(lubridate))
suppressPackageStartupMessages(require(tidyr))


# Load the data
load("Data/Raw/jan2018.RData")
load("Data/Raw/feb2018.RData")
load("Data/Raw/march2018.RData")
load("Data/Raw/april2018.RData")
load("Data/Raw/may2018.RData")
load("Data/Raw/june2018.RData")
load("Data/Raw/july2018.RData")
load("Data/Raw/aug2018.RData")


remove_pred2 <- function(data, linkpos, links){
  # get the date from current link
  date <- links[[linkpos]]
  # convert to date object
  date <- parse_date_time(date, "%Y %m %d %H %M", tz = "EST5EDT")
  # remove cases after that date
  data2 <- data[data$arrival_time <= date,]
  return(data2)
}


### Remove the predicted values
# August
aug_clean <- list()
for(j in 1:length(data.aug)){
  aug_clean[[j]] <- remove_pred2(data.aug[[j]], linkpos = j, link = links.aug)
  print(j)
}
# Save the results
save(aug_clean, file = paste(path,"aug_clean.RData", sep = ""))

# January
jan_clean <- list()
for(j in 1:length(data.jan)){
  jan_clean[[j]] <- remove_pred2(data.jan[[j]], linkpos = j, link = links.jan)
  print(j)
}
# Save the results
save(jan_clean, file = paste(path,"jan_clean.RData", sep = ""))

# February
feb_clean <- list()
for(j in 1:length(data.feb)){
  feb_clean[[j]] <- remove_pred2(data.feb[[j]], linkpos = j, link = links.feb)
  print(j)
}
# Save the results
save(feb_clean, file = paste(path,"feb_clean.RData", sep = ""))

# March
march_clean <- list()
for(j in 1:length(data.march)){
  march_clean[[j]] <- remove_pred2(data.march[[j]], linkpos = j, link = links.march)
  print(j)
}
# Save the results
save(march_clean, file = paste(path,"march_clean.RData", sep = ""))

# April
april_clean <- list()
for(j in 1:length(data.april)){
  april_clean[[j]] <- remove_pred2(data.april[[j]], linkpos = j, link = links.april)
  print(j)
}
# Save the results
save(april_clean, file = paste(path,"april_clean.RData", sep = ""))

# May
may_clean <- list()
for(j in 1:length(data.may)){
  may_clean[[j]] <- remove_pred2(data.may[[j]], linkpos = j, link = links.may)
  print(j)
}
# Save the results
save(may_clean, file = paste(path,"may_clean.RData", sep = ""))

# June
june_clean <- list()
for(j in 1:length(data.june)){
  june_clean[[j]] <- remove_pred2(data.june[[j]], linkpos = j, link = links.june)
  print(j)
}
# Save the results
save(june_clean, file = paste(path,"june_clean.RData", sep = ""))

# July
july_clean <- list()
for(j in 1:length(data.july)){
  july_clean[[j]] <- remove_pred2(data.july[[j]], linkpos = j, link = links.july)
  print(j)
}
# Save the results
save(july_clean, file = paste(path,"july_clean.RData", sep = ""))