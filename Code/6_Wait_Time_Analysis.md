Wait Time Analysis
================
Clare Clingain

# Research Questions

Here are the research questions I hope to answer:

1)  What does the distribution of lateness look like for connections
    between the 1 train and the Staten Island Ferry?

2)  How does this distribution vary across time (e.g., rush hour vs
    tourist peak)?

3)  How does this distribution vary for people who can run versus people
    who can’t run from the 1 train to the ferry?

# Initial Visualizations

## Density plots

``` r
# overlay plot
plot(density(analysis_data$wait_times_1min), main = "Wait times with 1, 2, and 3 minutes exit time", col = 2)
lines(density(analysis_data$wait_times_2min), col = 4)
lines(density(analysis_data$wait_times_3min), col = 5)
legend("topright",legend = c("1 min","2 min","3 min"), lty = 1, lwd = 2, col = c(2,4,5))
```

![](6_Wait_Time_Analysis_files/figure-gfm/density-1.png)<!-- -->

The three distributions look quite similar. In terms of the simulations
I ran, these distributions look like the beta distribution
results.

## Time (hour) x Wait times

``` r
plot(as.factor(analysis_data$hour), analysis_data$wait_times_1min, main = "Wait times  (1 min exit time)",xlab = "Hour of day",ylab = "Wait time")
```

![](6_Wait_Time_Analysis_files/figure-gfm/time%20by%20wait%20times-1.png)<!-- -->

``` r
plot(as.factor(analysis_data$hour), analysis_data$wait_times_2min, main = "Wait times  (2 min exit time)",xlab = "Hour of day",ylab = "Wait time")
```

![](6_Wait_Time_Analysis_files/figure-gfm/time%20by%20wait%20times-2.png)<!-- -->

``` r
plot(as.factor(analysis_data$hour), analysis_data$wait_times_3min, main = "Wait times (3 min exit time)",xlab = "Hour of day",ylab = "Wait time")
```

![](6_Wait_Time_Analysis_files/figure-gfm/time%20by%20wait%20times-3.png)<!-- -->

It makes sense that the waits pile up late at night and during the
tourist peak hours (10-3). I’m curious seeing that the very lengthy wait
times caused by a missing ferry are so dispersed. I initially thought
that it would be worse in the wee hours of the morning, but it looks to
be a problem throughout the day. This isn’t concerning in terms of
something being wrong with the data because there are many reasons why a
ferry or a train never shows. Both can break down, both can have sick
passengers, and both can barely miss each other.

``` r
# medians
medians_IQR <- analysis_data %>% 
  group_by(as.factor(hour)) %>% 
  summarise(median_1min = median(wait_times_1min),
            median_2min = median(wait_times_2min),
            median_3min = median(wait_times_3min),
            IQR_1min = IQR(wait_times_1min),
            IQR_2min = IQR(wait_times_2min),
            IQR_3min = IQR(wait_times_3min))
colnames(medians_IQR)[1] <- "hour"
# plot the medians and IQR
plot(x = as.numeric(medians_IQR$hour), y = medians_IQR$median_1min, pch = 16, main = "Median wait times by hour", ylab = "Wait time (in minutes)", xlab = "Hour")
lines(x = as.numeric(medians_IQR$hour), y = medians_IQR$median_1min, lwd = 2)
lines(x = as.numeric(medians_IQR$hour), y = medians_IQR$median_2min, lwd = 2, col = 2, type = 'o', pch = 16)
lines(x = as.numeric(medians_IQR$hour), y = medians_IQR$median_3min, lwd = 2, col = 4, type = 'o', pch = 16)
legend("bottomright",legend = c("1 min","2 min","3 min"), lty = 1, lwd = 2, col = c(1,2,4))
```

![](6_Wait_Time_Analysis_files/figure-gfm/med%20iqr-1.png)<!-- -->

For the rush-hour and tourist peak hours, it looks like time-to-exit
doesn’t make a difference. A longer time-to-exit does seem to matter for
the late night/early morning hours.

## Time (weekday) x Wait times

Now I’ll check the wait times by
weekday.

``` r
plot(analysis_data$weekday, analysis_data$wait_times_1min, main = "Wait times (1 min exit time)",xlab = "Day of the week",ylab = "Wait time")
```

![](6_Wait_Time_Analysis_files/figure-gfm/weekday%20by%20wait-1.png)<!-- -->

``` r
plot(analysis_data$weekday, analysis_data$wait_times_2min, main = "Wait times (2 min exit time)",xlab = "Day of the week",ylab = "Wait time")
```

![](6_Wait_Time_Analysis_files/figure-gfm/weekday%20by%20wait-2.png)<!-- -->

``` r
plot(analysis_data$weekday, analysis_data$wait_times_3min, main = "Wait times (3 min exit time)",xlab = "Day of the week",ylab = "Wait time")
```

![](6_Wait_Time_Analysis_files/figure-gfm/weekday%20by%20wait-3.png)<!-- -->

I’m curious as to why the distributions for Tuesday and Thursday seem
more spread and have slightly higher medians than Monday, Wednesday, and
Friday. Once again, we see that the long delays seem to be evenly
distributed across days of the week. I’d like to test if these
distrbutions are different from each other later
on.

## Time (Month) x Wait times

``` r
plot(as.factor(analysis_data$month), analysis_data$wait_times_1min, main = "Wait times (1 min exit time)",xlab = "Month",ylab = "Wait time")
```

![](6_Wait_Time_Analysis_files/figure-gfm/month%20wait%20time-1.png)<!-- -->

``` r
plot(as.factor(analysis_data$month), analysis_data$wait_times_2min, main = "Wait times (2 min exit time)",xlab = "Month",ylab = "Wait time")
```

![](6_Wait_Time_Analysis_files/figure-gfm/month%20wait%20time-2.png)<!-- -->

``` r
plot(as.factor(analysis_data$month), analysis_data$wait_times_3min, main = "Wait times (3 min exit time)",xlab = "Month",ylab = "Wait time")
```

![](6_Wait_Time_Analysis_files/figure-gfm/month%20wait%20time-3.png)<!-- -->

## Time (Rush vs nonrush) x Wait times

Next, I’ll have a look at the three distributions by rush
hour.

``` r
plot(as.factor(analysis_data$rushour), analysis_data$wait_times_1min, main = "Wait times (1 min exit time)",xlab = "Rush hour vs Non-rush hour",ylab = "Wait time")
```

![](6_Wait_Time_Analysis_files/figure-gfm/rush%20wait-1.png)<!-- -->

``` r
plot(as.factor(analysis_data$rushour), analysis_data$wait_times_2min, main = "Wait times (2 min exit time)",xlab = "Rush hour vs Non-rush hour",ylab = "Wait time")
```

![](6_Wait_Time_Analysis_files/figure-gfm/rush%20wait-2.png)<!-- -->

``` r
plot(as.factor(analysis_data$rushour), analysis_data$wait_times_3min, main = "Wait times (3 min exit time)",xlab = "Rush hour vs Non-rush hourk",ylab = "Wait time")
```

![](6_Wait_Time_Analysis_files/figure-gfm/rush%20wait-3.png)<!-- -->

As expected, wait times are longer outside of rush hour. However, non
rush hour includes late night hours as well as tourist peak hours. I’ll
break it down further by tourist peak hours.

# Test the difference between the wait distributions

I will use the two-sample Kolmogorov-Smirnov test to determine whether
each distribution is different from the other two. I will adjust my
p-values to reflect the multiple
tests.

``` r
one_two_res <- ks.test(analysis_data$wait_times_1min, analysis_data$wait_times_2min)
```

    ## Warning in ks.test(analysis_data$wait_times_1min,
    ## analysis_data$wait_times_2min): p-value will be approximate in the presence
    ## of ties

``` r
one_two_res
```

    ## 
    ##  Two-sample Kolmogorov-Smirnov test
    ## 
    ## data:  analysis_data$wait_times_1min and analysis_data$wait_times_2min
    ## D = 0.025524, p-value = 4.077e-09
    ## alternative hypothesis: two-sided

``` r
one_three_res <- ks.test(analysis_data$wait_times_1min, analysis_data$wait_times_3min)
```

    ## Warning in ks.test(analysis_data$wait_times_1min,
    ## analysis_data$wait_times_3min): p-value will be approximate in the presence
    ## of ties

``` r
one_three_res
```

    ## 
    ##  Two-sample Kolmogorov-Smirnov test
    ## 
    ## data:  analysis_data$wait_times_1min and analysis_data$wait_times_3min
    ## D = 0.03311, p-value = 4.774e-15
    ## alternative hypothesis: two-sided

``` r
two_three_res <- ks.test(analysis_data$wait_times_2min, analysis_data$wait_times_3min)
```

    ## Warning in ks.test(analysis_data$wait_times_2min,
    ## analysis_data$wait_times_3min): p-value will be approximate in the presence
    ## of ties

``` r
two_three_res
```

    ## 
    ##  Two-sample Kolmogorov-Smirnov test
    ## 
    ## data:  analysis_data$wait_times_2min and analysis_data$wait_times_3min
    ## D = 0.022789, p-value = 2.36e-07
    ## alternative hypothesis: two-sided

``` r
# adjust p-values
paste("The adjusted p-values for each respective test are",p.adjust(c(one_two_res$p.value, one_three_res$p.value, two_three_res$p.value), method = "hochberg"))
```

    ## [1] "The adjusted p-values for each respective test are 8.15491874028851e-09"
    ## [2] "The adjusted p-values for each respective test are 1.43218770176645e-14"
    ## [3] "The adjusted p-values for each respective test are 2.35996039488207e-07"

We see a significant difference between all three distributions.
Although this is great news, I strongly wonder if the data violate the
iid assumption of the KS test. Even though some wait times may be
independent of one another (i.e., morning rush from evening rush,
January from June), I doubt that this is the case across all the data.
Two consectutive trains are unlikely to be independent. Nevertheless,
this test gives us an additional piece of information that we will use
with caution.

# Test difference between distribution means

As discussed above, the iid assumption is trick with this data. However,
I’d like to get some 95% confidence intervals for the difference between
the
means.

``` r
t1 <- t.test(analysis_data$wait_times_1min, analysis_data$wait_times_2min)
t2 <- t.test(analysis_data$wait_times_1min, analysis_data$wait_times_3min)
t3 <- t.test(analysis_data$wait_times_2min, analysis_data$wait_times_3min)
paste("The 95% confidence interval for the difference in means between 1min vs 2min is (", round(t1$conf.int[1],3),",", round(t1$conf.int[2],3),")")
```

    ## [1] "The 95% confidence interval for the difference in means between 1min vs 2min is ( -0.624 , -0.315 )"

``` r
paste("The 95% confidence interval for the difference in means between 1min vs 3min is (", round(t2$conf.int[1],3),",", round(t2$conf.int[2],3),")")
```

    ## [1] "The 95% confidence interval for the difference in means between 1min vs 3min is ( -0.464 , -0.161 )"

``` r
paste("The 95% confidence interval for the difference in means between 2min vs 3min is (", round(t3$conf.int[1],3),",", round(t3$conf.int[2],3),")")
```

    ## [1] "The 95% confidence interval for the difference in means between 2min vs 3min is ( 0.002 , 0.311 )"

# Probality of Wait Times

Next I will calculate the probability of waiting 30+ minutes, of waiting
27-29 minutes (the myth), and of waiting less than 5 minutes for each of
the distributions.

## The 1 minute myth

I’m allowing for a range of 1 to 3 minutes to qualify as the myth given
that I’m looking at a range of exit times. First I’ll calculate the
marginal probabilities, and then move onto conditional probabilities.

``` r
# Between 27 and 29 minutes (the myth)
paste("The probability of waiting between 27 and 29 minutes for the ferry is",round(sum(analysis_data$wait_times_1min >= 27 & analysis_data$wait_times_1min <= 29.9)/dim(analysis_data)[1],2))
```

    ## [1] "The probability of waiting between 27 and 29 minutes for the ferry is 0.05"

``` r
paste("The probability of waiting between 27 and 29 minutes for the ferry is",round(sum(analysis_data$wait_times_2min >= 27 & analysis_data$wait_times_2min <= 29.9)/dim(analysis_data)[1],2))
```

    ## [1] "The probability of waiting between 27 and 29 minutes for the ferry is 0.04"

``` r
paste("The probability of waiting between 27 and 29 minutes for the ferry is",round(sum(analysis_data$wait_times_3min >= 27 & analysis_data$wait_times_3min <= 29.9)/dim(analysis_data)[1],2))
```

    ## [1] "The probability of waiting between 27 and 29 minutes for the ferry is 0.05"

Whether or not it’s surprising, missing the ferry by a couple minutes
has a small probability. Let’s see if there are differences if we
condition on hour of day.

``` r
myth_hour <- analysis_data %>% 
  group_by(as.factor(hour)) %>% 
  summarise(prob_1min = sum(wait_times_1min >= 27 & wait_times_1min <=29.9)/n(),
            prob_2min = sum(wait_times_2min >= 27 & wait_times_2min <=29.9)/n(),
            prob_3min = sum(wait_times_3min >= 27 & wait_times_3min <=29.9)/n())
colnames(myth_hour)[1] <- "Hour"
print.data.frame(myth_hour)
```

    ##    Hour   prob_1min   prob_2min   prob_3min
    ## 1     0 0.067660550 0.064220183 0.096330275
    ## 2     1 0.020322773 0.013150030 0.197848177
    ## 3     2 0.072192513 0.072192513 0.101604278
    ## 4     3 0.334851936 0.317767654 0.044419134
    ## 5     4 0.094512195 0.060975610 0.097560976
    ## 6     5 0.118497110 0.080924855 0.054913295
    ## 7     6 0.049786629 0.028449502 0.015647226
    ## 8     7 0.001305483 0.002610966 0.002610966
    ## 9     8 0.002821670 0.002821670 0.001693002
    ## 10    9 0.038671294 0.036192365 0.049082796
    ## 11   10 0.057503506 0.058906031 0.063814867
    ## 12   11 0.057169634 0.048734770 0.069353327
    ## 13   12 0.062365591 0.060215054 0.082795699
    ## 14   13 0.047675805 0.039332539 0.053635280
    ## 15   14 0.037383178 0.038421599 0.065420561
    ## 16   15 0.063078217 0.044575273 0.046257359
    ## 17   16 0.003084040 0.001542020 0.003855050
    ## 18   17 0.003438395 0.004584527 0.002865330
    ## 19   18 0.002390915 0.002390915 0.003586372
    ## 20   19 0.004895105 0.006293706 0.006993007
    ## 21   20 0.078163772 0.066997519 0.059553350
    ## 22   21 0.037428023 0.026231606 0.095009597
    ## 23   22 0.116042078 0.084155161 0.020381328
    ## 24   23 0.057098765 0.058641975 0.066358025

Some interesting patterns emerge in the conditional probabilities. For
the 1 minute and 2 minute exit times, you have a 33% and 32% chance,
respectively, of just missing the ferry by minutes at 3 am. Yet if you
take 3 minutes to exit the terminal, you have only a 4% chance of
missing the ferry by minutes at 3 am. A similar pattern exists for 10 pm
ferries. In contrast, the pattern is reversed at 1 am: with a 3 minute
exit time, you have a 19% chance of just missing the ferry by minutes.
But if you take 2 minutes or 1 minute to exit, you have only 1 % and 2%
chance, respectively.

Given the high May median from the by-month distribution, I’ll check the
probability of waiting 27-29 minutes (inclusive) by month.

``` r
probs_month <- analysis_data %>% 
  group_by(as.factor(month)) %>% 
  summarise(prob_1min = sum(wait_times_1min >= 27 & wait_times_1min <=29.9)/n(),
            prob_2min = sum(wait_times_2min >= 27 & wait_times_2min <=29.9)/n(),
            prob_3min = sum(wait_times_3min >= 27 & wait_times_3min <=29.9)/n())
colnames(probs_month)[1] <- "Month"
print.data.frame(probs_month)
```

    ##   Month  prob_1min  prob_2min  prob_3min
    ## 1     1 0.03323056 0.02569373 0.04898938
    ## 2     2 0.02437881 0.02578528 0.04641350
    ## 3     3 0.03181617 0.02386213 0.03667698
    ## 4     4 0.03868930 0.03316226 0.04026846
    ## 5     5 0.09839915 0.08858058 0.10394877
    ## 6     6 0.04907459 0.04655076 0.05019630
    ## 7     7 0.05924051 0.03265823 0.03189873
    ## 8     8 0.04869043 0.04338295 0.04245991

Something definitely happened in May – it is the only month where the
probability exceeds 0.059 across all exit times.

Finally, let’s check out the probability conditionl on weekday.

``` r
prob_weekday <- analysis_data %>% 
  group_by(as.factor(weekday)) %>% 
  summarise(prob_1min = sum(wait_times_1min >= 27 & wait_times_1min <=29.9)/n(),
            prob_2min = sum(wait_times_2min >= 27 & wait_times_2min <=29.9)/n(),
            prob_3min = sum(wait_times_3min >= 27 & wait_times_3min <=29.9)/n())
colnames(prob_weekday)[1] <- "Weekday"
print.data.frame(prob_weekday)
```

    ##   Weekday  prob_1min  prob_2min  prob_3min
    ## 1     Mon 0.06210303 0.03599153 0.04163726
    ## 2     Tue 0.07484150 0.07252203 0.04314211
    ## 3     Wed 0.04408777 0.03474197 0.03860219
    ## 4     Thu 0.03853211 0.03045872 0.09853211
    ## 5     Fri 0.04529400 0.04103470 0.04196967

Once again, the probabilities are quite low, with a range from 0.03 to
0.09. Monday, Wednesday, and Friday do appear to be the better days.
Tuesday holds the highest probability of just missing the ferry by
minutes for 1 minute and 2 minute exit times, while Thursday holds the
highest probability for 3 minute exit times.
