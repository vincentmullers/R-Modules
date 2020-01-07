# Use install.packages("dplyr") if you have not installed the package yet. Then load it in using library(dplyr)
library(dplyr)

# Let's first quickly build a data set that we want to work with. 
# I am creating a data frame with one column called animal that includes a randomly sampled name of one of four animals. 
# First I am setting a seed, such that we get the same results (random sample is based on same seed).
set.seed(1000)

df = data.frame("animal" = sample(c("cat","dog","giraffe","elephant"), 100, replace = TRUE))

# dplyr uses so called piping (%>%) that allows us to move the results of one function into the next row. With mutate we can introduce a new variable. 
# Suppose we want a variable called "pet" that equals TRUE if the animal is a cat or dog, and FALSE if the animal is a giraffe or elephant. 
# With "mutate" we can add a variable as a column to a data frame. 
df = df %>% 
     mutate(pet = case_when(animal %in% c("cat","dog") ~ TRUE,
                            animal %in% c("giraffe","elephant") ~ FALSE
     ))

head(df)

# I am using case_when to specify when we want pet to be TRUE and when FALSE. Note in this case, we could do this too:
df = df %>% 
     mutate(pet = case_when(animal %in% c("cat","dog") ~ TRUE,
                            TRUE ~ FALSE
     ))

# The above is saying, if animal is equal to cat or dog, pet should be TRUE, and in all other cases (TRUE) pet should be equal to FALSE. 
head(df)

# Now let's say we want to add weight of the particular animal. I will use a distributions for each animal that I sample from to get a weight.
set.seed(1000)

df = df %>%
     mutate(weight_kg = case_when(animal == "dog" ~ rnorm(n = 100, mean = 30, sd = 5),
                                  animal == "cat" ~ rnorm(n = 100, mean = 15, sd = 2),
                                  animal == "giraffe" ~ rnorm(n = 100, mean = 900, sd = 90),
                                  animal == "elephant" ~ rnorm(n = 100, mean = 4000, sd = 1000)
                                  ))

head(df)

# Let's arrange our data frame based on animal and weight (heaviest animals by animal first). Note we need to add desc() sign to weight_kg. 
df = df %>%
     arrange(animal,desc(weight_kg))

# Let's say we want to filter on animals that are heavier than 15 kg
any(df$weight_kg < 15)

df = df %>%
     filter(weight_kg > 15)

# We know how to add a column with mutate. Removing a column is also very easy. For this we use select. 
# I am not overwriting df as we want to keep all columns. 
select(df, c(animal,pet))
select(df, -animal) # all but animal

# Let's change the kg to pounds. 
df = df %>%
     mutate(weight_kg = weight_kg * 2.2)

# we have the wrong column name now, still saying kg. Let's change colnames to say weight_lbs.
df = rename(df,  weight_lbs = weight_kg)

head(df)

# Finally, let's summarize the data. First we want to group by animal and then calculate the mean of weight. I am also including the number of rows for each animal.
df = df %>%
     group_by(animal,pet) %>% 
     summarize(
       n = n(),
       mean = mean(weight_lbs)
     )

# Note that we've used a lot of lines above to code everything we wanted to. Using %>% we could however add this all together. Remember the result of a function
# gets moved into the next function when we use %>%.
# Let's first remove df.
rm(df)

# Now let's recreate df using dplyr's %>%.
set.seed(1000)

df = data.frame("animal" = sample(c("cat","dog","giraffe","elephant"), 100, replace = TRUE)) %>%
  mutate(pet = case_when(animal %in% c("cat","dog") ~ TRUE,
                         animal %in% c("giraffe","elephant") ~ FALSE
  )) %>%
  mutate(weight_kg = case_when(animal == "dog" ~ rnorm(n = 100, mean = 30, sd = 5),
                               animal == "cat" ~ rnorm(n = 100, mean = 15, sd = 2),
                               animal == "giraffe" ~ rnorm(n = 100, mean = 900, sd = 90),
                               animal == "elephant" ~ rnorm(n = 100, mean = 4000, sd = 1000)
  )) %>%
  arrange(animal,desc(weight_kg)) %>%
  filter(weight_kg > 15) %>%
  mutate(weight_kg = weight_kg * 2.2) %>%
  rename(weight_lbs = weight_kg) %>%
  group_by(animal,pet) %>% 
  summarize(
    n = n(),
    mean = mean(weight_lbs)
  )

df
