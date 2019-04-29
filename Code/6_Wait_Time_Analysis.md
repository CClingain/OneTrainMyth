Wait Time Analysis
================
Clare Clingain
April 29, 2019

# Initial Visualizations

## Density plots

``` r
# overlay plot
plot(density(analysis_data$wait_times_1min), main = "Wait times with 1,2, and 3 minutes exit time", col = 2)
lines(density(analysis_data$wait_times_2min), col = 4)
lines(density(analysis_data$wait_times_3min), col = 5)
legend("topright",legend = c("1 min","2 min","3 min"), lty = 1, lwd = 2, col = c(2,4,5))
```

![](6_Wait_Time_Analysis_files/figure-gfm/density-1.png)<!-- -->

The three distributions look quite similar. In terms of the simulations
I ran, these distributions look like the beta distribution
results.

## Time x Wait times

``` r
plot(analysis_data$hour, analysis_data$wait_times_1min, main = "Wait times",xlab = "Hour of day",ylab = "Wait time (1 min exit time)")
```

![](6_Wait_Time_Analysis_files/figure-gfm/time%20by%20wait%20times-1.png)<!-- -->

# Test the difference between the distributions

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
this test gives us an additional peice of information that we will use
with caution.
