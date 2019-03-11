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
ferry <- ferry[1:end,]