#################################
###### 2. Data Cleaning #########
#################################

load("Data/onetrain_stoptimeJan31.Rdata")

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

# Save the current data
save(onetrain_stoptime_sub, file = "Data/onetrain_stoptimeJan31_clean.Rdata")