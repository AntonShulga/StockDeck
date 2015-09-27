require(quantmod); require(forecast)
options("getSymbols.warning4.0"=FALSE) 

stockPred <- function(stockList, lDepth, predHorizon, confInterval) {
   
   result <- data.frame(symb=character(), 
                      lDepth = integer(), 
                      predHor = integer(), 
                      confInt = integer(),
                      RMSE = numeric(),
                      errorRate = numeric())
   
   for(i in 1:length(stockList)) {
      for (j in 1:length(lDepth)) {
         for (n in 1:length(predHorizon)) {
            data <- as.data.frame(getSymbols(stockList[i], src = "yahoo", 
                                             from = as.character(Sys.Date()-lDepth[j]*30.5-predHorizon[n]*30.5),
                                             to = as.character(Sys.Date()),
                                             auto.assign = FALSE))
            
            data <- to.monthly(data)
            
            data <- Cl(data)
            
            ts1 <- ts(data, frequency = 12)
            
            ts1Train <- window(ts1, start = 1, end = (lDepth[j])/12+1-0.01)
            ts1Test <- window(ts1, start = lDepth[j]/12+1, end = length(ts1)/12+1-0.1)
            
            ets1 <- ets(ts1Train, model="MMM")
            
            fcast <- forecast(ets1, h = predHorizon[n], level = confInterval)
            
            RMSE <- sqrt(mean((fcast$mean - ts1Test)^2))
            
            for (m in 1:length(confInterval)) {
               errIndex <- fcast$lower[(1:predHorizon[n])+predHorizon[n]*(m-1)] > ts1Test | fcast$upper[(1:predHorizon[n])+predHorizon[n]*(m-1)] < ts1Test
               errRate <- sum(errIndex) / length(errIndex)
               
               result <- rbind(result, data.frame(stockList[i],
                                              lDepth[j],
                                              predHorizon[n],
                                              confInterval[m],
                                              RMSE,
                                              errRate*100))
               
            }
             
         }
      }
   }
   
   names(result) <- c("stockList","lDepth","predHorizon","confInterval","RMSE","errRate")
   return(result)
}

# VIPdata <- as.data.frame(getSymbols("GS", src = "yahoo", 
#    from = "2012-01-01",
#    to = as.character(Sys.Date()),
#    auto.assign = FALSE))
# 
# mVIP <- to.monthly(VIPdata)
# 
# VIPcl <- Cl(mVIP)
# 
# ts1 <- ts(VIPcl, frequency = 12)
# 
# ts1Train <- window(ts1, start = 1, end = 4-0.01)
# ts1Test <- window(ts1, start = 4, end = 4.66)
# 
# ets1 <- ets(ts1Train, model="MMM")
# 
# fcast <- forecast(ets1, h=8, level = 95)
# 
# errIndex <- fcast$lower > ts1Test | fcast$upper < ts1Test 
# 
# plot(fcast, main = "PLot")
# lines(ts1Test, col="red")
# cc <- rep("green", 8)
# cc[errIndex] <- "red"
# points(ts1Test, col = cc)
