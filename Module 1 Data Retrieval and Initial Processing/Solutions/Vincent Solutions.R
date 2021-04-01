library(RODBC)
library(odbc)
library(stringr)

con <- odbcConnect("HANA")

attributes(con)
odbcGetInfo(con)

# ===== Set up connection and run query ===== #
# Check out the below query: note the "\" to escape quotes inside quotes
sell_thru = sqlQuery(con, "SELECT sales_org, postal_cd, sold_to_desc, fiscal_week_begin, net_management_sales_usd 
                           FROM _SYS_BIC.\"BOSE.MPE_SALES/MPE_CAV_SALES_SALESACTUALS_SELLTHROUGH\" where SALES_ORG='US10'")

# Check out sell_thru (do not open sell_thru df entirely - R will crash)
head(sell_thru)

# EX 1. Some postal codes have more than 5 characters. Show the different number of characters that the postal_cd field is made out of.     
unique(nchar(as.character(sell_thru$POSTAL_CD)))

# EX 2. Clean up the POSTAL_CD field to always consist of the first 5 characters  
# Hint: Use substr()
sell_thru$POSTAL_CD = substr(sell_thru$POSTAL_CD,1,5)
unique(nchar(as.character(sell_thru$POSTAL_CD)))

# EX 3. Now exclude the zips with length 0 
sell_thru = sell_thru[!(sell_thru$POSTAL_CD == ""),]
unique(nchar(as.character(sell_thru$POSTAL_CD)))

# Padding zips w/ trailing 0's
sell_thru$POSTAL_CD = str_pad(sell_thru$POSTAL_CD, 5, pad="0")
unique(nchar(as.character(sell_thru$POSTAL_CD)))

# EX 4. SOLD_TO_DESC includes all resellers. Transform the field to split out "BB", transform any other values to "RSL". 
# (Hint: use ifelse() on the SOLD_TO_DESC field)
unique(sell_thru$SOLD_TO_DESC)
sell_thru$SOLD_TO_DESC = ifelse(sell_thru$SOLD_TO_DESC == "Best Buy Stores","BB","RSL")
unique(sell_thru$SOLD_TO_DESC)

# ===== Retrieve sell-in data ===== #
sell_in = sqlQuery(con, "SELECT net_mangement_sales_usd, postal_cd, sales_org, sales_off, fiscal_week_begin FROM _SYS_BIC.\"BOSE.MPE_SALES/MPE_CAV_SALES_DIRECT_SELLIN\" where SALES_ORG ='US10' AND sales_off IN ('4003','4010')")

# EX 5. check out sell_in 
head(sell_in)

# EX 6. Use same procedure as above for sell-thru to clean up zip codes
unique(nchar(as.character(sell_in$POSTAL_CD)))
sell_in$POSTAL_CD = substr(sell_in$POSTAL_CD,1,5)
sell_in$POSTAL_CD = str_pad(sell_in$POSTAL_CD, 5, pad="0")

unique(nchar(as.character(sell_in$POSTAL_CD)))

# ===== Now we want to join the two data sets ===== # 
# EX 7. Make sure the sell-in data frame has a column "channel" that indicates which channel the results apply to
sell_in["channel"] = ifelse(sell_in$SALES_OFF == "4003", "RDG","ECOM")
unique(sell_in$channel)

# EX 8. Strip column SALES_OFF as we do not need it anymore now we have channel 
sell_in = sell_in[,colnames(sell_in) != "SALES_OFF"]
sell_in = sell_in %>% dplyr::select(-SALES_OFF)

# EX 9. Make sure both data frames have the same column names (hint: use colnames())
colnames(sell_in) <- c("sales","zip","sales_org","fwk","channel")
colnames(sell_thru) <- c("sales_org","zip","channel","fwk","sales")

# EX 10. Join the two dataframes by using rbind() ("rowbind")
sales = rbind(sell_in,sell_thru) 
nrow(sales) == nrow(sell_in) + nrow(sell_thru)

# EX 11. Write the results to a local csv file (hint: use write.csv())
sales = sales[,colnames(sales) != "X"]
write.csv(sales, "~/sales.csv", row.names = FALSE)

