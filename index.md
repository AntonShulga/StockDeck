---
title       : Stock Price Prediction Shiny App
subtitle    : for Coursera Data Product Course
author      : AShulga
job         : 
framework   : io2012        # {io2012, html5slides, shower, dzslides, ...}
highlighter : highlight.js  # {highlight.js, prettify, highlight}
hitheme     : tomorrow      # 
widgets     : []            # {mathjax, quiz, bootstrap}
mode        : selfcontained # {standalone, draft}
knit        : slidify::knit2slides
---


## Application summary

Application link: http://ashulga.shinyapps.io/StockPricePrediction

Basic idea of the application is to develop prediction of chosen stock price for the selected number of months preceding the date of use. This period is used to test accuracy of prediction. The user is allowed to chose the length of learning horizon (which is certain amount of months preceding the test period) and width of prediction confidence interval. The accuracy of prediction can be analyzed on the plot provided as well as based on RMSE and error rate (the share of data points in test period which are out of prediction confidence interval). The app is based on the time series analysis method (exponential smoothing) which is part of forecast R package. 


--- .class #id 

## Use example

- Choose AMZN stock symbol for Amazon
- Set learning horizon to 60 months
- Set prediction horizon to 12 months
- Set confidence interval to 90%
- Push Update Stock button!

You should see that RMSE for 12 months predictions is 53.1 USD and 1/3 of the data points in test period are out of prediction interval (33% error rate).

--- .class #id 

## Accuracy analysis 1/2

Now we are going to analyse accuracy of predictions for a number of stocks (Amazon, Netflix, Microsoft and Vodafone) and for different learning depths (36/42/48/54/60 months).

```r
source("StockPred.R"); library(ggplot2) # sourcing user-defined stockPred function
results <- stockPred(c("AMZN","MSFT", "NFLX", "VOD"), c(36,42,48,54,60), 24, c(50,75,95))
yyy <- results[results$predHorizon == 24 & results$confInterval == 95,]
```


```r
ggplot(yyy, aes(lDepth, RMSE, group = stockList, color = stockList)) + geom_line() + xlab("Learning depth (months)")
```

<img src="assets/fig/unnamed-chunk-2-1.png" title="plot of chunk unnamed-chunk-2" alt="plot of chunk unnamed-chunk-2" style="display: block; margin: auto;" />

Some of the predictions (Netflix) demonstrate poor accuracy and require further improvements

--- .class #id 

## Accuracy analysis 2/2

Now we will see how sensitive the accurace is to different confidence intervals. 

```r
ggplot(results, aes(as.factor(confInterval), errRate, group = confInterval)) + geom_boxplot() + 
   xlab("Confidence interval (%)") + ylab("Error rate (%)")
```

<img src="assets/fig/unnamed-chunk-3-1.png" title="plot of chunk unnamed-chunk-3" alt="plot of chunk unnamed-chunk-3" style="display: block; margin: auto;" />

As we can see 95% confidence interval provides error rate in the range of 11-25% which is probably too large for the profitable low risk investment strategy to base on. 
The above analysis provides some grounds for declining autoregression methods as a reliable way for stock price predictions. Other factors should be considered for including into the model.  
