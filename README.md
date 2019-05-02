# Making Connections: Transfers between the 1 train and the Staten Island Ferry

## What's the problem?

Poor subway service is affecting millions of New Yorkers, but some of us have another nightmare: making connections from the subway to the Staten Island Ferry. Nobody wants to wait 30 minutes for the next ferry all because the 1 train took its sweet time pulling into South Ferry station. 

The poor service on the 1 train has become so bad that Staten Islanders have christened it with a grammatically incorrect meme: the 1 train is named after how many minutes you’ll miss ferry. 

![](Images/1trainmeme.jpg)

Any Staten Islander will tell you this is true and go on an angry rant about the 1 train and the ferry. Out of my own frustrations, I created the second meme: everyone ignores Staten Island!

![](Images/guygirlmeme2_edit.jpg)

Let’s get a little serious – Staten Islanders have some of the worst commutes in the country, with an average commute of 69 minutes each way. Compare this to the average of about 40 minutes for other New Yorkers. Yet research has shown that long commutes can detract from people’s quality of life and is associated with lower life satisfaction. 

The public transportation issue for Staten Islanders isn’t only related to their quality of life, but their love lives as well! Surveys of single New Yorkers found that only 8 percent of Manhattan, Brooklyn, and Queens residents said they would be willing to regularly date someone who lives on the Island, with most single New Yorkers citing public transportation as the biggest issue with dating someone from Staten Island! Those of us lucky enough to date among that 8 percent never hear the end of how long it took to get the Island from our significant others.

## Research Questions

If we can improve the connection between the 1 train and the Staten Island ferry, that could shave off up to 30 minute wait times for commuters. We turn to data to get answers to two questions. 

1) What does the distribution of wait times look like for connections between the 1 train and the Staten Island Ferry?

2) How does this distribution vary across time (e.g., rush hour vs tourist peak)?

3) How does this distribution vary for people who can run versus people who can't run from the 1 train to the ferry?

Wait times will be calculated with an additional 1, 2, and 3 minute exit time from South Ferry to Whitehall ferry terminal. 

## Data Sources

1. [MTA Historical Real Time Subway data](https://datamine-history.s3.amazonaws.com/index.html)

2. [Staten Island Ferry Departure data](https://data.cityofnewyork.us/Transportation/Test-Staten-Island-Ferry-Daily-Performance-data/7gic-pibm)

Yes, the MTA data is just as messy as the subways, buses, trains, and ferries. 

## Plans + Goals

1. Access MTA Real Time data through API
2. Extract necessary data for 1 train and Staten Island Ferry
3. Clean the data
4. Conduct exploratory analysis
5. Compare the lateness distributions


