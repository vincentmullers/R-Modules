## This panel is the Script panel. Everything we execture from here will be send to the console below and executed. 
## You can execute from the terminal too, but the script allows us to neatly organize code.  
## Execute code line by line by pressing contr + enter. This will skip comment lines (starting with # - don't want to run these). 

# R has a variety of ready to use data sets build in. Let's load one of them, called USArrests. 
data("USArrests")

# This data is now assigned to the variable USArrests.
USArrests

# Note in the environment panel. there's a varable called USArrests. Open it to see it in a new tab.
# Let's check out what kind of structure this data is in. 
str(USArrests)

# Note we are dealing with a data frame with 4 variables. The state is not one of them, this is captured in the rownames. 
rownames(USArrests)

# For some functions we need to provide more than 1 argument. In case yo.u are not sure which one's need to be supplied,
# run ? before the function to get some help (see help pane down right).
?head

# In this case we need to add an "n" parameter that tells the function how many rows to print. Let's check out the top 5 rows of USArrests.
head(USArrests, n = 5)

# We want to be working with the rows and columns of this data set. Let's first see how we can access a certain column.
# There's several ways of doing this: Using "$" and Using "[]". 
USArrests$Murder
USArrests["Murder"]

# Note that the first method takes only the values and therefore the data structure changes to a numeric vector. The second method leaves the 
# initial data structure intact, and we are left with a data frame with 1 column. 
str(USArrests$Murder)
str(USArrests["Murder"])

# The states are not one of the variables, but instead saved as row names. We would like to have the states in a separate variable in the 
# data frame. Let's define a column called "State".
USArrests$State = rownames(USArrests)
head(USArrests)

# We can get rid of the rownames as follows
rownames(USArrests) = NULL
head(USArrests)

# In the same way we can get rid of a column
USArrests$Assault = NULL

# Next we want to grab certain rows. Suppose we only want to show the 5th row. R starts indexing at 1 so you get the 5th row by typing 5.  
USArrests[5,]

# Note we added a "," in between the brackets. The left side of the "," indicates which rows we want, and the right side indicates which columns we want.
# In case we do not specify column names, we get all columns for the 5th row. 
# If we only want the 5th row of the "State" column, try the following.
USArrests[5, "State"]

# Let's try some filtering on rows. We can use the "==" sign to test if a value in a certain column of a data frame is equal to a specified string. 
# We know "California" is one of the values in the "State" column. Let's see what the "==" tells us. 
USArrests$State == "California"

# It gives us a binary vector telling us for each row in the State column if it's equal to "California". We can use this binary vector to do filtering
# on rows. Filtering on the rows where State == "California".
USArrests[USArrests$State == "California",]

# The binary vector tells us which rows to take (the one's that are TRUE). As I've not indicated any columns, the function returns all columns. 
# Now let's do the same for columns.
colnames(USArrests)
colnames(USArrests) == "State"

# This gives us for each column name, whether it's equal to "State". If it's TRUE, we want to keep the column. 
USArrests[,colnames(USArrests) == "State"]

# There's easier ways to do the above, but it's helpful in learning how to filter on columns and rows. 
# Similarly we can filter based on more than 1 condition at the same time. Let's filter on the rows where Murder > 5 AND UrbanPop > 70
USArrests[USArrests$Murder > 5 & USArrests$UrbanPop > 70,]

# Filtering based on an "or" condition can be done using "|".
USArrests[USArrests$Murder > 10 | USArrests$UrbanPop > 90,]

# Filtering on every row except where State equals "California"? Add a ! to change signs in the binary TRUE/FALSE vector. 
USArrests[USArrests$State != "California",]

# State is either California or Florida?
USArrests[USArrests$State == "California" | USArrests$State == "Florida",]

# Doing to above can be cumbersone with many states (OR conditions). We can use %in% to make this easier. 
USArrests[USArrests$State %in% c("California","Florida"),]

# In many cases, we do not want to hard-code the threshold numbers as done above. Maybe we want to pick the states that are in the top 10% murder rates.
# For that we would need a quantile function.
?quantile

# Let's save the top 10% quantile to a variable and use it to filter on the right rows. 
quant = quantile(USArrests$Murder, probs = 0.9)
quant
USArrests[USArrests$Murder >= quant,]

# If we want to continue with this selection, we need to overwrite the existing data set as follows.
USArrests = USArrests[USArrests$Murder >= quant,]
USArrests

# Finally, let's order the data set along Murder
USArrests = USArrests[order(USArrests$Murder, decreasing = TRUE),]
USArrests


## Let's load in another data set and try some other useful functions. 
data("iris")
iris

# In the iris data set we have multiple observations by species. In this case we could quite easily check which unique species we have in our data.
# If we had a much larger data set, this would be a tedious task. We can use the unique() function to check this quickly. 
unique(iris$Species)

# Some other questions about the data set are answered in the below section and some new functions are introduced.

# Is there a "setosa" flower that has sepal.length bigger than 6.5?
any(iris$Sepal.Length[iris$Species == "setosa"] > 5.5) # the any function is TRUE if there is any TRUE value in the binary vector created. 

# How many? 2 ways to check are shown below. 
length(iris$Species[iris$Sepal.Length > 5.5 & iris$Species == "setosa"])
nrow(iris[iris$Sepal.Length > 5.5 & iris$Species == "setosa",])

# Are there any duplicates in the data? (two plants with same properies)
iris[duplicated(iris),]

# Which rows are duplicates?
which(duplicated(iris))
which(duplicated(iris, fromLast = TRUE))

iris[c(which(duplicated(iris)),which(duplicated(iris, fromLast = TRUE))),] # combining above two indices into a column using "c"

# What is the mean petal length for versicolor flowers?
mean(iris$Petal.Length[iris$Species == "versicolor"])

# What is the mean petal length by species?
aggregate(Petal.Width ~ Species, data = iris, FUN = mean) # the left side of the "~" indicates the variables we want to aggregate, the right side indicates by what varables. IF more than 1, add a "+" sign in between varable names.  

# What is the mean of all numeric columns by species?
aggregate(. ~ Species, data = iris, FUN = mean) # the "." means all columns except columns indicated right of the "~"

## Finally, let's look at using loops. We'll check out the "for" loop and the "while" loop. 
# Let's say we want to take several actions for each of the species. This could be handled by a for loop. 
# Suppose we want to remove the flower with the lowest petal.length for each flower type.
# first let's see what the lowest petal.lengths are by flower type:
aggregate(Petal.Length ~ Species, data = iris, min)
nrow(iris)

# now remove the smallest by species:
for(i in unique(iris$Species)){
  
  # We execute the following for each unique species in the iris data set. "i" will loop over the unique values of species.
  # Let's define which row we want to remove.
  rm = which(iris$Species == i & iris$Petal.Length == min(iris$Petal.Length[iris$Species == i]))
  
  # remove the row from the iris data frame
  iris = iris[-rm,]            

}

# Let's see what the shorted petal.lengths are by species. Note they are higher now as we removed the smaller one's. 
aggregate(Petal.Length ~ Species, data = iris, min)
nrow(iris) # We've removed 3 rows. One for each species. 


## One other loop is the "while" loop. 
# Let's say we want to keep removing the lowest petal.lengths until the total petal.length of all virginica flowers is less than 150. 
current_total = sum(iris$Petal.Length[iris$Species == "virginica"])

# we have 49 observations for the Virginica flower left
nrow(iris[iris$Species == "virginica",]) 

# let's define the while loop:
while(sum(iris$Petal.Length[iris$Species == "virginica"]) >= 150){
  
  # Removing the smallest petal length flower from the virginica species. 
  rm = which(iris$Species == "virginica" & iris$Petal.Length == min(iris$Petal.Length[iris$Species == "virginica"]))
  
  # remove the row from the iris data frame
  iris = iris[-rm,]            
  
}

# We are now left with 25 flowers with the highest petal width
nrow(iris[iris$Species == "virginica",]) 
sum(iris$Petal.Length[iris$Species == "virginica"]) # note that the while loop stopped because the sum of petal lengths dropped below 150. 

# This is the end :) Move on to the practice module!
