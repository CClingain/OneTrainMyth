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
