# Let's practice! 

# Ex 1. Generate a sequence of numbers from 1 to 1000 and save to a variable
df = seq(1,1000)

# Plot df in a line chart
plot(df, type='l')

# Compute the log of the 6th highest value. Hint: you could use order() to order descending (or ascending)
log(df[order(-df)][6])

# Subtract 1 from all uneven numbers. Hint: Use modulus %%. 
df[(df %% 2) == 1] = df[(df %% 2) == 1]-1

# Add dates (starting point doesn't matter as long as its a sequence) of the same length as your variable and add them together to make a data frame. 
# Hint: use seq again. "from" doesnt matter, use length.out.
dates = seq(from = as.Date('2001-01-01'), length.out = length(df), by= "week")
df = data.frame("date" = dates, "y" = df)

# Randomly shuffle the observations over the dates. Hint: use sample() on the sequence of rows.
df$y = df$y[sample(seq(1,nrow(df)))]

# take the sqrt over the generated values
df$y = sqrt(df$y)

# Remove all values above 15
df = df[df$y <= 15,]

# Only keep each third value (1-4-7-10-13-etc). Hint: use seq()
df <- df[seq(1, nrow(df), 3),]

# Remove the top 5 values. Hint: Use order(-y)
df <- df[!df$y %in% head(df$y[order(-df$y)],5),]

# Add a random value that takes as value either FALSE or TRUE and add it to the data frame. Can be any function as long as its not based on any other columns. 
df$random = runif(nrow(df),min=0,max=1) <= 0.5

# Check if the values with TRUE are higher than FALSE. Hint: Try using aggregate().
aggregate(y ~ random, data = df, sum)


