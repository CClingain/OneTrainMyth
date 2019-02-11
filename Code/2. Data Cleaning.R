#################################
###### 2. Data Cleaning #########
#################################

# Subset South Ferry trains only
onetrain_stoptime_sub <- onetrain_stoptime[onetrain_stoptime$stop_id=="142S",]