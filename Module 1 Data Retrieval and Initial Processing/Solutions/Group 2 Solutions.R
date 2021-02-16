# ---------------------------------------------------------------------------------------------------------------- #
# This script will ingest data from HANA to your laptop. It also performs some initial preprocessing of the data.  #
# Parts of the script are coded for you - the numbered exercises are meant for you to practise.                    #
# ---------------------------------------------------------------------------------------------------------------- #

# We'll start by loading the libraries we're going to need. Please use install.packages("<package_name>") the first 
# time you're using a package. After that, you can simply use library(<package_name>) as below.
library(RODBC)
library(odbc)
library(stringr)
library(rstudioapi)

# ===== Set up connection and run query ===== #
# Using the odbc libraries, we will set up a connection to hana as follows. The name you filled in should correspond
# to the DSN name in data source manager.
#produces error: con <- odbcConnect("HANA")
con <- odbcConnect(dsn = "HANA",uid = "jc1039692",pwd = askForPassword(prompt = "Please enter your password"))
rodbc <- odbc::dbConnect(odbc::odbc(), dsn = "HANA",uid = "jc1039692",pwd = askForPassword(prompt = "Please enter your password"))

attributes(con)
odbcGetInfo(con)

# Now the connection is set up, we can query the database using a SQL statement. 
# Check out the below query. Note the "\" to escape quotes inside quotes. It will take a minute for the query to run.
sell_thru = sqlQuery(con, "SELECT sales_org, postal_cd, sold_to_desc, fiscal_week_begin, net_management_sales_usd FROM _SYS_BIC.\"BOSE.MPE_SALES/MPE_CAV_SALES_SALESACTUALS_SELLTHROUGH\"where SALES_ORG='US10'")

# Check out the data you have just retrieved (do not open sell_in entirely - R will crash).
head(sell_thru)

# EX 1. Some postal codes have more than 5 characters. Show the different number of characters that the postal_cd field is made out of.     
#Both of the following give the same output
nchar(sell_thru$POSTAL_CD, type = "chars", allowNA = FALSE, keepNA = NA)
(str_length(sell_thru$POSTAL_CD))

# EX 2. Clean up the POSTAL_CD field to always consist of the first 5 characters. Hint: Use substr().
sell_thru$POSTAL_CD <- substr(sell_thru$POSTAL_CD, 0, 5)
sell_thru$POSTAL_CD

# EX 3. Now exclude the zips with length 0.
df(sell_thru$POSTAL_CD != 0, )
complete.cases(sell_thru$POSTAL_CD)
sell_thru <- sell_thru[complete.cases(sell_thru$POSTAL_CD),]


# We want all zips to be of length 5. Here we use padding to add trailing 0's to zip codes of length < 5.
sell_thru$POSTAL_CD = str_pad(sell_thru$POSTAL_CD, 5, pad="0")
(sell_thru$POSTAL_CD = str_pad(sell_thru$POSTAL_CD, 5, pad="0"))

# EX 4. SOLD_TO_DESC includes all resellers. Transform the field to split out "BB", transform any other values to "RSL". 
# (Hint: use ifelse() or case_when() on the SOLD_TO_DESC field).
sell_thru$SOLD_TO_DESC <- ifelse(sell_thru$SOLD_TO_DESC == "Best Buy Stores", "BB", "RSL")


# ===== Retrieve sell-in data ===== #
sell_in = sqlQuery(con, "SELECT net_mangement_sales_usd, postal_cd, sales_org, sales_off, fiscal_week_begin FROM _SYS_BIC.\"BOSE.MPE_SALES/MPE_CAV_SALES_DIRECT_SELLIN\" where SALES_ORG ='US10' AND sales_off IN ('4003','4010')")

# EX 5. check out sell_in .
head(sell_in)


# EX 6. Use same procedure as above for sell-thru to clean up zip codes..
nchar(sell_in$POSTAL_CD, type = "chars", allowNA = FALSE, keepNA = NA)
sell_in <- sell_in[complete.cases(sell_in$POSTAL_CD),]
sell_in$POSTAL_CD <- substr(sell_in$POSTAL_CD, 0, 5)
sell_in <- sell_in[complete.cases(sell_in$POSTAL_CD),]

# ===== Now we want to join the two data sets ===== # 
# EX 7. Make sure the sell-in data frame has a column "channel" that indicates which channel the results apply to.
sell_in$Channel = ifelse(sell_in$SALES_OFF == 4003, "RDG", "DCD")

# EX 8. Strip column SALES_OFF as we do not need it anymore now we have channel .
sell_in$SALES_OFF <- NULL

# EX 9. Make sure both data frames have the same column names. Hint: use colnames().
colnames(sell_in)
colnames(sell_thru)
colnames(sell_thru)[colnames(sell_thru) == "SOLD_TO_DESC"] <- "Channel"
colnames(sell_in)[colnames(sell_in) == "NET_MANGEMENT_SALES_USD"] <- "NET_MANAGEMENT_SALES_USD"

# EX 10. Join the two dataframes by using rbind() ("rowbind").
COMBINED <- rbind(sell_in, sell_thru)


# EX 11. Write the results to a local csv file. Hint: use write.csv().
write.csv(COMBINED)
