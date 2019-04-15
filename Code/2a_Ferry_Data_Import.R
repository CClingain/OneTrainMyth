########################################
####### 2a. Ferry Data Import ##########
########################################


# The Staten Island Ferry departure and arrival data is contained in a series
# of Excel worksheets. A file exists for each month, with four separate sheets
# indicating the times for arrivals and departures for St. George and Whitehall.

# The issues with this data is how it is structured. Cancelled ferries can only
# be identified by the highlight/coloring of the text. This is tricky for import.
# Additionally, any lateness indicator (i.e., "weather","overcrowding/tourists")
# relate to highlights. I'm not completely interested in *why* boats were late
# or cancelled as opposed to the fact that they were, but I think this odd
# coding may cause some difficulties in the data extraction process.

# Another limitation of the ferry data is that it's not collected on holidays.

# I need to extract 2 sheets: Weekday Whitehall and Weekend Whitehall.

# Test run: first excel file
library(lubridate)
library(readxl)

ferry <- read_excel("Data/Ferry/01 January  2018.xlsx", sheet = 2)

# remove last column
ferry <- ferry[,-ncol(ferry)]

# Rename the columns: Step 1. Capture dates and weekdays
jandates <- paste("Jan",1:31,"2018")
jan <- parse_date_time(jandates, order = "%m %d %Y")
weekdays <- wday(jan, label = T)
jan.full <- cbind.data.frame(jan, weekdays, jandates)
# extract weekdates only
jandates_weekday <- jan.full$jandates[jan.full$weekdays!="Sat"&jan.full$weekdays!="Sun"]
#compress whitespace with .
jandates_weekday <- gsub(x= jandates_weekday, " ",".")
# rename the columns
names(ferry) <- c("Schedule",jandates_weekday,"Schedule")

# NOTE: a wonderful thing about the ferry data is that we now now what
# cutoff makes a ferry a late ferry: 6 minutes.

# Remove extraneous rows (remove the late/missing reasons and NAs)
row.end <- which(ferry$Schedule=="PEAK")
ferry <- ferry[1:(row.end-1),]

# Remove first and last columns which are the ferry schedule
ferry <- ferry[,2:24]

# Get the dates for each column
dates <- as.Date(colnames(ferry), "%B.%d.%Y")

# transpose the data frame so each row is a day
ferry2 <- as.data.frame(t(ferry))

# append dates 
ferry2$date <- dates

# Combine into single columns (date + time)
ferry_final <- NULL
for(i in 2:73){
  temp <- unite(ferry2,temp, c("date",paste("V",i,sep="")), sep = " ")$temp
  ferry_final <- rbind(ferry_final,temp)
} 
# only issue is that it did combine the NAs

# Check missing by row (there should only be 14 missing for there to have been a full schedule)
missing.rows <- apply(ferry2, 1, FUN = function(x)sum(is.na(x)))

# Change to times
ferry_final2 <- apply(ferry_final,2,FUN = function(x)parse_date_time(x, " %Y-%m-%d HM"))
# Convert to data frame and make POSIX objects
ferry_final2  <- as.data.frame(t(ferry_final2))

# Before I fix the classes, I need to get the rows lined up.
remove_nas <- function(data){
  temp <- data
  nonmissing <- which(!is.na(temp))
  ferry_row <- temp[nonmissing]
  
  
  # if it has less than 58 rows
  if(length(ferry_row) < 58){
    num.rows <- length(ferry_row)
    times <- 58 - num.rows
    ferry_row <- append(as.character(ferry_row), rep(NA,times))
    final <- as.numeric(ferry_row)
  } else {
    final <- as.numeric(ferry_row)
  }
  
  return(final)
}
# Apply to all rows
ferry_singlemat <- NULL
for(i in 1:dim(ferry_final2)[1]){
  final <- remove_nas(ferry_final2[i,])
  
  ferry_singlemat <- rbind(ferry_singlemat, final)
}

# rename the columns and the rows
end <- dim(ferry_singlemat)[2]
names <- paste("time",1:end, sep = "")
ferry_singlemat <- as.data.frame(ferry_singlemat)
colnames(ferry_singlemat) <- names
rownames(ferry_singlemat) <- dates

# convert each column to POSIX to get times
for(i in 1:dim(ferry_singlemat)[2]){
  col <- names[i]
  class(ferry_singlemat[,col]) <- c('POSIXt','POSIXct')
  ferry_singlemat[,col] <- with_tz(ferry_singlemat[,col], "UTC")
  #attributes(ferry_singlemat[,col])$tzone <- "UTC"
}
# Save out data
save(ferry_singlemat, file = "Data/Ferry/Clean/ferry_jan.RData")

#### Repeat for February: Weekdays only ####
ferry <- read_excel("Data/Ferry/02 February 2018.xlsx", sheet = 2)

# remove last column
ferry <- ferry[,-ncol(ferry)]

# Rename the columns: Step 1. Capture dates and weekdays
febdates <- paste("Feb",1:28,"2018")
feb <- parse_date_time(febdates, order = "%m %d %Y")
weekdays <- wday(feb, label = T)
feb.full <- cbind.data.frame(feb, weekdays, febdates)
# extract weekdates only
febdates_weekday <- feb.full$febdates[feb.full$weekdays!="Sat"&feb.full$weekdays!="Sun"]
#compress whitespace with .
febdates_weekday <- gsub(x= febdates_weekday, " ",".")
# rename the columns
names(ferry) <- c("Schedule",febdates_weekday,"Schedule")
# Remove extraneous rows (remove the late/missing reasons and NAs)
row.end <- which(ferry$Schedule=="PEAK")
ferry <- ferry[1:(row.end-1),]

# Remove first and last columns which are the ferry schedule
ferry <- ferry[,2:21]

# Get the dates for each column
dates <- as.Date(colnames(ferry), "%B.%d.%Y")

# transpose the data frame so each row is a day
ferry2 <- as.data.frame(t(ferry))

# append dates 
ferry2$date <- dates
# Combine into single columns (date + time)
ferry_final <- NULL
for(i in 2:73){
  temp <- unite(ferry2,temp, c("date",paste("V",i,sep="")), sep = " ")$temp
  ferry_final <- rbind(ferry_final,temp)
} 
# only issue is that it did combine the NAs

# Check missing by row (there should only be 14 missing for there to have been a full schedule)
missing.rows <- apply(ferry2, 1, FUN = function(x)sum(is.na(x)))

# Change to times
ferry_final2 <- apply(ferry_final,2,FUN = function(x)parse_date_time(x, " %Y-%m-%d HM"))
# Convert to data frame and make POSIX objects
ferry_final2  <- as.data.frame(t(ferry_final2))
# Apply to all rows
ferry_singlemat <- NULL
for(i in 1:dim(ferry_final2)[1]){
  final <- remove_nas(ferry_final2[i,])
  
  ferry_singlemat <- rbind(ferry_singlemat, final)
}
# rename the columns and the rows
end <- dim(ferry_singlemat)[2]
names <- paste("time",1:end, sep = "")
ferry_singlemat <- as.data.frame(ferry_singlemat)
colnames(ferry_singlemat) <- names
rownames(ferry_singlemat) <- dates

# convert each column to POSIX to get times
for(i in 1:dim(ferry_singlemat)[2]){
  col <- names[i]
  class(ferry_singlemat[,col]) <- c('POSIXt','POSIXct')
  ferry_singlemat[,col] <- with_tz(ferry_singlemat[,col], "UTC")
  #attributes(ferry_singlemat[,col])$tzone <- "UTC"
}
# Save out data
save(ferry_singlemat, file = "Data/Ferry/Clean/ferry_feb.RData")

#### Repeat for March: Weekdays only ####
ferry <- read_excel("Data/Ferry/03 March 2018.xlsx", sheet = 2)

# remove last column
ferry <- ferry[,-ncol(ferry)]

# Rename the columns: Step 1. Capture dates and weekdays
marchdates <- paste("March",1:31,"2018")
march <- parse_date_time(marchdates, order = "%m %d %Y")
weekdays <- wday(march, label = T)
march.full <- cbind.data.frame(march, weekdays, marchdates)
# extract weekdates only
marchdates_weekday <- march.full$marchdates[march.full$weekdays!="Sat"&march.full$weekdays!="Sun"]
#compress whitespace with .
marchdates_weekday <- gsub(x= marchdates_weekday, " ",".")
# rename the columns
names(ferry) <- c("Schedule",marchdates_weekday,"Schedule")
# Remove extraneous rows (remove the late/missing reasons and NAs)
row.end <- which(ferry$Schedule=="PEAK")
ferry <- ferry[1:(row.end-1),]

# Remove first and last columns which are the ferry schedule
ferry <- ferry[,2:23]

# Get the dates for each column
dates <- as.Date(colnames(ferry), "%B.%d.%Y")

# transpose the data frame so each row is a day
ferry2 <- as.data.frame(t(ferry))

# append dates 
ferry2$date <- dates
# Combine into single columns (date + time)
ferry_final <- NULL
for(i in 2:73){
  temp <- unite(ferry2,temp, c("date",paste("V",i,sep="")), sep = " ")$temp
  ferry_final <- rbind(ferry_final,temp)
} 
# only issue is that it did combine the NAs

# Check missing by row (there should only be 14 missing for there to have been a full schedule)
missing.rows <- apply(ferry2, 1, FUN = function(x)sum(is.na(x)))

# Change to times
ferry_final2 <- apply(ferry_final,2,FUN = function(x)parse_date_time(x, " %Y-%m-%d HM"))
# Convert to data frame and make POSIX objects
ferry_final2  <- as.data.frame(t(ferry_final2))
# Apply to all rows
ferry_singlemat <- NULL
for(i in 1:dim(ferry_final2)[1]){
  final <- remove_nas(ferry_final2[i,])
  
  ferry_singlemat <- rbind(ferry_singlemat, final)
}
# rename the columns and the rows
end <- dim(ferry_singlemat)[2]
names <- paste("time",1:end, sep = "")
ferry_singlemat <- as.data.frame(ferry_singlemat)
colnames(ferry_singlemat) <- names
rownames(ferry_singlemat) <- dates

# convert each column to POSIX to get times
for(i in 1:dim(ferry_singlemat)[2]){
  col <- names[i]
  class(ferry_singlemat[,col]) <- c('POSIXt','POSIXct')
  ferry_singlemat[,col] <- with_tz(ferry_singlemat[,col], "UTC")
  #attributes(ferry_singlemat[,col])$tzone <- "UTC"
}
# Save out data
save(ferry_singlemat, file = "Data/Ferry/Clean/ferry_march.RData")

#### Repeat for April: Weekdays only ####
ferry <- read_excel("Data/Ferry/04 APRIL 2018.xlsx", sheet = 2)

# remove last column
ferry <- ferry[,-ncol(ferry)]

# Rename the columns: Step 1. Capture dates and weekdays
aprildates <- paste("april",1:30,"2018")
april <- parse_date_time(aprildates, order = "%m %d %Y")
weekdays <- wday(april, label = T)
april.full <- cbind.data.frame(april, weekdays, aprildates)
# extract weekdates only
aprildates_weekday <- april.full$aprildates[april.full$weekdays!="Sat"&april.full$weekdays!="Sun"]
#compress whitespace with .
aprildates_weekday <- gsub(x= aprildates_weekday, " ",".")
# rename the columns
names(ferry) <- c("Schedule",aprildates_weekday,"Schedule")
# Remove extraneous rows (remove the late/missing reasons and NAs)
row.end <- which(ferry$Schedule=="PEAK")
ferry <- ferry[1:(row.end-1),]

# Remove first and last columns which are the ferry schedule
ferry <- ferry[,2:22]

# Get the dates for each column
dates <- as.Date(colnames(ferry), "%B.%d.%Y")

# transpose the data frame so each row is a day
ferry2 <- as.data.frame(t(ferry))

# append dates 
ferry2$date <- dates
# Combine into single columns (date + time)
ferry_final <- NULL
for(i in 2:73){
  temp <- unite(ferry2,temp, c("date",paste("V",i,sep="")), sep = " ")$temp
  ferry_final <- rbind(ferry_final,temp)
} 
# only issue is that it did combine the NAs

# Check missing by row (there should only be 14 missing for there to have been a full schedule)
missing.rows <- apply(ferry2, 1, FUN = function(x)sum(is.na(x)))

# Change to times
ferry_final2 <- apply(ferry_final,2,FUN = function(x)parse_date_time(x, " %Y-%m-%d HM"))
# Convert to data frame and make POSIX objects
ferry_final2  <- as.data.frame(t(ferry_final2))
# Apply to all rows
ferry_singlemat <- NULL
for(i in 1:dim(ferry_final2)[1]){
  final <- remove_nas(ferry_final2[i,])
  
  ferry_singlemat <- rbind(ferry_singlemat, final)
}
# rename the columns and the rows
end <- dim(ferry_singlemat)[2]
names <- paste("time",1:end, sep = "")
ferry_singlemat <- as.data.frame(ferry_singlemat)
colnames(ferry_singlemat) <- names
rownames(ferry_singlemat) <- dates

# convert each column to POSIX to get times
for(i in 1:dim(ferry_singlemat)[2]){
  col <- names[i]
  class(ferry_singlemat[,col]) <- c('POSIXt','POSIXct')
  ferry_singlemat[,col] <- with_tz(ferry_singlemat[,col], "UTC")
  #attributes(ferry_singlemat[,col])$tzone <- "UTC"
}
# Save out data
save(ferry_singlemat, file = "Data/Ferry/Clean/ferry_april.RData")

#### Repeat for May: Weekdays only ####
ferry <- read_excel("Data/Ferry/05 MAY 2018.xlsx", sheet = 2)

# remove last column
ferry <- ferry[,-ncol(ferry)]

# Rename the columns: Step 1. Capture dates and weekdays
maydates <- paste("may",1:31,"2018")
may <- parse_date_time(maydates, order = "%m %d %Y")
weekdays <- wday(may, label = T)
may.full <- cbind.data.frame(may, weekdays, maydates)
# extract weekdates only
maydates_weekday <- may.full$maydates[may.full$weekdays!="Sat"&may.full$weekdays!="Sun"]
#compress whitespace with .
maydates_weekday <- gsub(x= maydates_weekday, " ",".")
# rename the columns
names(ferry) <- c("Schedule",maydates_weekday,"Schedule")
# Remove extraneous rows (remove the late/missing reasons and NAs)
row.end <- which(ferry$Schedule=="PEAK")
ferry <- ferry[1:(row.end-1),]

# Remove first and last columns which are the ferry schedule
ferry <- ferry[,2:24]

# Get the dates for each column
dates <- as.Date(colnames(ferry), "%B.%d.%Y")

# transpose the data frame so each row is a day
ferry2 <- as.data.frame(t(ferry))

# append dates 
ferry2$date <- dates
# Combine into single columns (date + time)
ferry_final <- NULL
for(i in 2:73){
  temp <- unite(ferry2,temp, c("date",paste("V",i,sep="")), sep = " ")$temp
  ferry_final <- rbind(ferry_final,temp)
} 
# only issue is that it did combine the NAs

# Check missing by row (there should only be 14 missing for there to have been a full schedule)
missing.rows <- apply(ferry2, 1, FUN = function(x)sum(is.na(x)))

# Change to times
ferry_final2 <- apply(ferry_final,2,FUN = function(x)parse_date_time(x, " %Y-%m-%d HM"))
# Convert to data frame and make POSIX objects
ferry_final2  <- as.data.frame(t(ferry_final2))
# Apply to all rows
ferry_singlemat <- NULL
for(i in 1:dim(ferry_final2)[1]){
  final <- remove_nas(ferry_final2[i,])
  
  ferry_singlemat <- rbind(ferry_singlemat, final)
}
# rename the columns and the rows
end <- dim(ferry_singlemat)[2]
names <- paste("time",1:end, sep = "")
ferry_singlemat <- as.data.frame(ferry_singlemat)
colnames(ferry_singlemat) <- names
rownames(ferry_singlemat) <- dates

# convert each column to POSIX to get times
for(i in 1:dim(ferry_singlemat)[2]){
  col <- names[i]
  class(ferry_singlemat[,col]) <- c('POSIXt','POSIXct')
  ferry_singlemat[,col] <- with_tz(ferry_singlemat[,col], "UTC")
  #attributes(ferry_singlemat[,col])$tzone <- "UTC"
}
# Save out data
save(ferry_singlemat, file = "Data/Ferry/Clean/ferry_may.RData")

#### Repeat for June: Weekdays only ####
ferry <- read_excel("Data/Ferry/06 JUNE 2018.xlsx", sheet = 2)

# remove last column
ferry <- ferry[,-ncol(ferry)]

# Rename the columns: Step 1. Capture dates and weekdays
junedates <- paste("june",1:30,"2018")
june <- parse_date_time(junedates, order = "%m %d %Y")
weekdays <- wday(june, label = T)
june.full <- cbind.data.frame(june, weekdays, junedates)
# extract weekdates only
junedates_weekday <- june.full$junedates[june.full$weekdays!="Sat"&june.full$weekdays!="Sun"]
#compress whitespace with .
junedates_weekday <- gsub(x= junedates_weekday, " ",".")
# rename the columns
names(ferry) <- c("Schedule",junedates_weekday,"Schedule")
# Remove extraneous rows (remove the late/missing reasons and NAs)
row.end <- which(ferry$Schedule=="PEAK")
ferry <- ferry[1:(row.end-1),]

# Remove first and last columns which are the ferry schedule
ferry <- ferry[,2:22]

# Get the dates for each column
dates <- as.Date(colnames(ferry), "%B.%d.%Y")

# transpose the data frame so each row is a day
ferry2 <- as.data.frame(t(ferry))

# append dates 
ferry2$date <- dates
# Combine into single columns (date + time)
ferry_final <- NULL
for(i in 2:73){
  temp <- unite(ferry2,temp, c("date",paste("V",i,sep="")), sep = " ")$temp
  ferry_final <- rbind(ferry_final,temp)
} 
# only issue is that it did combine the NAs

# Check missing by row (there should only be 14 missing for there to have been a full schedule)
missing.rows <- apply(ferry2, 1, FUN = function(x)sum(is.na(x)))

# Change to times
ferry_final2 <- apply(ferry_final,2,FUN = function(x)parse_date_time(x, " %Y-%m-%d HM"))
# Convert to data frame and make POSIX objects
ferry_final2  <- as.data.frame(t(ferry_final2))
# Apply to all rows
ferry_singlemat <- NULL
for(i in 1:dim(ferry_final2)[1]){
  final <- remove_nas(ferry_final2[i,])
  
  ferry_singlemat <- rbind(ferry_singlemat, final)
}
# rename the columns and the rows
end <- dim(ferry_singlemat)[2]
names <- paste("time",1:end, sep = "")
ferry_singlemat <- as.data.frame(ferry_singlemat)
colnames(ferry_singlemat) <- names
rownames(ferry_singlemat) <- dates

# convert each column to POSIX to get times
for(i in 1:dim(ferry_singlemat)[2]){
  col <- names[i]
  class(ferry_singlemat[,col]) <- c('POSIXt','POSIXct')
  ferry_singlemat[,col] <- with_tz(ferry_singlemat[,col], "UTC")
  #attributes(ferry_singlemat[,col])$tzone <- "UTC"
}
# Save out data
save(ferry_singlemat, file = "Data/Ferry/Clean/ferry_june.RData")

#### Repeat for July: Weekdays only ####
ferry <- read_excel("Data/Ferry/07 JULY 2018.xlsx", sheet = 2)

# remove last column
ferry <- ferry[,-ncol(ferry)]

# Rename the columns: Step 1. Capture dates and weekdays
julydates <- paste("july",1:31,"2018")
july <- parse_date_time(julydates, order = "%m %d %Y")
weekdays <- wday(july, label = T)
july.full <- cbind.data.frame(july, weekdays, julydates)
# extract weekdates only
julydates_weekday <- july.full$julydates[july.full$weekdays!="Sat"&july.full$weekdays!="Sun"]
#compress whitespace with .
julydates_weekday <- gsub(x= julydates_weekday, " ",".")
# rename the columns
names(ferry) <- c("Schedule",julydates_weekday,"Schedule")
# Remove extraneous rows (remove the late/missing reasons and NAs)
row.end <- which(ferry$Schedule=="PEAK")
ferry <- ferry[1:(row.end-1),]

# Remove first and last columns which are the ferry schedule
ferry <- ferry[,2:23]

# Get the dates for each column
dates <- as.Date(colnames(ferry), "%B.%d.%Y")

# transpose the data frame so each row is a day
ferry2 <- as.data.frame(t(ferry))

# append dates 
ferry2$date <- dates
# Combine into single columns (date + time)
ferry_final <- NULL
for(i in 2:73){
  temp <- unite(ferry2,temp, c("date",paste("V",i,sep="")), sep = " ")$temp
  ferry_final <- rbind(ferry_final,temp)
} 
# only issue is that it did combine the NAs

# Check missing by row (there should only be 14 missing for there to have been a full schedule)
missing.rows <- apply(ferry2, 1, FUN = function(x)sum(is.na(x)))

# Change to times
ferry_final2 <- apply(ferry_final,2,FUN = function(x)parse_date_time(x, " %Y-%m-%d HM"))
# Convert to data frame and make POSIX objects
ferry_final2  <- as.data.frame(t(ferry_final2))
# Apply to all rows
ferry_singlemat <- NULL
for(i in 1:dim(ferry_final2)[1]){
  final <- remove_nas(ferry_final2[i,])
  
  ferry_singlemat <- rbind(ferry_singlemat, final)
}
# rename the columns and the rows
end <- dim(ferry_singlemat)[2]
names <- paste("time",1:end, sep = "")
ferry_singlemat <- as.data.frame(ferry_singlemat)
colnames(ferry_singlemat) <- names
rownames(ferry_singlemat) <- dates

# convert each column to POSIX to get times
for(i in 1:dim(ferry_singlemat)[2]){
  col <- names[i]
  class(ferry_singlemat[,col]) <- c('POSIXt','POSIXct')
  ferry_singlemat[,col] <- with_tz(ferry_singlemat[,col], "UTC")
  #attributes(ferry_singlemat[,col])$tzone <- "UTC"
}
# Save out data
save(ferry_singlemat, file = "Data/Ferry/Clean/ferry_july.RData")


#### Repeat for August: Weekdays only ####
ferry <- read_excel("Data/Ferry/08 AUGUST 2018.xlsx", sheet = 2)

# remove last column
ferry <- ferry[,-ncol(ferry)]

# Rename the columns: Step 1. Capture dates and weekdays
augdates <- paste("aug",1:31,"2018")
aug <- parse_date_time(augdates, order = "%m %d %Y")
weekdays <- wday(aug, label = T)
aug.full <- cbind.data.frame(aug, weekdays, augdates)
# extract weekdates only
augdates_weekday <- aug.full$augdates[aug.full$weekdays!="Sat"&aug.full$weekdays!="Sun"]
#compress whitespace with .
augdates_weekday <- gsub(x= augdates_weekday, " ",".")
# rename the columns
names(ferry) <- c("Schedule",augdates_weekday,"Schedule")
# Remove extraneous rows (remove the late/missing reasons and NAs)
row.end <- which(ferry$Schedule=="PEAK")
ferry <- ferry[1:(row.end-1),]

# Remove first and last columns which are the ferry schedule
ferry <- ferry[,2:24]

# Get the dates for each column
dates <- as.Date(colnames(ferry), "%B.%d.%Y")

# transpose the data frame so each row is a day
ferry2 <- as.data.frame(t(ferry))

# append dates 
ferry2$date <- dates
# Combine into single columns (date + time)
ferry_final <- NULL
for(i in 2:73){
  temp <- unite(ferry2,temp, c("date",paste("V",i,sep="")), sep = " ")$temp
  ferry_final <- rbind(ferry_final,temp)
} 
# only issue is that it did combine the NAs

# Check missing by row (there should only be 14 missing for there to have been a full schedule)
missing.rows <- apply(ferry2, 1, FUN = function(x)sum(is.na(x)))

# Change to times
ferry_final2 <- apply(ferry_final,2,FUN = function(x)parse_date_time(x, " %Y-%m-%d HM"))
# Convert to data frame and make POSIX objects
ferry_final2  <- as.data.frame(t(ferry_final2))
# Apply to all rows
ferry_singlemat <- NULL
for(i in 1:dim(ferry_final2)[1]){
  final <- remove_nas(ferry_final2[i,])
  
  ferry_singlemat <- rbind(ferry_singlemat, final)
}
# rename the columns and the rows
end <- dim(ferry_singlemat)[2]
names <- paste("time",1:end, sep = "")
ferry_singlemat <- as.data.frame(ferry_singlemat)
colnames(ferry_singlemat) <- names
rownames(ferry_singlemat) <- dates

# convert each column to POSIX to get times
for(i in 1:dim(ferry_singlemat)[2]){
  col <- names[i]
  class(ferry_singlemat[,col]) <- c('POSIXt','POSIXct')
  ferry_singlemat[,col] <- with_tz(ferry_singlemat[,col], "UTC")
  #attributes(ferry_singlemat[,col])$tzone <- "UTC"
}
# Save out data
save(ferry_singlemat, file = "Data/Ferry/Clean/ferry_aug.RData")

#### Combine all ferry months into single data frame ####
# Load all files and rename
load("Data/Ferry/Clean/ferry_jan.RData")
ferry_jan <- ferry_singlemat
load("Data/Ferry/Clean/ferry_feb.RData")
ferry_feb <- ferry_singlemat
load("Data/Ferry/Clean/ferry_march.RData")
ferry_march <- ferry_singlemat
load("Data/Ferry/Clean/ferry_april.RData")
ferry_april <- ferry_singlemat
load("Data/Ferry/Clean/ferry_may.RData")
ferry_may <- ferry_singlemat
load("Data/Ferry/Clean/ferry_june.RData")
ferry_june <- ferry_singlemat
load("Data/Ferry/Clean/ferry_july.RData")
ferry_july <- ferry_singlemat
load("Data/Ferry/Clean/ferry_aug.RData")
ferry_aug <- ferry_singlemat

# add extra column where needed 
ferry_jan$time59 <- NA
ferry_feb$time59 <- NA
ferry_march$time59 <- NA
ferry_april$time59 <- NA
ferry_june$time59 <- NA

# combine chronologically
ferry_master <- rbind.data.frame(ferry_jan, ferry_feb, ferry_march, ferry_april,
                                 ferry_may, ferry_june, ferry_july, ferry_aug)

# save
save(ferry_master, file = "Data/Ferry/Clean/ferry_2018.RData")

# remove extraneous data
rm(ferry_jan, ferry_feb, ferry_march, ferry_april,
   ferry_may, ferry_june, ferry_july, ferry_aug, ferry, ferry2, ferry_final,
   ferry_final2, ferry_singlemat, jandates, febdates, marchdates, aprildates,
   junedates, julydates, augdates, jandates_weekday, febdates_weekday, 
   marchdates_weekday, aprildates_weekday, maydates_weekday, junedates_weekday,
   julydates_weekday, augdates_weekday, ferry_row, ferry_start)