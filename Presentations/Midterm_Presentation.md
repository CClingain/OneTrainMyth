Midterm Presentation: The 1 Train Project
========================================================
author: Clare Clingain
date: March 25, 2019
autosize: true
font-family: 'Helvetica'
css: 1trainstyle.css

Quick Review
========================================================

- An urban myth exists among Staten Islanders: the ~~1 train~~ is named after exactly how many minutes you'll miss the ferry by.
-  Considering that the 1 train's final destination is South Ferry -- the station that connects to the Staten Island Ferry -- this is concerning.
- Staten Islanders have some of the longest commutes in the country, and the Staten Island ferry is also a major tourist attraction.

Research Questions
========================================================

1) What does the distribution of lateness look like for connections between the ~~1 train~~ and the Staten Island Ferry?

2) How does this distribution vary across time (e.g., rush hour vs tourist peak)?

3) How does this distribution vary for people who can run versus people who can't run from the ~~1 train~~ to the ferry?

Data
========================================================
- MTA Historical Real-Time Data
  - 5-minute intervals from January 2018 to August 2018
  
<br>

<center><strong>An absolute nightmare to get this data</strong></center>


Finally have (most of) the data!
========================================================

- Extracted and performed initial cleaning of all data (except half of July)
- Three functions:
  - extract_historical()
  - clean_historical()
  - remove_pred()
  
Goals of each function
========================================================
<strong>1) extract_historical():</strong> communicate with AWS server, extract data, convert to GTFS (transit data) form, combine train ID with train stops data, save data frame

<strong>2) clean_historical():</strong> convert characters to numerics, convert time stamps to POSIX, subset to South Ferry only, order data chronologically

<strong>3) remove_pred():</strong> remove the predicted time stamps (e.g., if data collected at 10:31am, remove arrivals listed after that time)


Extraction process: example code
========================================================


```r
links.aug <- links[links < "2018-09-01" & links > "2018-07-31-23-56"]
data.aug <- list()
for(k in 1:length(links.aug)){
  data.aug[[k]] <- remove_pred(clean_historical(extract_historical(links.aug[[k]])), linkpos = k, links = links.aug)
}
# Save the results
save(data.aug, file = paste(path,"aug2018.RData", sep = ""))
```

Many bugs with similar solutions
========================================================

- Some data pulled from server is empty
  - Save false data frame with same column names
- Some lists in a single data pull are empty
  - Save false data frame with same column names
  
This may seem easy now, but the data contains <strong>78, 336 links</strong> with <strong>~189 lists</strong> within each link... lots of space for things to go wrong

Data: Staten Island Ferry Data
========================================================
- Extracted from CSV files
- Cleaned data

<br>
<strong>A nice surprise:</strong> the SI Ferry data contains a code for which ferry boats are considered late -- any boat that leaves 6 minutes after its scheduled time!


Next Steps
========================================================

- Finalize cleaning and merging of MTA data
- Merge ferry data
- Match train data to ferry data (e.g., which ferry is the nearest to that train?)
- Extract and examine the distributions of lateness

========================================================
title:false
<br>
<br>
<center><thanks>Thank you!</thanks></center>
