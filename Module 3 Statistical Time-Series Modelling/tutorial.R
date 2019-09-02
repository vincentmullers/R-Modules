setwd("C:/Users/vm1040690/Documents/Data science/git/R-Modules/")

library(forecast)
library(lubridate)
library(data.table)
library(prophet)

# Read in the data 
df = read.csv("./df_m2.csv",sep=",", row.names= "X")
df$week = as.Date(df$week)
df = df[df$week != max(df$week),]

# The first model we'll be trying is called AR - autoregressive model. Meaning we regress the series on its own lagged values. 
# First, let's see how the series is correlated with its own lagged values.
Acf(df$sales, lag.max = 52)

# You'll notice the bar for 52 is high, as well as its previous value (lag 1).
# Let's define the AR model to only look at its past value
m = ar(x = df$sales, aic = FALSE, method = "ols", order.max = 1, demean = T)

# Check out features of the model
m
m$ar

# You'll see this is the same as fitting a linear model based on its lagged (-1) value. (We do need to set same optimization method for AR model -> ols)
# Let's prove this out 
lag = shift(df$sales,1)[2:nrow(df)]
lm = lm(sales ~ lag, data = df[2:nrow(df),])
lm

round(m$ar[1],2) == round(lm$coefficients[["lag"]],2)

# Redefine model with other optim. method
m = ar(x = df$sales, order.max = 1, demean = T)

# Let's see how well the "fit" looks like in-sample. This means we will be checking out model predictions on data on which it is trained.
# The model includes residuals, so we can define estimates from those as follows
df$in_sample = (df$sales-m$resid)

plot(df$sales, type='l')
lines(df$in_sample, col="blue")

# May look like it's capturing seasonality, but it's not. Let's have a closer look. 
plot(df$sales[df$week <= "2015-12-31" & df$week >= "2015-11-01"], type='o')
lines(df$in_sample[df$week <= "2015-12-31" & df$week >= "2015-11-01"], col="blue",type='o')

# It's always one week late, as it only knows the previous value.. this may work in low-selling season, but clearly not in high selling season.

# Let's predict into the future using the AR(1) model. Use predict(). 
pred = as.numeric(predict(m, n.ahead = 52)$pred) # 52 observations = 1 year
# Ignore the warning, it just doesnt like working with 1 dim arrays

plot(c(df$sales,pred),type='l')
abline(v=nrow(df), lty= 2) 

# If the AR coefficient is <1, then we have so called mean-reversion. This means predictions will eventually turn to the mean. In this case this happens really quickly.
# Let's see if this is what happens
plot(pred,type='l')

m$x.mean
round(m$x.mean) == round(tail(pred,1)) # Yes !

# For mathematical proof, see screenshot I added. 

# Now we've seen an AR(1) model at work. Let's extend to ARMA models. This stands for autoregressive, moving average models.
# The AR models do not take into consideration trend. We can account for this by adding a moving average component.
# This is a parameter regressed on the residuals (checks if we're consistently higher or lower, which would indicate an upward or downward trend)
# Let's formulate this model
m = arima(df$sales, order = c(1,0,1)) # first order indicates autoregressive terms, second one integration, third one moving average terms.
m

df$in_sample = (df$sales - m$residuals)

plot(df$sales, type='l')
lines(df$in_sample, col="blue")

# Still no seasonality, but we do capture some trend now.
# lets formulate a SARMA model (seasonal autoregressive moving average model)
m = arima(df$sales, order = c(1,0,0), seasonal = list(order = c(1,0,1), period = 52), method = "ML") # Need to estimate using Maximum Likelihood as the columns are colinear

df$in_sample = (df$sales - m$residuals)

plot(df[,c("week","sales")], type='l')
lines(df[,c("week","in_sample")], col="blue")

# We did it! The model now considers its previous value, a moving average component, and a seasonal component (lag 52 value) 

# Still a drawback though.. if you look carefully you'll see that we expect a dip around 2017-03-26 because that happened in the year before..
# if we look at the whole series we would actually probably rather say that's an outlier and not really take it into consideration
# Moreover, we expect the fit to be really tight as we're using the previous value.. note that predicting out for a long time will be tricky.

# Some of the above problems can be solved using a model that works through curve-fitting. The model introduced below tries fitting a combination of 
# sin and cosine curves to the series at hand. It's therefore way better at handling outliers, and perhaps also at dealing with seasonality.
# It's called prophet and it's build by Facebook. Let's formulate it now:
?prophet

# Prophet needs its input to look a certain way (ds for dates and y for numerics)
df$ds = as.POSIXct(df$week, tz ="CET")
df$y = df$sales

# Let's reformulate the model 
m <- prophet(seasonality.mode = 'additive',
             growth = "linear", 
             changepoint.range = 0.8,
             yearly.seaonality = TRUE,
             weekly.seasonality = FALSE)

# note we defined changepoint range to be 0.8. This means we allow to make changepoints to the growth curve it fits (which we set to be linear)
# based on the first 80% of the data. Sometimes it makes sense to set this at 100% if you expect sudden changes in growth. Since we do not expect
# that in this case, we set it at 80% to prevent it making weird jumps at the end of the series.

m <- suppressMessages(fit.prophet(m, df))

plot(m,predict(m, df))

# Can also inspect elements in model
prophet_plot_components(m,predict(m,df))

# this shows it considers the observation in 2016 as an outlier.. it allows the prediction to have a large deviation form actuals on this particular point. 
# We see we still have an issue fitting the peaks. The reason here is that we only see this kind of seasonality in the last month. 
# So fitting monthly seasonality won't matter, as we don't see this pattern in the other months..
# One of two solutions would be to add a regressor for week 52 (or possibly 51 and 52)
# Let's reformulate the model 

df$regressor = df$number == 51

m <- prophet(seasonality.mode = 'additive',
             growth = "linear", 
             changepoint.range = 0.8,
             yearly.seaonality = TRUE,
             weekly.seasonality = FALSE)

m <- add_regressor(m, "regressor")
m$extra_regressors

m <- suppressMessages(fit.prophet(m, df))

plot(m,predict(m, df))

# another solution would be to define a model for low selling season, and one for high selling season 
m_low <- prophet(seasonality.mode = 'additive',
             growth = "linear", 
             changepoint.range = 0.8,
             yearly.seaonality = TRUE,
             weekly.seasonality = FALSE)

m_low <- suppressMessages(fit.prophet(m_low, df[df$number <= 46,]))

low_selling = predict(m_low,df[df$number <= 46,])$yhat
plot(m_low,predict(m_low, df[df$number <= 46,]))
# Looks quite good!

# now for high selling season
m_high <- prophet(seasonality.mode = 'additive',
             growth = "linear", 
             changepoint.range = 0.8,
             yearly.seaonality = TRUE,
             weekly.seasonality = FALSE)

m_high <- suppressMessages(fit.prophet(m_high, df[df$number > 46,]))

high_selling = predict(m_high,df[df$number > 46,])$yhat
plot(m_high,predict(m_high, df[df$number > 46,]))

# Now combine
df$pred[df$number > 46] = high_selling
df$pred[df$number <= 46] = low_selling

plot(df[,c("week","sales")], type='o')
lines(df[,c("week","pred")], col="blue", type='o')

# Looking as good as you may expect! Some noise is simply not explanable given the data we have (like the large lift during last year's amazon prime day)

# Let's predict into the future.  
# first set up future data frame (same way as we did for date mapping in module 2) until CY end 2020
cal_w = seq(as.Date(paste("2001","-01-01",sep="")),as.Date(paste("2001","-12-24",sep="")),by="week")
cal_w = gsub("2001",min(year(df$ds)),cal_w)
cal_w = lapply(0:(length(unique(year(df$ds)))),function(x) {gsub(min(unique(year(df$ds))),unique(year(cal_w))+x,cal_w)})
cal_w = data.frame("ds" = unlist(cal_w), "number" = rep(1:52,length(unique(year(df$ds)))+1))
cal_w$ds = as.Date(cal_w$ds)
cal_w$ds = as.POSIXct(cal_w$ds, tz= "CET")

future = join(cal_w, df[,c("ds","sales")],type='left')

# redefine regressor variable for total set of dates
future$regressor = future$number == 51

# Now predict using m_low and m_high and provide corresponding data sets
future$pred = NA
future$pred[future$number <= 46] = predict(m_low, future[future$number <= 46,])$yhat

# Let's check it out
plot(future[c("ds","sales")],type="l")
lines(future[c("ds","pred")], col="blue")

# Only modelled low selling season. Let's add high selling now using the other model.
future$pred[future$number > 46] = predict(m_high, future[future$number > 46,])$yhat

# Let's check it out
plot(future[c("ds","sales")],type="l")
lines(future[c("ds","pred")], col="blue")

# Pretty cool model right. Let's put you to work in practice.R!

