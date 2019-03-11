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

