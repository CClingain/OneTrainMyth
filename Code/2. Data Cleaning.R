#################################
###### 2. Data Cleaning #########
#################################

# Convert data classes
onetrain_stoptime$arrival_time <- as.numeric(as.character(onetrain_stoptime$arrival_time))
onetrain_stoptime$arrival_delay <- as.numeric(as.character(onetrain_stoptime$arrival_delay))
onetrain_stoptime$departure_time <- as.numeric(as.character(onetrain_stoptime$departure_time))
onetrain_stoptime$departure_delay <- as.numeric(as.character(onetrain_stoptime$departure_delay))

# Subset South Ferry trains only
onetrain_stoptime_sub <- onetrain_stoptime[onetrain_stoptime$stop_id=="142S",]

# Convert times from # of seconds since POSIX time (1970-01-01 00:00:00)
class(onetrain_stoptime_sub$arrival_time) = c('POSIXt','POSIXct')