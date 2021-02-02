library(RODBC)
library(odbc)
library(dplyr)
library(dbplyr)

# ===== Set up connection and run query ===== #
# Using the odbc libraries, we will set up a connection to hana as follows. The name you filled in should correspond
# to the DSN name in data source manager. In my case, this is simply "HANA". R will look up the connection parameters it needs from the 
# data source manager(server name / credentials / etc) and set up the connection.  
# you may need to add uid and pwd arguments to the below function for it to work
rodbc <- odbc::dbConnect(odbc::odbc(), dsn = "HANA")

# If we do not yet know which table we need, we could list the tables using the following command. 
# We do not want to run "dbListTables(rodbc)" in this case, as there's too many tables and it will take a long time to load. 
# We can filter down on tables that contain certain strings as follows. Note I used % as wildcards. 
dbListTables(rodbc, table_name = "BOSE.MPE_SALES/%SALES%")

# Let's say we want sell through data. Let's see if we can find a table that contains this data. Note that we cannot just use a view without verifying the data is correct.
# This is just for practice purposes. 
dbListTables(rodbc, table_name = "BOSE.MPE_SALES/%SELLTHROUGH%")

# Now suppose we know we know the table name we want to retrieve some data from (US sell through). We have its name, and can validate we have the right name using this 
# command. 
dbExistsTable(rodbc, "BOSE.MPE_SALES/MPE_CAV_SALES_SALESACTUALS_SELLTHROUGH_AM")

# With the following command we can explore what fields are in the view we want to query. 
dbListFields(rodbc, 'BOSE.MPE_SALES/MPE_CAV_SALES_SALESACTUALS_SELLTHROUGH_AM')

# Now we can set a so-called "pointer" to the database table. We have to certain syntax to make sure dbplyr knows what schema the table is in.  
service = tbl(rodbc, dbplyr::in_schema('_SYS_BIC','\"BOSE.MPE_SALES/MPE_CAV_SALES_SALESACTUALS_SELLTHROUGH_AM\"'))

# Once we set up this pointer, we can run computations in the database to check out the data and eventually filter it down. "glimpse" will give us 
# the fields and their data types. This will take some time to run. 
glimpse(service)

# Tally will count the rows in the view to get a feeling of its size.  
tally(service)

# Now let's use some dplyr functions to filter down the data to what we want and write it to a variable. 
# In this case, I want to filter on Best Buy sell through and show mean net billing quantities by product. 
service = service %>% 
          dplyr::filter(SOLD_TO_DESC == "Best Buy Stores") %>%
          dplyr::group_by(SAP_PRODUCT_FAMILY_DESC) %>%
          dplyr::summarise(mean = mean(NET_BILLING_QTY))

# This function uses "lazy" execution. This means it actually only starts executing once we start working with the data. Once we run a function on 
# the "service" pointer variable, it starts executing all that it needs to do to get to the desired result. This saves computational power. 
# Let's look at the data using head(). This means we are asking for data, so it starts executing above steps - you'll see this takes relatively long. 
head(service)

# Now let's filter service down to fiscal '17 and overwrite service. 
service = service %>% 
          dplyr::filter(FISCAL_YEAR >= 2017)
            
# We still didnt retrieve the data into local memory. We can do this using collect().
service = collect(service)

# Now we can play with service as a local variable.
head(service)

