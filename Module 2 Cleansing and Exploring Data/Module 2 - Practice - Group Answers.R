# install.packages("data.table")
library(lubridate)
library(data.table)
library(dplyr)

# EX1: Set working directory and open the file we saved at the end of the tutorial. Use row.names = "X" to prevent another column is added with the row index numbers.
setwd("C:\\Users\\eb1035856\\OneDrive - Bose Corporation\\Documents\\GitHub\\EricBeckwith")
getwd()

df = read.csv("Module 2 tutorial.csv", 
              sep=",", 
              as.is = TRUE,
              row.names = "X")

head(df)

# EX2: Add a column variable for calendar year and month
# df$calendar_year = lubridate::year(df$fwk) # Tried this but offers weird results when trying to plot.
# df$month = lubridate::month(df$fwk)

df <- mutate(df, calendar_year = lubridate::year(df$fwk))
df <- mutate(df, month = lubridate::month(df$fwk))


# VMUL
df = df %>%
     dplyr::mutate(calendar_year = lubridate::year(fwk), 
                   month = lubridate::month(fwk))


head(df)
str(df)

# EX3: Plot the data
#fiscal week is still a character so need to change that to date before plotting
df$fwk = as.Date(df$fwk)

plot(df[,c("fwk","sales")],type='l' , ylim=range(Yaxis)) 

# VMUL
plot(df[,c("fwk","sales")],type='l', ylim = range(df$sales)) # ylim = c(0,max(df$sales)) 


#I noticed y axis wasnt formatted... I try to solve below.  
Yaxis<-c(0, 5000000 , 10000000 , 15000000 , 20000000, 25000000)


# VMUL Scientific notation of y axis
options(scipen = 50000000) # off - number of digits.
plot(df[,c("fwk","sales")],type='l', ylim = range(df$sales)) # ylim = c(0,max(df$sales)) 
options(scipen = 0) # on
plot(df[,c("fwk","sales")],type='l', ylim = range(df$sales)) # ylim = c(0,max(df$sales)) 


# formatting y axis
plot(df[,c("fwk","sales")],type='o', ylim = range(df$sales), yaxt = 'n') # do not include a y axis
axis(2, at = df$sales, labels=sprintf("%.0f", df$sales/1000))



#EX4: Create 4 plots in one panel, each one showing the month Dec of the years 2015 through 2018. HINT: I've added par(mfrow=c(2,2)) to create the grid for the plots, just plot 4 times to see the grid filled in. 
par(mfrow=c(2,2))

df2 = filter(df, fwk>= "2015-12-01" , fwk<= "2015-12-31")
head(df2)
plot(df2[,c("fwk", "sales")], type='l' , main = "2015")
df3 = filter(df, fwk>= "2016-12-01" , fwk<= "2016-12-31")
plot(df3[,c("fwk", "sales")], type='l', main = "2016")
df4 = filter(df, fwk>= "2017-12-01" , fwk<= "2017-12-31")
plot(df4[,c("fwk", "sales")], type='l', main = "2017")
df5 = filter(df, fwk>= "2018-12-01" , fwk<= "2018-12-31")
plot(df5[,c("fwk", "sales")], type='l', main = "2018")


# VMUL
for(i in c(2015,2016,2017,2018)){
  
  nam <- paste("df_", i, sep = "")
  assign(nam, df %>% dplyr::filter(month == 12 & calendar_year == i))
  
}

df_l = df %>%
       dplyr::filter(month == 12) %>% 
       split(f = .$calendar_year)

for(i in seq_along(df_l)){
  
  plot(df_l[[i]][c("fwk","sales")], type='o')
  
}

par(mfrow=c(2,2))
plot(df[df$calendar_year == "2016" & df$month == 12,c("fwk","sales")],type='o')
plot(df[df$calendar_year == "2017" & df$month == 12,c("fwk","sales")],type='o')
plot(df[df$calendar_year == "2018" & df$month == 12,c("fwk","sales")],type='o')
plot(df[df$calendar_year == "2019" & df$month == 12,c("fwk","sales")],type='o')


library(ggplot2)
df  = df %>% dplyr::mutate(week = week(fwk))

ggplot(df %>% dplyr::filter(month == 12), aes(x = week, y = sales, color = as.factor(calendar_year))) +
geom_line() + 
theme_light() + 
theme_economist()

### 

# EX5: Build a model below that always predicts sales to be the same as 52 weeks ago.
df <- mutate(df, Pred = shift(df$sales, n = 52, fill = NA, type=c("lag"), give.names=FALSE)) 
head(df)


#EX6: plot the original series using type='l' after setting par().
par(mfrow=c(1,1))
plot(df[,c("fwk","sales")],type='l' , ylim=range(Yaxis))


# EX7: add the predictions using lines(). set col = "blue"
plot(df[,c("fwk","sales")],type='l' , ylim=range(Yaxis))
lines(df$fwk, df$Pred, col = "blue") # df[,c("fwk,"Pred")]
  
# EX8: Let's see how the predictions look like in high season for the years 2016 to 2019. Use plot. 
par(mfrow=c(2,2))

# VMUL: Similar case as above. Also, why not filter on df? 
df3 = df

df3= filter(df3, fwk>= "2016-12-01" , fwk<= "2016-12-31")
plot(df3[,c("fwk", "sales")], type='l', main = "2016")
lines(df3$fwk, df3$Pred, col = "blue")

df4=df

df4= filter(df4, fwk>= "2017-12-01" , fwk<= "2017-12-31")
plot(df4[,c("fwk", "sales")], type='l', main = "2017")
lines(df4$fwk, df4$Pred, col = "blue")

df5=df

df5= filter(df5, fwk>= "2018-12-01" , fwk<= "2018-12-31")
plot(df5[,c("fwk", "sales")], type='l', main = "2018")
lines(df5$fwk, df5$Pred, col = "blue")

df6=df

df6= filter(df6, fwk>= "2019-12-01" , fwk<= "2019-12-31")
plot(df6[,c("fwk", "sales")], type='l', main = "2019")
lines(df6$fwk, df6$Pred, col = "blue")

# VMUL: For last one need to set a ylim. ylim = c(0,max(c(df$sales,df$Pred)))


## You can see the predictions look ok, but need much more intelligence. It should for example have known sell-through would be lower at the end of 2020 due to a declining trend, or
# know that Black Friday was not falling in the same week as the year before. We'll look into how to account for this in the next modules. 

# Sometimes, before we start modelling the series, it makes sense to transform the response variable (many models for example "like" to have data that is within the 0-1 range).
# In other cases, we transform to smooth data, make a data set "stationary" (constant mean and variance over time) or for example lower the impact of outliers.
# EX9: Add a couple of columns to the data frame: log, sqrt and minmax transform of the sales column. 
df <- mutate(df, log = log(df$sales) , sqrt = sqrt(df$sales), 
             MM_transform = (df$sales - min(df$sales))/ (max(df$sales)-min(df$sales)))

head(df)

max(df$MM_transform)
min(df$MM_transform)

# EX10: Finally, add a T52 column to the data that sums sales for the last 52 weeks (sum of previous 51 weeks and current week). This series will have NAs for the first 51 values and start at row index 52. 
df<- mutate(df, T52 = data.table::frollsum(df$sales, n = 52))

head(df)


# EX11: Let's save what we have as input for the next module. Use write.csv and name the file data_module2_out.csv.
write.csv(df, "data_module2_out.csv")

sample (c("Luis","Dave","Martin", "Athena"), size = 1)


                           