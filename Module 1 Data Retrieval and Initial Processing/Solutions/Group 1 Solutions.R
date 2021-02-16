library(RODBC) 
library(odbc) 
library(stringr) 
library(dplyr)

con <- odbcConnect("HANA")
attributes(con)
odbcGetInfo(con)


## Retrieve Data
sell_thru = sqlQuery(con, "SELECT sales_org, postal_cd, sold_to_desc, fiscal_week_begin, net_management_sales_usd 
                           FROM _SYS_BIC.\"BOSE.MPE_SALES/MPE_CAV_SALES_SALESACTUALS_SELLTHROUGH\" where SALES_ORG='US10'")

sell_in = sqlQuery(con, "SELECT net_mangement_sales_usd, postal_cd, sales_org, sales_off, fiscal_week_begin 
                         FROM _SYS_BIC.\"BOSE.MPE_SALES/MPE_CAV_SALES_DIRECT_SELLIN\" where SALES_ORG ='US10' AND sales_off IN ('4003','4010')") 


# Check out sell_thru (do not open sell_thru df entirely - R will crash)
head(sell_thru)

## EX 1. Some postal codes have more than 5 characters. Show the different number of characters that the postal_cd field is made out of.     
sell_thru$POSTAL_CD2 = str_length(sell_thru$POSTAL_CD)
unique(sell_thru$POSTAL_CD2)


# Vincent
# unique(nchar(as.character(sell_thru$POSTAL_CD)))


## EX 2. Clean up the POSTAL_CD field to always consist of the first 5 characters. Hint: Use substr()
sell_thru$POSTAL_CD3 = substr(sell_thru$POSTAL_CD,1,5)

# Vincent
# sell_thru$POSTAL_CD = substr(sell_thru$POSTAL_CD,1,5)

sell_thru$POSTAL_CD4 = str_length(sell_thru$POSTAL_CD3)
unique(sell_thru$POSTAL_CD4)
nrow(sell_thru)

# Vincent
# unique(nchar(as.character(sell_thru$POSTAL_CD)))


## EX 3. Now exclude the zips with length 0 
sell_thru1 = subset(sell_thru,sell_thru$POSTAL_CD4 != 0)


# unique(nchar(as.character(sell_thru1$POSTAL_CD3)))

# Vincent
# sell_thru = sell_thru[!(sell_thru$POSTAL_CD == ""),] # now POSTAL_CD4
# sell_thru = sell_thru[!nchar(as.character(sell_thru$POSTAL_CD)) == 0,] # or > 0
# sell_thru = sell_thru %>%
#             dplyr::filter(!nchar(as.character(POSTAL_CD)) == 0)


nrow(sell_thru1)

# We want all zips to be of length 5. Here we use padding to add trailing 0's to zip codes of length < 5.
# Padding zips w/ trailing 0's

sell_thru1$POSTAL_CDF = str_pad(sell_thru1$POSTAL_CD3, 5, pad="0")

# Vincent: sell_thru$POSTAL_CD = str_pad(sell_thru$POSTAL_CD, 5, pad="0")

head(sell_thru1)

sell_thru1$POSTAL_CD6 = str_length(sell_thru1$POSTAL_CDF)
unique(sell_thru1$POSTAL_CD6)

# Vincent:
# unique(nchar(as.character(sell_thru$POSTAL_CD)))



# EX 4. SOLD_TO_DESC includes all resellers. Transform the field to split out "BB", transform any other values to "RSL". 
# (Hint: use ifelse() or case_when() on the SOLD_TO_DESC field).
sell_thru1$SOLD_TO_DESC2 = ifelse(sell_thru1$SOLD_TO_DESC == "Best Buy Stores","BB","RSL")
sell_thru1$SOLD_TO_DESC3 = ifelse(sell_thru1$SOLD_TO_DESC2 == "BB","BB","RSL")


# Vincent
# unique(sell_thru$SOLD_TO_DESC)
# sell_thru$SOLD_TO_DESC[is.na(sell_thru$SOLD_TO_DESC)] = "RSL"
# sell_thru$SOLD_TO_DESC = ifelse(sell_thru$SOLD_TO_DESC == "Best Buy Stores","BB","RSL")

# sell_thru = sell_thru %>%
#             dplyr::mutate("SOLD_TO_DESC" = replace(SOLD_TO_DESC, is.na(SOLD_TO_DESC), "RSL")) %>%
#             dplyr::mutate("SOLD_TO_DESC" = ifelse(SOLD_TO_DESC == "Best Buy Stores", "BB","RSL"))
              
# sell_thru = sell_thru %>%
#             dplyr::mutate("SOLD_TO_DESC" = case_when(SOLD_TO_DESC == "Best Buy Stores" ~ "BB",
#                                                      TRUE ~ "RSL"))


head(sell_thru1)
unique(sell_thru1$SOLD_TO_DESC2)





# EX 5. check out sell_in .
head(sell_in)

# EX 6. Use same procedure as above for sell-thru to clean up zip codes.
sell_in$POSTAL_CD2 = substr(sell_in$POSTAL_CD,1,5)
sell_in$POSTAL_CD3 = str_length(sell_in$POSTAL_CD2)

sell_in1 = subset(sell_in,sell_in$POSTAL_CD3 != 0)
sell_in1$POSTAL_CDF = str_pad(sell_in1$POSTAL_CD2, 5, pad="0")

head(sell_in1)

sell_in1$POSTAL_CD5 = str_length(sell_in1$POSTAL_CDF)

unique(sell_in1$POSTAL_CD5)


# ===== Now we want to join the two data sets ===== # 
# EX 7. Make sure the sell-in data frame has a column "channel" that indicates which channel the results apply to.
sell_in1$CHANNEL = ifelse(sell_in1$SALES_OFF == "4003","Retail","ECommerce")


# EX 8. Strip column SALES_OFF as we do not need it anymore now we have channel .
sell_in1$SALES_OFF = NULL
sell_in1$POSTAL_CD = NULL
sell_in1$POSTAL_CD2 = NULL
sell_in1$POSTAL_CD3 = NULL
sell_in1$POSTAL_CD5 = NULL

sell_thru1$POSTAL_CD = NULL
sell_thru1$POSTAL_CD2 = NULL
sell_thru1$POSTAL_CD3 = NULL
sell_thru1$POSTAL_CD4 = NULL
sell_thru1$POSTAL_CD6 = NULL
sell_thru1$SOLD_TO_DESC3 = NULL
sell_thru1$SOLD_TO_DESC = NULL


# Vincent:
# sell_thru[c("SALES_OFF","POSTAL_CD")] = NULL
# sell_thru = sell_thru %>% 
#             dplyr::select(-c(SALES_OFF,...))



# EX 9. Make sure both data frames have the same column names. Hint: use colnames().
head(sell_in1)
head(sell_thru1)
sell_thru1$CHANNEL = NA
sell_in1$SOLD_TO_DESC2 = NA


# Vincent:
# colnames(sell_in)[!colnames(sell_in) %in% colnames(sell_thru1)]


names(sell_in1)[names(sell_in1) == "NET_MANGEMENT_SALES_USD"] <- "NET_MANAGEMENT_SALES_USD"
names(sell_in1)
names(sell_thru1)


## Check if colnames are the same 
all(colnames(sell_in1) %in% colnames(sell_thru1))
all(colnames(sell_thru1) %in% colnames(sell_in1))

identical(names(sell_in1),names(sell_thru1))

## Needs to be in same order for identical to work
identical(names(sell_in1)[order(names(sell_in1))], names(sell_thru1)[order(names(sell_thru1))])

# EX 10. Join the two dataframes by using rbind() ("rowbind").
merged <- rbind(sell_in1, sell_thru1)

# Vincent:
# nrow(sales) == nrow(sell_in) + nrow(sell_thru)

# EX 11. Write the results to a local csv file. Hint: use write.csv().
# write.csv(merged, "./data.csv")




