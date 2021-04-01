setwd("C:/Users/vm1040690/Documents/Data science/git/R-Modules/")

library(forecast)
library(lubridate)
library(data.table)
library(prophet)

# Read in the data 
df = read.csv("data_module2_out.csv",sep=",", row.names= "X")
df$fwk = as.Date(df$fwk)
df = df[df$fwk != max(df$fwk),]

# The first model we'll be trying is called AR - autoregressive model. Meaning we regress the series on its own lagged values. 
# First, let's see how the series is correlated with its own lagged values. Acf stands for auto-correlation function. 
Acf(df$sales, lag.max = 52)

# You'll notice the bar for 52 is high, as well as its previous value (lag 1).
# Let's define the AR model to only look at its previous value
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

# Let's see how well the "fit" looks like in-sample. This means we will be checking out model predictions on data on which it is trained.
# The model includes residuals (distance from actual to predictions), so we can define estimates from those as follows:
df$in_sample = (df$sales - m$resid)

plot(df$sales, type='l')
lines(df$in_sample, col="blue")

# This may look like it's capturing seasonality, but it's not. Let's have a closer look. 
plot(df[df$fwk <= "2017-12-31" & df$fwk >= "2017-11-01",c("fwk","sales")], type='o', ylim = c(0,max(df$sales)))
lines(df[df$fwk <= "2017-12-31" & df$fwk >= "2017-11-01",c("fwk","in_sample")], col="blue",type='o')

# It's always one week late, as it only knows the previous value.. this may work in low-selling season, but clearly not in high selling season.

# Let's predict into the future using the AR(1) model using predict(). 
pred = as.numeric(predict(m, n.ahead = 52)$pred) # 52 observations = 1 year

plot(c(df$sales,pred),type='l')
abline(v=nrow(df), lty= 2) 

# If the AR coefficient is <1, then we have so called mean-reversion. This means predictions will eventually turn to the mean. In this case this happens really quickly.
# Let's see if this is what happens
plot(pred,type='l')

m$x.mean

cat("mean:", round(m$x.mean),"\n","Last Pred", round(tail(pred,1))) # Getting close !

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
m = arima(df$sales, order = c(1,0,0), seasonal = list(order = c(1,0,1), period = 52), method = "ML")

df$in_sample = (df$sales - m$residuals)

plot(df[,c("fwk","sales")], type='l')
lines(df[,c("fwk","in_sample")], col="blue")

# We did it! The model now considers its previous value, a moving average component, and a seasonal component (lag 52 value) 

# The above model has gathered large popularity due to its simplicity in interpretation and stable way of working. 
# It does (like any model) have some drawbacks. Think about dealing with outliers or sudden trend changes. As the model is always using lag 1 and 52 of the 
# series, it will often not know how to properly deal with those.

# Some of the above problems can be solved using a model that works through curve-fitting. The model introduced next tries fitting a combination of 
# sin and cosine curves to the series at hand to model seasonality. It's therefore way better at handling outliers.
# It's called prophet and it's built by Facebook. Let's formulate it now:
?prophet

# Prophet needs its input variables in a predefined structure and using specific names (ds for dates and y for numerics)
df$ds = as.POSIXct(df$fwk, tz ="CET")
df$y = df$sales

# Let's formulate the model 
m <- prophet(seasonality.mode = 'additive',
             growth = "linear", 
             changepoint.range = 0.8,
             yearly.seaonality = TRUE,
             weekly.seasonality = FALSE)

# Explanation of arguments passed to the function:
# Seasonality Mode: is seasonality additive or multiplicative? 
# Growth: is trend linear or logistic?
# Changepoint Range: Allow the growth curve to change up to X percent of the training set. 80% is the default. 
# ... there's a range of other arguments that can (optionally) be used like use defining changepoints, setting the number of changepoints to evaluate,
# the flexibility of rate changes, etc.  

# Let's fit the model and use plot to see the predictions 
m <- suppressMessages(fit.prophet(m, df))
plot(m,predict(m, df))

# Can also inspect the components of model
prophet_plot_components(m,predict(m,df))


# The fit looks to be capturing seasonality quite well.
# However, we do see that the last couple of weeks are not so closely fit. We're constantly predicting above actual sales, as COVID 19 has impacted BBY sales.
# One thing we could do is adjust the flexibility of changepoints to the trend component. This is done by changing the changepoint range and the flexibility
# of the changepoint acceptance. This is done through changing the scale parameter of our sparse prior (read article for more info on this). 

# Let's formulate the model 
m <- prophet(seasonality.mode = 'additive',
             growth = "linear", 
             changepoint.range = 1,
             changepoint.prior.scale = 1,
             yearly.seaonality = TRUE,
             weekly.seasonality = FALSE)


# Let's fit the model and use plot to see the predictions 
m <- suppressMessages(fit.prophet(m, df))
plot(m,predict(m, df))

## As you can see, we are now much more closely fitting the last months' sales. 

# We can now predict into the future using predict()
future = make_future_dataframe(m, 53, freq = 'week', include_history = TRUE)
future = left_join(future, df %>% dplyr::select(ds, sales), by = 'ds')
future$pred = predict(m, future)$yhat

# Let's check it out
plot(future[c("ds","sales")],type="l", ylim =c(0,max(future$sales, na.rm=TRUE)))
lines(future[c("ds","pred")], col="blue")


