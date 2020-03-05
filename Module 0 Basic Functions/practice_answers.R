library(dplyr)
# Let's practice! 

# Ex 1. Generate a sequence of numbers from 1 to 1000 and save to a variable.
df = seq(1,1000)
df = 1:1000

# Plot df in a line chart.
plot(df, type='l')

# Compute the log of the 6th highest value. Hint: you could use order() to order a variable.
log(df[order(-df)][6])

sort(df, decreasing = TRUE)[[6]] %>% log()

df %>% sort(decreasing = TRUE) %>% .[[6]] %>% log()


# Subtract 1 from all odd numbers. Hint: Use modulus %%. 
for(i in seq_along(df)){
  
  if(df[i] %% 2 == 1){df[i] = df[i] -1}
  
}

df[(df %% 2) == 1] = df[(df %% 2) == 1]-1

df = ifelse(df %% 2 == 1, df - 1, df)

df = sapply(df, function(x) ifelse(x %% 2 == 1, x - 1, x))


# Add dates (starting point doesn't matter as long as it's a sequence) of the same length as your variable and add them together to make a data frame. 
# Hint: use seq again. "from" doesnt matter, use length.out.
dates = seq(from = as.Date('2001-01-01'), length.out = length(df), by= "week")
df = data.frame("date" = dates, "y" = df)

df = data.frame("date" = seq(from = as.Date('2001-01-01'), length.out = length(df), by= "week"),
                "y" = df)


df = data.frame("y" = df) %>%
     dplyr::mutate('date' = seq(from = as.Date('2001-01-01'), length.out = length(.$y), by= "week"))


# take the sqrt of the generated values.
df$y = sqrt(df$y)

df = df %>% 
     dplyr::mutate(y = sqrt(y))

df$y %$% sqrt()


# Remove all values above 15.
df = df[df$y <= 15,]

df = df %>%
     dplyr::filter(y <= 15) 

df = df %>%
     dplyr::filter(!y > 15)



# Only keep each third row (1-4-7-10-13-etc). Hint: use seq().
df = df[seq(1, nrow(df), 3),]


# Remove the top 5 values. Hint: Use order(-value)
df = df[!df$y %in% head(df$y[order(-df$y)],5),]

df = df[!df$y %in% df$y %>% sort(decreasing = TRUE) %>% .[1:5],]

df = df %>%
     dplyr::arrange(-y) %>%
     slice(-c(1:5))


# Print how many values of y are bigger than 10.
length(df$y[df$y > 10])

df %>% dplyr::filter(y > 10) %>% nrow()


# Randomly shuffle the observations over the dates. Hint: use sample() on the sequence of rows.
df$y = df$y[sample(seq_along(df$date))]
df$y = df$y[sample(1:nrow(df))]

df %>% plot(type='l', ylim = c(0,20))


# Add a column "category" to df that equals "one" if the value column is within the top 30% quantile, and "two" otherwise. Hint: use ifelse().
df$category = case_when(df$y >= quantile(df$y, 0.7) ~ "one",
                        TRUE ~ "two")

df$category = ifelse(df$y >= quantile(df$y, 0.7), "one", "two")



# Check if the sum of the values in category "one" are larger than in category "two". Try using aggregate().
aggregate(y ~ category, data = df, FUN = sum)





