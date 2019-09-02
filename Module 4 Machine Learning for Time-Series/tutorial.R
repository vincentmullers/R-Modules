setwd("C:/Users/vm1040690/Documents/Data science/git/R-Modules/")

library(lubridate)
library(data.table)
library(xgboost)
library(data.table)
library(dplyr)
library(plyr)

# Read in the data 
df = read.csv("./df_m2.csv",sep=",", row.names= "X")
df$week = as.Date(df$week)
df = df[df$week != max(df$week),]

# Let's set up a so-called Xtreme Gradient Boosting model. This model is a tree based model. It combines "weak" learners (simple decision trees) to create one "strong" learner. 
# It fits trees sequentially on the error of the previous model. So it keeps training trees on the unexplained part of the model (this is called boosting). 
# As we keep training this model, the error will keep going down, but we need to make sure it is not OVERFITTING. This means we are fitting the model too closely on 
# Noise in the training set. We need to make sure there is some GENERALIZATION such that that model performs well out-of-sample. 

# This is a non-parametric ML model, which means it does not know we're dealing with a time-series data set. It will try to predict a continuous variable based on the inputs we give it,
# Like month, week, year, and possibly other regressors. 
# Let's first train a model on just date variables week month and year. This model also expects its inputs in a certain structure.
x_trn = as.matrix(df[!colnames(df) %in% c("sales","week")]); y_trn = as.matrix(df$sales)
dtrain = xgb.DMatrix(data = x_trn, label = y_trn)  
dtrain

model <- xgboost(data = dtrain, nrounds = 30, eta=0.1, verbose=1, lambda=0.05, alpha=0.05, min_child_weight=1)
# as we've indicated verbose =1, it shows the root mean squared error after each boosting iteration

# Let's see how the model looks like
# All 30 trees
xgb.plot.tree(model = model)

# Plotting the first of 30 trees
xgb.plot.tree(model = model, tree = 1)

# The model runs through all trees and adds the results
xgb.plot.tree(model = model, tree = 29)

# Predict
preds_past = predict(model, x_trn)

plot(df$sales,type='l')
lines(preds_past,col="blue")

# First year looks a little different and we have this dip. We don't want the model to create a tree split for this. 
# It would be good to give this model some weights, as with time-series most recent data is in most cases most relevant. 
weightsData <- rev(0.98^(1:nrow(x_trn)))

dtrain = xgb.DMatrix(data = x_trn, label = y_trn, weight = weightsData)  
model <- xgboost(data = dtrain, nrounds = 30, eta = 0.1, verbose = 0, lambda = 0.05, alpha = 0.05, min_child_weight = 1)

# You'll see the model parameters (so-called hyperparameters) only govern how the algorithm learns, but does not impose any structure on the model. 
model$params

# nrounds = 30 means 30 boosting iterations, we will fit a tree and then boost 29 by fitting a new tree to the residuals of the previous model 
preds_past = predict(model, x_trn)
plot(df$sales,type='l')
lines(preds_past,col="blue")

# Nice! it doesnt care anymore about the lack of fit at the outlier, cause the weight given to this observation is small. It now concentrates on a tight fit in the last years. 
# How does this model do out of sample? Let's see. 
# first set up future data frame (same way as last module) until CY end 2020
cal_w = seq(as.Date(paste("2001","-01-01",sep="")),as.Date(paste("2001","-12-24",sep="")),by="week")
cal_w = gsub("2001",min(year(df$week)),cal_w)
cal_w = lapply(0:(length(unique(year(df$week)))),function(x) {gsub(min(unique(year(df$week))),unique(year(cal_w))+x,cal_w)})
cal_w = data.frame("week" = unlist(cal_w), "number" = rep(1:52,length(unique(year(df$week)))+1))
cal_w$week = as.Date(cal_w$week)

future = join(cal_w, df[,c("week","sales")],by = "week",type='left')
future = future %>%
              mutate("month" = month(week)) %>%
              mutate("year" = year(week))

x_total = as.matrix(future[!colnames(future) %in% c("sales","week")])

future$preds = predict(model, x_total)
plot(future[c("week","sales")], type='l')
lines(future[,c("week","preds")], col="blue")

# Notice there's no trend in this model. We see not splits for years we haven't seen yet. This model assumes stationarity!
# Conclusion: Tree models do not extrapolate (prediction outside the ranges where training took place)
# There's solutions like this, like detrending / making stationary / modelling on differences / residuals, but we won't explore that now.  


# Let's look at how we can test how accurate a model is!
# We want to know out of sample accuracy so let's set up a "validation" set, which makes up the last year. 
val = df[df$week >= max(df$week) %m-% months(12),]
train = df[!df$week %in% val$week,]

x_trn = as.matrix(train[!colnames(train) %in% c("sales","week")]); y_trn = as.matrix(train$sales)
x_val = as.matrix(val[!colnames(val) %in% c("sales","week")]); y_val = as.matrix(val$sales)

dtrain = xgb.DMatrix(data = x_trn, label = y_trn)  
dval = xgb.DMatrix(data = x_val, label = y_val) 

# Giving a more extensive example of which hyperparameters you can set
# We train the model on training set, and validate based on the last year that is split out in data frame val
model <- xgb.train(data = dtrain, 
                   watchlist = list(train=dtrain, validation=dval),  
                   verbose = 1, 
                   nrounds = 20, 
                   eval.metric = "mae", 
                   early_stopping_rounds = 10, 
                   params = list("alpha" = 200,
                                 "lambda"= 0.65, 
                                 "eta" = 0.4, 
                                 "min_child_weight" = 2, 
                                 "gamma" = 1,
                                 "max_depth" = 20,
                                 "subsample" = 1))

# To prevent overfitting, I added "early_stopping_rounds" which is telling the algorithm to stop boosting when we do not see improvements in the validation set.
# So instead of 20 rounds, it made only 8, as it couldnt make anymore improvements to the validation error in the next 10 rounds.
# Let's plot predictions
df$preds = predict(model, rbind(x_trn,x_val))
plot(df[c("week","sales")],type='l')
lines(df[c("week","preds")],col='blue')

# error rate? let's look at mean average error
error = mean(abs(df$sales - df$preds)[df$week %in% val$week])
error 

# This will be the same as the model is fit on
model$best_score

# This seems quite high but we're really far off during Amazon Prime. What if we remove that obs?
error = mean(abs(df$sales - df$preds)[df$week %in% val$week & df$week != "2018-11-19"])
error

# what is this as a percentage?
error / mean(df$sales[df$week %in% val$week])

# We're still 8% off on average. Really depends on the data whether to see if this is a lot or not. In this case there's quite a lot of noise we just can't explain.
# Move on to practice.R! 