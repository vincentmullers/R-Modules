# Let's practice! 

## NWH - Sometime console would freeze as I suck and would need to reset
## session > Restart R

## NWH - Creating seperate objects throughout the exercise in order to track changes
# Generate a sequence of numbers from 1 to 1000 and save to a variable called df. Hint: Use seq().

?seq
df = seq(from = 1, to = 1000)
1:1000

# NWH - random number generator 

dfrandom = runif(1000, min = 1, max = 1000)
plot(dfrandom)

# NWH - Exploring data frame

summary(df)
str(df)
head(df)
tail(df)
View(df)

# Plot df in a line chart. Use plot().

?plot
plot(df[1:5],
     # type = "l",
     lty = "dashed",
     col = "chocolate")

# Compute and print the log of the 6th highest value. Hint: you could use order() to order a variable.

?sort
sort(df, decreasing = TRUE)
value = sort(df,TRUE)[6]
print(value)
log(value)

?nth
?order
order(df)
df[995]
log(df[995])

# NWH - What is the difference between sort and order

# Subtract 1 from all odd numbers. Hint: Use modulus %% to find uneven numbers. 

oddminus1 = df[df %% 2 == 1] - 1
print(oddminus1)

df[df %% 2 == 1] = df[df %% 2 == 1] - 1

# NWH - Even Numbers

evenminus1 = df[df %% 2 == 0]-1
print(evenminus1)

# Add dates (starting point doesn't matter as long as it's a sequence) of the same length as your variable and add them together to make a data frame. 
# Hint: use seq again. "from" doesnt matter, use "length.out".

dates = as.Date("2010-01-01") + 1:1000
dates

df1 = data.frame("date" = dates, "y" = df)
head(df1)

colnames(df1) <- c("dates_new", "y_new")

## NWH - did not use sequence

# Take the sqrt of the values in your data frame (overwrite the original values). 

?transform
df2 = transform(df1, df=sqrt(df))
head(df2)

## NWH - ^^ creating seperate object on purpose

# Remove all values above 15 from the data frame.

df3 = df2[df2$df <= 15,]
df3

# Only keep each third row (1-4-7-10-13-etc) in your data frame. Hint: use seq().

df4 = df3[seq(1, nrow(df3),3),]
View(df4)
head(df4)

## NWH -- reset index

row.names(df4) <- NULL
head(df4)

# Remove the top 5 values in your data frame. Hint: Use order(y).

order(df4$df)
df4
nrow(df4)
df5 = df4[ -c(75:71),]
df5
nrow(df5)

# NWH ^^ This does not seem like the most efficient way to do this...

# Randomly shuffle the observations over the dates. Hint: use sample() and get just as many sampled values as the numbers of rows in your data set.

df6 = df5[sample(nrow(df5)),]
head(df5)
head(df6)

## NWH ^^ Not sure if I am doing this right...?

# Plot again. 

plot(df6,
     type = "l",
     lty = "solid",
     col = "chocolate")

plot(df6)

# Add a column "category" to df that equals "one" if the value column is within the top 30% quantile, and "two" otherwise. Hint: use ifelse().

quant = quantile(df6$df, probs = 0.7)
quant
category = ifelse (df6$df >= quant, 1, 2)
category

df6$category = category


## NWH - Checking if I did it right... should have 21 values in top 30% quantile

sum(category[which(category==1)])

df7 = data.frame(df6$dates, df6$df, category)
df7
head(df7)

## NWH - getting some weird column names.... so I will rename them

names(df7)[1] = "Date"
names(df7)[2] = "Value"
names(df7)[3] = "Category"

head(df7)

colnames(df7) <- c("1","2","3")
data.table::setnames(old = "1", new = "6")


# Check if the sum of the values in category "one" are larger than in category "two". Try using aggregate().

?aggregate
aggregate(Value ~ Category, df7, FUN=sum) 

## Who will do the next module?

sample (c("Maarten","Dave","Martin","Eric"), size = 1)

## Maarten is assigned module 1        
