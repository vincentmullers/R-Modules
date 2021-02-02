# Let's practice! 

# Generate a sequence of numbers from 1 to 1000 and save to a variable called df. Hint: Use seq().
df <- seq(1:1000)
seq(1:1000) -> "df"

# Plot df in a line chart. Use plot().
plot(df)

# Compute and print the log of the 6th highest value. Hint: you could use order() to order a variable.
log(order(df, decreasing=TRUE) [6])
# [1] 6.902743

# Subtract 1 from all uneven numbers. Hint: Use modulus %% to find uneven numbers. 
# what exactly does %% do/mean?

# A
is.odd <- seq(1,1000,by=2)
on <- is.odd - 1
for (df in 1:1000) {
  if (df %% 2 ==1) print(df-1)
}


# B
is.odd <- seq(1,1000, by=2)
on <- is.odd - 1
on <- data.frame(is.odd -1)

for (df in 1:1000) {
  if (df %% 2 == 1) print(df-1)
}


# Add dates (starting point doesn't matter as long as it's a sequence) of the same length as your variable and add them together to make a data frame. 
# Hint: use seq again. "from" doesnt matter, use "length.out".
dates <- data.frame(seq(as.Date('2000/1/1'), by = 'day', length.out = 500))
ALL <- cbind(is.odd, dates)


# Take the sqrt of the values in your data frame (overwrite the original values). 
ALL$square_root = '^'(ALL$is.odd,1/2)
ALL = subset(ALL,select = -c(is.odd))

# Remove all values above 15 from the data frame.
ALL <- data.frame(ALL[!rowSums(ALL[-1] >15),])


# Only keep each third row (1-4-7-10-13-etc) in your data frame. Hint: use seq().
ALL = ALL[seq(1, nrow(ALL), 3),]


# Remove the top 5 values in your data frame. Hint: Use order(y).
ALL <- ALL[order(ALL[, 2], decreasing = TRUE),]
ALL = ALL[-1:-5,]

# OR 
ALL <- ALL[-c(1:5),]

# Randomly shuffle the observations over the dates. Hint: use sample() and get just as many sampled values as the numbers of rows in your data set.
#Is this correct? They look shuffled but didn't use sample function, and don't know what it means when it says "shuffle observations over the dates"
ALL[] <- lapply(ALL, sample)


# Plot again. 
plot(ALL)

# Add a column "category" to df that equals "one" if the value column is within the top 30% quantile, and "two" otherwise. Hint: use ifelse().
ALL$category <- ifelse(ALL$square_root >= (quantile(ALL$square_root, probs = (.7))), 'one', 'two')


# Check if the sum of the values in category "one" are larger than in category "two". Try using aggregate().
aggregate(ALL$square_root, by=list(category=ALL$category),FUN=sum)
# category        x
# 1      one 128.6664
# 2      two 176.3850
