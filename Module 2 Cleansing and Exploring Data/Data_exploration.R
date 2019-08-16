library(lubridate)

getwd()
setwd("~/Data science/git/R-Modules/")

df = read.csv("./sales.csv", 
                 sep=",", 
                 as.is = TRUE)

head(df)

df = df[df$channel == "ECOM",]

df = aggregate(formula = sales ~ fwk, 
                  data = df, 
                  FUN = function(x){ sum(x, na.rm = TRUE) 
                    }
                  )

df$fwk = as.Date(df$fwk)
plot(df, type='l')

# Get rid of current week
df = df[df$fwk != floor_date(now(),"week", week_start = 0),]

plot(df, type='l')

# Fix 1 april 
df$wday = weekdays(df$fwk)
dates_collapse = sort(unique(df$fwk[month(df$fwk) == 4 & day(df$fwk) == 1 & df$wday != "zondag"]))
dates_collapse = dates_collapse[dates_collapse != min(df$fwk)]
all_dates = unique(df$fwk)
all_dates = all_dates[order(all_dates)]

for(i in dates_collapse){
  cat("Date",i,"\n")
  df$fwk[df$fwk == i] = all_dates[which(all_dates == i)-1]
}

df = aggregate()

df$wday = NULL

df = aggregate(sales ~ fwk, df, function(x) {sum(x,na.rm=TRUE)})
plot(df,type='l')

# Nice! 



















