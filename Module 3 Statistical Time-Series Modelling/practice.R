# In the tutorial you have seen there's quite some parameters that need to be provided to the prophet model.
# Each data set requires its own specific set of parameters (hyperparameters) to function optimally. 
# Finding optimal hyperparameters often means trying out different settings and evaluating performance. We'll be looking at some hyperparameters and try to tune them
# and see if we can improve performance. 

# 1. Strip the data from the last 52 weeks and assign the result to a new variable called df_train.



# 2. Set up the same prophet model as in the tutorial, but now train the model on df_train. 



# 3. Now run the model on df (create predictions column for df).



# 4. Compute accuracy on the last 52 weeks of df by computing this error metric: "Mean Absolute Error" (MAE) on actual sales vs forecast from the earlier defined model.



# 5. Let's see if we could improve this error metric by adjusting one of the hyperparameters of the prophet model. Choose either changepoint.prior.scale or changepoint.range 
# and see if different values for these hyperparameters improve the model (improve the MAE). Try at least 3 values. 



# 6. Conclude whether you have been able to tune the model parameter to improve performance. 






