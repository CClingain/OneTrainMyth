
#### February 23, 2019

After thinking about my data and looking at what I was getting, I
realized that I will need to stream in a series of data to get the full
picture because I won’t be able to get all the real-time data. Obtaining
all the real time data would require constant retrieval. Instead, I’m
going to take samples of the data. I’m reworking my data import and
cleaning scripts so that they can automate this process.

#### February 25, 2019

Whie I have been extracting the data using the script I made, I realized
that there wil be an inherent issue with getting the data from the train
to match up with the data from the ferry. How can get a distribution of
wait times if I don’t have all the data? Luckily, the MTA saves the
real-time data for all the train lines since 2014. Pairing this up with
the ferry data, I have enough to go back to September 2014… Step one
will be to access the historical real-time data
[here](http://web.mta.info/developers/MTA-Subway-Time-historical-data.html).

One of the problems arising from this data is that there are very close
time interval. For example, the data say that a train arrived at South
Ferry at 9:34am, 9:36am, and 9:37am. However, this isn’t possible. South
Ferry is a terminal station, so any new trains have to wait for a
departing train to leave in order to enter. I came across a similar
problem when I was pulling from the real-time update. I think this comes
about as a side effect of the MTA updating the positions of the trains
every 30 seconds. My guess is that the latest time is the most accurate
one, on average. So in order to capture the correct data, I will look at
the row numbers from the subsetted South Ferry data, and take the row
with the highest row number for that time range.

#### March 4th, 2019

Based on what I was seeing in the preliminary data, I was concerned
about some of the time stamps. Some trains seemed to come in too quick
succession. To understand if this is possible and does happen, I spent a
good amount of time this past week waiting for a few 1 trains to pass
by. I kept track of the times that trains were arriving, as well as when
trains were departing South Ferry. The data doesn’t lie\! Some trains do
arrive in quick auccession of one another.

Let’s get back to the data cleaning. After receiving feedback and taking
time to think, I will remove any data that is predicted from each
import. I have to build this into my functions and test it out.
Logistically, running all of this code may be a bit of a nightmare.
There are 78,336 files to pull. Pending my computer holding up, I may
subset to a smaller time range. This will also depend on any broken
links – this would stop the process. Luckily, Madison suggested using
possibly() from the purrrr package, which allows for functions to run
even if they break in certain instances.

#### March 11th, 2019

There has been a few issues with extracting the historical data, but
hopefully the current fix will work. I think the reason I was getting
the error is that the links were converted to POSIX when I just need to
keep them as characters. I’ve set the code to extract, so hopefully it
goes through this time. In the meantime, I may start cleaning the ferry
data for the same period.

One hour later… After another break of the fix I was sure would work, I
realized what the problem was: some urls just don’t return any data\!
They would break at the selection of each data frame from the lists
because there were no data frames to select. I’ve now added in a fail
safe for the extract\_historical() and clean\_historical() functions.
Any link that has no data will instead return a 1 x 7 data frame with
NAs. The remove\_pred() function doesn’t need a fail safe since any rows
with NA are considered to be smaller than the given date. The code is
currently running. Let’s hope this does it\!

A few hours later… The functions are working\! However, a new issue has
come up. It seems like the GET request times out automatically after 10
seconds. For one of the urls, it couldn’t grab the data within 10
seconds, so it broke the whole loop. I’ve not set a max wait time of 60
seconds; that seems like a reasonable amount of time to connect to the
server. After reading some results online, it is possible that this may
be happening because of my organization’s network (NYU). If I keep
getting this error, I may try running it from my home wifi.

A couple hours later… I figured out the latest code break, which came as
a result of one of the fail safes. The data frames didn’t have the same
columns. Hopefully now it’ll work…

The code is working\! The new issues are a) amount of time for code to
run and b) extensive, consectutive missing data. I’m thinking of
creating a script that will have some sort of skip logic in a big
function that will do what my three functions do now. It would also be a
good idea to see if I can filter out the 1 train data earlier, mainly in
extraction.

##### March 12, 2019

I have finished the script to get all 9 months of data and will be
sending it off to Yoav shortly. My main concern is that the script
sometimes stops for reasons that seem to link to NYU limiting my calls.
I have toyed with the idea of adding a system sleep time, but even 1
second of sleep time will add up since each month has roughly 8,900
links to go through. We’ll see how things go. I’m testing the code for
each month to make sure it runs smoothly. There was only one more bug I
had to fix. Let’s hope this goes well.

##### April 8, 2019

Over the last few weeks, I’ve gotten all my data\! Before looking at the
data, I ran some simulations to see what the lateness distributions and
connections could look like. I used both a normal distributino and a
beta distribution to add the lateness noise. Based on the sims, it’s
interesting to see that the early hours of the morning where botht he
ferry and the 1 train run so infrequently (though the ferry less so),
the delays are a hit or miss – either you wait a short amount of time or
you wait for nearly 30 minutes. There’s also something interesting going
on during the tourst peak hours (11am-3pm) where the wait time looks
near continuous – you may wait any amount of time.

At this point, I may run a few more simulations, but I think Im ready to
take a look at the data.

##### April 12, 2019

The goal I have for this Monday is to clean and merge all the ferry
data. I need this completed before I can get the waiting time
distributions.
