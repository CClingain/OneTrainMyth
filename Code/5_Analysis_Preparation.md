Analysis Preparation
================
Clare Clingain

# Analysis Data Preparation

Since both the MTA data and the Ferry data have be cleaned, they now
need to be combined to create a data set that is suitable for analysis.

Note: For knitting purposes, cleaned data is loaded into the file. The
code that matches trains to ferries takes a long time to
run.

## Merge and Unlist MTA data

``` r
mta_master <- c(jan_clean, feb_clean, march_clean, april_clean, may_clean, june_clean, july_clean, aug_clean)

mta_master2 <- NULL

for(i in 56544:length(mta_master)){
  if(is.null(mta_master[[i]])==TRUE){
    print("This line is empty")
  } else{
  temp <- as.data.frame(as.matrix(mta_master[[i]]))
  mta_master2 <- rbind(mta_master2, temp)
  }
  print(i)
}

# fix classes
mta_master2$arrival_time <- parse_date_time(mta_master2$arrival_time,  "%Y-%m-%d %H:%M:%S")
# Save data
save(mta_master2, file = "../Data/Clean/mta_master.RData")
```

## Check data

``` r
head(mta_master2)
```

## Filter out holidays and weekends

``` r
holidays <- c("2018-01-01","2018-01-15","2018-02-19","2018-05-28","2018-07-04")
weekends <- c("2018-01-06","2018-01-07","2018-01-13","2018-01-14","2018-01-20","2018-01-21","2018-01-27","2018-01-28","2018-02-03","2018-02-04","2018-02-10","2018-02-11","2018-02-17","2018-02-18","2018-02-24","2018-02-25","2018-03-03","2018-03-04","2018-03-10","2018-03-11","2018-03-17","2018-03-18","2018-03-24","2018-03-25","2018-03-31","2018-04-01","2018-04-07","2018-04-08","2018-04-14","2018-04-15","2018-04-21","2018-04-22","2018-04-28","2018-04-29","2018-05-05","2018-05-06","2018-05-12","2018-05-13","2018-05-19","2018-05-20","2018-05-26","2018-05-27","2018-06-02","2018-06-03","2018-06-09","2018-06-10","2018-06-16","2018-06-17","2018-06-23","2018-06-24","2018-06-30","2018-07-01","2018-07-07","2018-07-08","2018-07-14","2018-07-15","2018-07-21","2018-07-22","2018-07-28","2018-07-29","2018-08-04","2018-08-05","2018-08-11","2018-08-12","2018-08-18","2018-08-19","2018-08-25","2018-08-26")
# make time obects
holidays <- parse_date_time(holidays,"%Y-%m-%d")
weekends <- parse_date_time(weekends, "%Y-%m-%d")
# combine
holidays_weekends <- c(holidays,weekends)
# Filter
mta_sub <- filter(mta_master2, !grepl(paste(holidays_weekends, collapse="|"), arrival_time))

# Remove the 12/31 data
remove <- grep("2017-12-31", mta_sub$arrival_time)
mta_sub <- mta_sub[-remove,]

# remove the empty rows
mta_sub <- mta_sub[complete.cases(mta_sub[,"arrival_time"]),]

# remove empty ferry rows
ferry_sub <- ferry_master[complete.cases(ferry_master[,"time1"]),]
```

``` r
# Find the row we should look in 
ferry_row <- unlist(lapply(mta_sub$arrival_time, FUN = function(x) max(which((as.Date(rownames(ferry_sub)) > x)==FALSE))))

# rename the rownames of mta_sub so that they'll match the ferry_row index
rownames(mta_sub) <- 1:dim(mta_sub)[1]
```

## Get closest ferry

``` r
get_ferry <- function(data, index_row){
  # Gets the wait time between ferry and train
  # data = MTA data frame 
  # index_row = ferry row that contains the train arrival time for each MTA row
  
  ## Step 1: Grab the closest ferry row
  row_index <- ferry_row[index_row]
  # include one row after for search 
  ferry_initial <- t(as.matrix(ferry_sub[row_index:(1+row_index),]))
  ferry_reshape <- c(ferry_initial[,1], ferry_initial[,2])
  ferry_dat <- as.POSIXct(ferry_reshape, "UTC")
  ## Step 2: Find the closest ferry
  closest_ferry_index <- min(which((ferry_dat - data$arrival_time[index_row])>0))

  closest_ferry <- ferry_dat[closest_ferry_index]

  # Return the closest ferry
  return(closest_ferry)
}
```

``` r
# Initialize storage
ferry_match <- NULL

# Get the closest ferry for each arrival time
for (i in 1:dim(mta_sub)[1]){
  # printing i for time purposes
  print(i)
  
  ferry_match[i] <- get_ferry(mta_sub, i)
  
}
```

## Get wait times

``` r
get_wait <- function(data, ferry, index_row){
  # Obtains the wait times between each train and its closest ferry
  # data = MTA data set used in get_ferry()
  # ferry = return vector of get_ferry()
  
  ## Step 1: Pull the closest ferry from vector
  closest_ferry <- ferry[index_row]
  
  ## Step 2: Convert to POSIX
  class(closest_ferry) <- c('POSIXt','POSIXct')
  closest_ferry <- with_tz(closest_ferry, "UTC")
  
  ## Step 3: Obtain wait times
  wait_time <- as.numeric(closest_ferry - data$arrival_time[index_row])
  
  # if it looks like it's in minutes, change to seconds
  #if(mean(data$wait_time)<120){
  #    data$wait_time <- data$wait_time*60
  #} else {
  #  
  #}
return(wait_time)
}
```

``` r
# Initialize storage
wait_times <- NULL

# Get the wait times for each arrival
for (i in 1:dim(mta_sub)[1]){
  # printing i for time purposes
  print(i)
  
  wait_times[i] <- get_wait(data = mta_sub, ferry = ferry_match, i)
  
}
```

## Check the raw wait times

``` r
summary(wait_times)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##   1.000   6.683  12.500  14.159  20.217  59.900

``` r
plot(wait_times)
```

![](5_Analysis_Preparation_files/figure-gfm/raw%20times%20check-1.png)<!-- -->

The max wait time is 59 minutes, which is fine since some ferry boats
don’t show up, making the wait time longer. (This typically happens
during the midnight hours).

## Get the closest ferry and wait time for 1, 2, and 3 minutes exit time

Note that I’m saving out the closest ferry vector instead of passing the
get\_ferry() within get\_wait() in case of breaks.

``` r
# 1 min
mta_sub_1min <- mta_sub
mta_sub_1min$arrival_time <- mta_sub_1min$arrival_time + 60
# 2 min
mta_sub_2min <- mta_sub
mta_sub_2min$arrival_time <- mta_sub_2min$arrival_time + 120
# 3 min
mta_sub_3min <- mta_sub
mta_sub_3min$arrival_time <- mta_sub_3min$arrival_time + 180

# Initialize storage
ferry_matches_1min <- NULL
ferry_matches_2min <- NULL
ferry_matches_3min <- NULL
wait_times_1min <- NULL
wait_times_2min <- NULL
wait_times_3min <- NULL

# Get the closest ferry and wait time for each train + exit time
for (i in 1:dim(mta_sub)[1]){
  # printing i for time purposes
  print(i)
  # closest ferry
  ferry_matches_1min[i] <- get_ferry(mta_sub_1min, i)
  ferry_matches_2min[i] <- get_ferry(mta_sub_2min, i)
  ferry_matches_3min[i] <- get_ferry(mta_sub_3min, i)

  # wait times
  wait_times_1min[i] <- get_wait(data = mta_sub_1min, ferry = ferry_matches_1min, i)
  wait_times_2min[i] <- get_wait(data = mta_sub_2min, ferry = ferry_matches_2min, i)
  wait_times_3min[i] <- get_wait(data = mta_sub_3min, ferry = ferry_matches_3min, i)
  
}
```

## Check the adjusted wait times

``` r
summary(wait_times_1min)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##    1.00    6.50   12.08   13.91   19.95   59.67

``` r
summary(wait_times_2min)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##   1.000   6.312  12.217  14.384  20.500  59.967

``` r
summary(wait_times_3min)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##   1.000   6.433  12.600  14.228  20.800  59.617

``` r
plot(wait_times_1min)
```

![](5_Analysis_Preparation_files/figure-gfm/check%20adjusted-1.png)<!-- -->

``` r
plot(wait_times_2min)
```

![](5_Analysis_Preparation_files/figure-gfm/check%20adjusted-2.png)<!-- -->

``` r
plot(wait_times_3min)
```

![](5_Analysis_Preparation_files/figure-gfm/check%20adjusted-3.png)<!-- -->

## Create additional time variables

We’ll want to look at differences in arrival times across times of day.

``` r
hours <- hour(mta_sub$arrival_time)
weekday <- wday(mta_sub$arrival_time, label = T)
month <- month(mta_sub$arrival_time)

# Rush hour variable
rushour <- ifelse((hours > 7 & hours <= 9),"Morning Rush", ifelse((hours > 16 & hours <= 19),"Evening Rush","Nonrush"))
tourist_peak <- ifelse((hours > 9 & hours < 16), "Tourist Peak","Non-tourist peak")
```

## Combine into data frame

``` r
analysis_data <- mta_sub
analysis_data$wait_times_raw <- wait_times
analysis_data$wait_times_1min <- wait_times_1min
analysis_data$wait_times_2min <- wait_times_2min
analysis_data$wait_times_3min <- wait_times_3min
analysis_data$hour <- hours
analysis_data$weekday <- weekday
analysis_data$month <- month
analysis_data$rushour <- rushour
analysis_data$tourist_peak <- tourist_peak
# remove extra columns
analysis_data <- analysis_data[,c(3,7:15)]
# save
save(analysis_data, file = "../Data/Clean/analysis_data.RData")
```
