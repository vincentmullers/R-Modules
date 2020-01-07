library(lubridate)

# -------------------------------------------------------------------------------------------------- #
# Now we have some data loaded onto our local file system, we can load the data and check it out.    #
# In this tutorial, I will show you some nice ways to format and preprocess data.                    #
# -------------------------------------------------------------------------------------------------- #


# Let's find out what the working directory is 
getwd()

# It's easy to set the working directory to where your file is located, so it's easy to load in. Make sure the file is saved to a folder and replace the below path to point
# to that folder. I placed it in my git folder under R-Modules. 
setwd("C:/Users/vm1040690/Documents/Data science/git/R-Modules/")


# trick for setwd().
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# read in data
df = read.csv("./sales.csv", 
                 sep=",", 
                 as.is = TRUE)

head(df)
str(df)

# We've got quite a lot of data here
nrow(df)

# Let's focus down on Best Buy
df = df[df$channel == "BB",]

# We'll leave zip codes for what they are now, and aggregate sales over fiscal week
df = aggregate(formula = sales ~ fwk, 
                  data = df, 
                  FUN = function(x){ sum(x, na.rm = TRUE) 
                    }
                  )

# Notice I use na.rm=TRUE as there may be NAs in the sales field

# Only look at last 5 years
years = tail(unique(year(df$fwk)),5)
df = df[year(df$fwk) %in% years,]

# Let's convert to dates and plot
df$fwk = as.Date(df$fwk)
plot(df, type='l')

# The last (current) week may not have finished yet, so let's cut it off
df = df[df$fwk != max(df$fwk),]
plot(df, type='l')

# We also need to fix 1 April: fiscal weeks always start on 1 april and may therefore cutoff previous weeks (that's why we see the drops around 1 april) 
# first I want to know the weekdays (if 1 april is starting on sunday then we capture a full week and everything is ok)
df$wday = weekdays(df$fwk)

# Let's capture all April 1st's that do not start on a sunday and therefore need to be fixed 
dates_collapse = sort(unique(df$fwk[month(df$fwk) == 4 & day(df$fwk) == 1 & df$wday != "zondag"]))
dates_collapse = dates_collapse[dates_collapse != min(df$fwk)]

# Now lets define a variable for all dates (ordered)
all_dates = unique(df$fwk)
all_dates = all_dates[order(all_dates)]

# If 1 april is not a sunday, we will replace the date to match the previous week starting sunday, so we will fix the broken week
# In earlier years, the previous week is non existent, so we need to create the date. 
for(i in dates_collapse){
  exists = as.numeric(all_dates[which(all_dates == i)+1] - all_dates[which(all_dates == i)+1]) == 7
  
  if(exists){df$fwk[df$fwk == i] = all_dates[which(all_dates == i)-1]}else{df$fwk[df$fwk == i] = all_dates[which(all_dates == i)-1]+days(7)}
}

# Now aggregate so the sales with the same date are added
df = aggregate(sales ~ fwk, df, function(x) {sum(x,na.rm=TRUE)})
df$wday = NULL

plot(df,type='l')
# That fixed most except for 2016 one.. not sure what happened there.. 

# That's enough from me for now. Let's save what we have. I'll handover the data cleaning and exploration work to you in practice.R.
write.csv(df, "sales_m2.csv")
