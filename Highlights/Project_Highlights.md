Highlights
================
Clare Clingain

# Overview

The 1 train has a reputation for being named after the number of minutes
by which you miss the Staten Island ferry. This project set out to
understand that myth using MTA Historical Real Time data and Staten
Island Ferry departure data. Specficially, this project attempted to
answer three questions.

1)  What does the distribution of wait times look like for connections
    between the 1 train and the Staten Island Ferry?

2)  How does this distribution vary across time (e.g., rush hour vs
    tourist peak)?

3)  How does this distribution vary for people who can run versus people
    who can’t run from the 1 train to the ferry?

To answer the third question, I added either 1, 2, or 3 minutes to the
arrival time at South Ferry as a buffer for time to exit the train and
enter Whitehall terminal. With the addition of the exit time, I then
found the closest ferry to each train arrival and derived the wait time
until the next ferry.

Perhaps by accident, but mostly by design, the results for question 3
are intertwined with the first two questions.

# Q1: Wait Time Distributions

Below are the wait time distributions for the three exit times. The
distributions look quite similar. I used a two-sample Kolmogorov-Smirnov
test to determine whether each distribution was different from the other
two. After adjusting the p-values via Benjamini-Hochberg, I found all
three distributions to be significantly different from one another.
However, I am cautious to interpret the results of the KS test given
that the independence assumption of my data is conditional on train
spacing. A train arrival in January is independent from a train arrival
in May, but any two consecutive trains are probably not
independent.

![](Project_Highlights_files/figure-gfm/wait%20time%20distributions-1.png)<!-- -->

# Q2: Marginal Wait Time Distributions

After getting the overall distributions, I decided to examine the
marginal distributions as functions of time of day. This section will
move from the moew granular to the more general.

## Rush hour vs Non-rush hour

The hours of the day were split into the following three categories
based on the ferry schedule:

  - Morning rush: 7 am to 9 am, inclusive
  - Evening rush: 4pm to 7pm, inclusive
  - Non rush: 8pm to 6 am, inclusive

Across all three exit times, morning rush hour and evening rush hour
look similar. Both appear to have a similar quantity of nightmare waits
(30+ minutes). The noticeable difference is between the rush hour times
and the non-rush hour time. The median wait time during non-rush hour is
much higher, and the distribution has a greater
variance.

![](Project_Highlights_files/figure-gfm/rush%20hour-1.png)<!-- -->![](Project_Highlights_files/figure-gfm/rush%20hour-2.png)<!-- -->![](Project_Highlights_files/figure-gfm/rush%20hour-3.png)<!-- -->

## Hours of the day

The morning rush, evening rush, and non-rush hour comparison aggregated
time blocks, but are there hour-by-hour differences in wait times? Based
on the median plot below, wait time does appear to vary as a function of
hour of the day. As soon as the morning rush hour is over, the median
wait times jump from less than 10 minutes to 14 to 16 minutes. This jump
is consistent for all three exit times. As the evening rush approaches,
wait times decrease, but steadily climb throughout the midnight hours.

![](Project_Highlights_files/figure-gfm/hours-1.png)<!-- -->

## Day of the week

Given the differences across hours, I checked for differences across
days of the week. There doesn’t seem to be any differences between the
days, and the nightmare wait times seem to be evenly spread. The good
news is that Monday doesn’t have the highest
median.

![](Project_Highlights_files/figure-gfm/day%20of%20the%20week-1.png)<!-- -->![](Project_Highlights_files/figure-gfm/day%20of%20the%20week-2.png)<!-- -->![](Project_Highlights_files/figure-gfm/day%20of%20the%20week-3.png)<!-- -->

## Month

Finally, given that the data spans from January to August, I checked to
see if the distributions vary across the months. Based on the
side-by-side boxplots, it’s difficult to distinguish minute differences.
Janurary, April, May, and June tend to have slightly higher medians, but
this may be
negligible.

![](Project_Highlights_files/figure-gfm/month-1.png)<!-- -->![](Project_Highlights_files/figure-gfm/month-2.png)<!-- -->![](Project_Highlights_files/figure-gfm/month-3.png)<!-- -->

# Q3: Differences by exit time?

Based on the results above, it seems that the differences between the
wait times are largely conditional on the time of day. During rush hour,
it doesn’t seem to make a difference if you can run or not, on average.
However, between 3 and 4 am, you may want to run to reduce the
probability that you’ll just miss the ferry.

# Is the myth just a myth?

Based on the probability of waiting between 27 and 29 minutes for a
ferry, it seems like the myth is only a myth. Whether you take 1, 2, or
3 minutes to exit to the terminal, you have roughly a 4% chance of just
missing the ferry.

Yet the myth is more nuanced when we break it down by time. If you take
3 minutes to exit, and you’re trying to catch a boat in the 3 am hour,
you have a 12% chance of just missing the ferry.

# What’s the chance of a nightmare wait (30+ minutes)?

The probability of waiting between 30 minutes and 59.9 minutes ranges
from 4% to 6%. This means that a nightmare wait is almost as likely as
the mythical wait\!

This might be great news, but you’ll want to be careful at 11 p.m. where
there’s roughly a 28% chance of having a nightmare wait across all exit
times.
