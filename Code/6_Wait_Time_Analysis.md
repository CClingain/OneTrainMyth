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
plot(analysis_data$weekday, analysis_data$wait_times_1min, main = "Wait times (1 min exit time)",xlab = "Hour of day",ylab = "Wait time")
```

![](6_Wait_Time_Analysis_files/figure-gfm/weekday%20by%20wait-1.png)<!-- -->

``` r
plot(analysis_data$weekday, analysis_data$wait_times_2min, main = "Wait times (2 min exit time)",xlab = "Hour of day",ylab = "Wait time")
```

![](6_Wait_Time_Analysis_files/figure-gfm/weekday%20by%20wait-2.png)<!-- -->

``` r
plot(analysis_data$weekday, analysis_data$wait_times_3min, main = "Wait times (3 min exit time)",xlab = "Hour of day",ylab = "Wait time")
```

![](6_Wait_Time_Analysis_files/figure-gfm/weekday%20by%20wait-3.png)<!-- -->

I’m curious as to why the distributions for Tuesday and Thursday seem
more spread and have slightly higher medians than Monday, Wednesday, and
Friday. Once again, we see that the long delays seem to be evenly
distributed across days of the week. I’d like to test if these
distrbutions are different from each other later on.

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
