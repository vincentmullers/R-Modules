library(lubridate)
library(data.table)
library(dplyr)

# Let's practice! 

# EX1: Set working directory and open the file we saved at the end of the tutorial. Use row.names = "X" to prevent another column is added with the row index numbers.


# EX2: Add a column variable for calendar year and month



# EX3: Plot the data
plot(df[,c("fwk","sales")],type='l')

# It looks like there is clear seasonality in the time-series. Weekly data is however still tricky to deal with when it comes to time-series modelling. 
# This is because a year is never split into an integer number of weeks... Let's check out what that means..

# EX4: Create 4 plots in one panel, each one showing the month Dec of the years 2015 through 2018. HINT: I've added par(mfrow=c(2,2)) to create the grid for the plots, just plot 4 times to see the grid filled in. 
par(mfrow=c(2,2))



# Notice that some years have 5 weeks in dec, others 4. Depending on when what week exactly starts, the peak shifts quite a bit.... Specifically, people's purchases go up dramatically 
# the week before christmas, and dives down after. 

# Suppose we build a model that looks back 1 year to predict into the future. This would be very useful in knowing seasonality in the data. 
# EX5: Build a model below that always predicts sales to be the same as 52 weeks ago.



# EX6: plot the original series using type='l' after setting par().
par(mfrow=c(1,1))



# EX7: add the predictions using lines(). set col = "blue"



# EX8: Let's see how the predictions look like in high season for the years 2016 to 2019. Use plot. 
par(mfrow=c(2,2))



## You can see the predictions look ok, but need much more intelligence. It should for example have known sell-through would be lower at the end of 2020 due to a declining trend, or
# know that Black Friday was not falling in the same week as the year before. We'll look into how to account for this in the next modules. 

# Sometimes, before we start modelling the series, it makes sense to transform the response variable (many models for example "like" to have data that is within the 0-1 range).
# In other cases, we transform to smooth data, make a data set "stationary" (constant mean and variance over time) or for example lower the impact of outliers.
# EX9: Add a couple of columns to the data frame: log, sqrt and minmax transform of the sales column. 





# EX10: Finally, add a T52 column to the data that sums sales for the last 52 weeks (sum of previous 51 weeks and current week). This series will have NAs for the first 51 values and start at row index 52. 





# EX11: Let's save what we have as input for the next module. Use write.csv and name the file data_module2_out.csv.






