#################################
####### 1. Data Import ##########
#################################

library(httr)

url <- "http://datamine.mta.info/mta_esi.php?key=51469dd0902e2edb2e1a327a2c413334&feed_id=1"

test <- GET(url)

# Check request went through (200 = good)
test$status_code

head(test$content)

# Process API request content
test_content <- content(test)
