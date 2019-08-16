library(dplyr)
library(plyr)

# Before using any function you can check out some information (see help pane down right) by running a ? before the function name:
?seq

# Let's generate some dates
dates = seq(as.Date("2019-01-01"),as.Date("2019-12-01"),by='week')

## .. and some numbers drawn from a normal distribution with the same length as the dates vector
# First set the seed to make sure we get the same result every time we run this
set.seed(5)
y = rnorm(length(dates), mean = 0, sd = 1)

# Combine the two into a dataframe 
df = data.frame(dates,y)

# Let's see how this looks like - use type='l' for a line plot
plot(df,type='l')

# check out data type
str(df)

# Let's add some details about the date
df$week = week(df$dates)
df$year = year(df$dates)

# Get rid of columns
df[,c("week","year")] = NULL
head(df)

# Let's reintroduce them in another way: Using so called piping (%>%). This means that the result of one line is carried over to the next one. We add a pipe after each operation.
# the dplyr library is used here
df = df %>% 
  mutate("week" = week(df$dates)) %>%
  mutate("year" = year(df$dates)) %>%
  mutate("quarter" = quarter(df$dates))

# How can we access the year column of our data frame? 2 options. 
df[,c("year")]
df[["year"]]

# How would that work for a list?
# Let's first create a list for each quarter
df = split(df,f = df$quarter)

# Let's see how our data structure looks now
str(df)

# We've got a list of 4 data frames! one for each quarter. 
# Access the data frame of the second quarter
df[[2]]

# Now let's print the year of this quarter - multiple ways.. 
df[[2]][["year"]]
df[[2]]$year
df[[2]][,c("year")]

# R uses [,] to indicate which columns and rows we want (on the left of the , the rows; on the right the columns). If we use [[]] then we are concentrating only on columns.  

# Let's convert back to a data frame. Put .id to the value it should add for the names of the lists (in this case we split on quarter).
df = ldply(df, .id = "quarter")

## Filtering. 
# Let's filter out quarter 2.
# notice we need to indicate the filter on the left side of [,] as we're filtering on the rows!
# first, let's see what happens if we indicate the requirement:
df$quarter != 2

# It returns a sequence of TRUE and FALSE with the length of the data frame. We want to keep the rows where we see TRUE, and remove the ones that returned FALSE. We do this as follows:
df = df[df$quarter != 2,]

# Let's check if the second quarter is gone
unique(df$quarter)

# Now let's remove a column, notice we need to indicate the filter on the right side of [,]
# first let's set up the filter
colnames(df) != "week"

# All of them are true except for the third one. So let's remove the third column
df = df[,colnames(df) != "week"]
head(df)

# we can have multiple conditions too. Let's look at negative values in Q1.
df$y[df$y < 0 & df$quarter == 1]

# lets put these to 0
df$y[df$y <0 & df$quarter == 1] = 0

# no negative values in the first quarter anymore!
plot(df$y,type='l')

# check using any() if there's values below 0 in the first quarter
df$y[df$quarter == 1] < 0
# any now will check if any of these printed values are TRUE - which is not the case,so it will print FALSE
any(df$y[df$quarter == 1] < 0)

# Loops. Let's check out some for loops. 
# Let's say we want to interpolate between the first and last value of each quarter 

for(quarter in unique(df$quarter)){
  
  # I am adding a cat here which will print the quarter it is working on in the current iteration. The "\n" makes sure we add a new line after each printed value. 
  cat(quarter,"\n")
  
  # define a temp variable that is df at the quarter of the current iteration
  temp = df[df$quarter == quarter,] 
  
  # define first and last value of the quarter
  first_value = temp$y[1]  
  last_value = tail(temp$y,1)
  
  # change y to be the interpolated values between first and last value of the quarter. I use the function approx to do the interpolation here.
  df$y[df$quarter == quarter] = approx(x = c(first_value,last_value), n = nrow(temp))$y
  
}

# check out what happened
plot(df[,c("dates","y")])

# first quarter started at 0 and ended at 0 so simply stayed at 0. 

# One other loop is the while loop. 
# Let's say we want to keep adding a random positive number to all values in the data frame, until the total reaches at least 1,000
# at this point the total is:
sum(df$y)

# let's define the while loop:
while(sum(df$y) < 100){
  
  # Runif means we're sampling from a uniform distribution, so all values are equally likely. We specify n = 1 as we want to sample one value that we're going to add to the values in the df. 
  # I specify that the minimum value of the distribution is 0 and max is 1.
  add = runif(1, min = 0, max = 1)
  
  # Let's print what we are adding at each iteration
  cat("adding:", add,"\n")
  
  df$y = df$y + add

  # Let's also print the total at this moment to see how close we are to our goal of a total value of 100.
  cat("total at this point:", sum(df$y),"\n")
  
}

# In my case, after adding 6 random values to all y's, I've reached a total of 115! This will very likely be different for you, as in this case we did not set.seed. 


# Finally, I am going to aggregate the y values by quarter
agg = aggregate(y ~ quarter, data = df, sum)
agg

# This is the end :) Move on to the practice module!








