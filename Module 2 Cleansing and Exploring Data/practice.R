library(lubridate)

# Let's practice! 

# Set working directory and open the file we saved at the end of the tutorial. Use row.names = "X" to prevent another column is added with the row index numbers.


# add a variable for year and month


# Plot the data
plot()

# It looks like there is clear seasonality in the time-series. Weekly data however is troublesome to deal with in time-series models. This is because a year is never split into 
# an integer number of weeks... Let's check out what that means..

# Create 4 plots in one panel each one showing the month Dec of the years 2015 through 2018. HINT: I've added par(mfrow=c(2,2)) to create the grid for the plots, just plot 4 times to see the grid filled in. 
par(mfrow=c(2,2))


# Notice that some years have 5 weeks in dec, others 4. Depending on when what week exactly starts, the peak shifts quite a bit.... Specifically, people's purchases go up dramatically 
# the week before christmas, and dives down after. Depending on when exactly our weeks start, we see the peak moving.. 
# This is troublesome for working with seasonality in time-series forecasting. -> working with weekly data is difficult

# Let's prove this out further.
# Suppose we build a model that looks back 1 year to predict into the future. This would be very useful in knowing seasonality in the data. 
# Build a model below that always predicts sales to be the same as 52 weeks ago. HINT: use shift() from the data.table package
library(data.table)

# plot the original series using type='l'
par(mfrow=c(1,1))

# add the predictions using lines(). set col = "blue"


# In the same way we could build a model that looks back to the date that is closest to the current date -1y
# Build a model that does this.



# Notice that there's almost no difference between model 1 and model 2 (only first prediction)

# Let's see how the predictions look like. Check out high selling season again as done above using plot, lines, ylim and col. 


# Note that some peaks are wrong. 
# The main reason is that we have the largest peak (besides BF) in the week before christmas. Depending on when our fiscal week starts, this week gets broken into pieces.
# The fact that we're working with weeks means we get different timing every year, and therefore different peaks. 
# -> We don't want to be comparing last year's 20 Dec start week to this year's 18 Dec start week as we capture 2 days less of this highest selling week.  


# Still it would be nice to work with weeks instead of months.. So let's try a potential solution.
# I have created a function in date_mapping.R that we can source here and use to convert our fiscal weeks to calendar weeks!
source("./Module 2 Cleansing and Exploring Data/date_mapping.R")

# Notice in the environment that the function date_mapping has been added
date_mapping

# First got to load some libraries
library(parallel)

# Now let's use the function to map fiscal week to calendar week
df_cw = date_mapping(df = df) # only needs one parameter, which is the data.frame

par(mfrow=c(1,1))
plot(df_cw[,c("week","sales")],type='l')
lines(df[,c("fwk","sales")],type='l',col="blue")
df_cw$month = month(df_cw$week)
df_cw$year = year(df_cw$week)

# Let's see how the years now look like.
par(mfrow=c(2,2))
plot(df_cw[df_cw$year == "2015" & df_cw$month == 12,c("number","sales")],type='o',ylim=c(0,max(df_cw$sales[df_cw$number >= 49])))
plot(df_cw[df_cw$year == "2016" & df_cw$month == 12,c("number","sales")],type='o',ylim=c(0,max(df_cw$sales[df_cw$number >= 49])))
plot(df_cw[df_cw$year == "2017" & df_cw$month == 12,c("number","sales")],type='o',ylim=c(0,max(df_cw$sales[df_cw$number >= 49])))
plot(df_cw[df_cw$year == "2018" & df_cw$month == 12,c("number","sales")],type='o',ylim=c(0,max(df_cw$sales[df_cw$number >= 49])))

par(mfrow=c(2,2))
plot(df[df$year == "2015" & df$month == 12,c("fwk","sales")],type='o',ylim=c(0,max(df$sales)))
plot(df[df$year == "2016" & df$month == 12,c("fwk","sales")],type='o',ylim=c(0,max(df$sales)))
plot(df[df$year == "2017" & df$month == 12,c("fwk","sales")],type='o',ylim=c(0,max(df$sales)))
plot(df[df$year == "2018" & df$month == 12,c("fwk","sales")],type='o',ylim=c(0,max(df$sales)))

# Allows us to compare the same weeks. 
# Let's save what we have. 
write.csv()


