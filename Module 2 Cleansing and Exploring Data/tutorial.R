library(lubridate)
library(dplyr)

# -------------------------------------------------------------------------------------------------- #
# Now we have some data loaded onto our local file system, we can load the data and check it out.    #
# In this tutorial, I will show you some nice ways to format and preprocess data.                    #
# -------------------------------------------------------------------------------------------------- #


# Let's find out what the working directory is 
getwd()

# We can change the working directory to where your file is located, so it's easy to load the data in we ingested from Module 1. 
# Make sure the file is saved to a folder and replace the below path to point to that folder. I placed it in my git folder under R-Modules. 
setwd("C:/Users/vm1040690/Documents/Data science/git/R-Modules/")
getwd()

# There's a trick to quickly set your working directory to the path this file is in. 
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()

# Read in data - make sure to change the path if your data.csv is located somewhere else. 
df = read.csv("../Module 1 Data Retrieval and Initial Processing/data.csv", 
                 sep=",", 
                 as.is = TRUE,
                 row.names = "X")

head(df)
str(df)

# We've got quite a lot of data here
nrow(df)

# In the last module, we did not rename columns yet, so let's do that first
colnames(df) <- c("sales","sales_org","fwk", "zip","channel","sold_to") 
  
# Let's focus down on Best Buy
df = df %>%
     # Remember that, in Module 1, you did not fix the NAs in the sold_to field. We need to remove those first, 
     # because the filter cannot evaluate sold_to == "BB" if sold_to is NA. 
     dplyr::filter(!is.na(sold_to)) %>%
     dplyr::filter(sold_to == "BB") %>%
     dplyr::select(-channel)

## Check that we're only left with BB in the sold_to field and NAs are removed.
unique(df$sold_to)

# We'll leave zip codes for what they are now, and aggregate sales over fiscal week. Notice I use na.rm = TRUE as there may be NAs in the sales field
df = aggregate(formula = sales ~ fwk, 
               data = df, 
               FUN = function(x) { sum(x, na.rm = TRUE) }
               )

# Only look at last 5 years
years = tail(unique(year(df$fwk)),5) # or for better visibility of steps: years = year(df$fwk) %>% unique() %>% sort(decreasing = FALSE) %>% tail(5)
df = df[year(df$fwk) %in% years,]

# Let's try to plot this
plot(df, type = 'l') # will throw an error as the data structure for fwk hasn't been set to date yet  

# Let's convert to dates and plot
df$fwk = as.Date(df$fwk)
plot(df, type='l')

# The last (current) week may not have finished yet, so let's cut it off
df = df[df$fwk != max(df$fwk),]
plot(df, type='l')


# There's currently a problem with BB data at Apr 1 2017 - let's get rid of this date.
df = df[df$fwk != "2017-04-01",]


# We need to fix 1 April: There's a new fiscal week created on 1 April which disrupts the sequence of weeks. 
# first I want to know the weekdays (if 1 april is starting on sunday then everything is ok)
df$wday = weekdays(df$fwk)

# Let's capture all April 1st's that do not start on a sunday and therefore need to be fixed - change 
dates_collapse = sort(unique(df$fwk[month(df$fwk) == 4 & day(df$fwk) == 1 & df$wday != "zondag"])) # change to "sunday" if you're in the US
dates_collapse = dates_collapse[dates_collapse != min(df$fwk)]

# Now lets define a variable for all dates (ordered)
all_dates = unique(df$fwk) %>% sort()

# If 1 april is not a sunday, we will replace the date to match the previous week starting sunday, so we will fix the broken week
# In earlier years, the previous week is non existent, so we need to create the date. 
for(i in dates_collapse){
  
  exists = as.numeric(all_dates[which(all_dates == i)+1] - all_dates[which(all_dates == i)-1]) == 7
  
  if(exists){df$fwk[df$fwk == i] = all_dates[which(all_dates == i)-1]}else{df$fwk[df$fwk == i] = all_dates[which(all_dates == i)-1]+days(7)}

}

# Now aggregate so the sales with the same date are added
df = aggregate(sales ~ fwk, df, function(x) {sum(x,na.rm=TRUE)})
df$wday = NULL

plot(df,type='l')

# That's enough from me for now. Let's save what we have. I'll handover the data cleaning and exploration work to you in practice.R.
write.csv(df, "data_module2.csv")

