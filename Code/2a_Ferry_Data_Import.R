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
ferry_final <- matrix(ncol=21, nrow = 71)
for(i in 2:73){
  temp <- unite(ferry2,temp, c("date",paste("V",i,sep="")), sep = " ")
  ferry_final[i,] <- temp$temp
}
ferry2$V2 <- unite(ferry2, V2, c("date","V2"), sep = " ")$V2
ferry2$V3 <- unite(ferry2, V3, c("date","V3"), sep = " ")$V3
ferry2$V4 <- unite(ferry2, V4, c("date","V4"), sep = " ")$V4
ferry2$V5 <- unite(ferry2, V5, c("date","V5"), sep = " ")$V5


# Check missing by row (there should only be 14 missing for there to have been a full schedule)
missing.rows <- apply(ferry2, 1, FUN = function(x)sum(is.na(x)))
# Remove those that have no data at all  (72)
nodata <- which(missing.rows == 72)
ferry2 <- ferry2[-nodata,]

# Now, we need to line up the times such that there aren't missing spaces and
# extra variables in the middle of the data. We'll move any necessary extra
# variables to the end of the data
# the col dim for most of the data is 61, but can go up to 66
# sp 66 will be the max col
ferry_final <- matrix(ncol = 66, nrow = 21)
for(i in 1:length(rownames(ferry2))){
  ferry_row <- as.vector(ferry2[i,])
  missing <- which(is.na(ferry_row))
  ferry_row <- ferry_row[,-missing]
  
  # remove the col names
  colnames(ferry_row) <- c()

  # if it has more than 61 rows
  if(length(ferry_row) > 61){
    num.rows <- length(ferry_row)
    times <- 66 - num.rows
    ferry_row <- append(ferry_row, rep(NA,times))
    ferry_final[i,] <- as.vector(ferry_row)
  } else {
  # if it has 61 rows exactly
  ferry_row <- append(ferry_row,rep(NA,5))
  ferry_final[i,] <- as.vector(ferry_row)
    }
  
}

# Change to times
ferry_final <- apply(ferry2,1,FUN = function(x)parse_date_time(x, "HM"))