getwd()
setwd("~/Data science/git/R-Modules/")

sales = read.csv("./sales.csv", 
                 sep=",", 
                 as.is = TRUE)

head(sales)

sales = aggregate(formula = sales ~ fwk, 
                  data = sales, 
                  FUN = function(x){ sum(x, na.rm = TRUE) 
                    }
                  )

sales$fwk = as.Date(sales$fwk)
plot(sales, type='l')
