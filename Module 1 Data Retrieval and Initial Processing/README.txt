Welcome to your second training!

In this module we want to learn how to retrieve data from (relational) databases. We will probably be exclusively using HANA and GFSDATA, so let's focus on those. Once we've retrieved some data, we will do some preprocessing, before we save the results as a data frame to a csv file for later use. 

Start by running through glimpse_db.R. This script shows some functions to check out a certain view within a database. It also uses a new R package called dbplyr that allows us to use dplyr functions within the database. This means we can run computations within the database, before loading it into memory. This could be extremely useful when dealing with large data sets that we simply cannot fully load into our laptops' memory. Functions from the plyr package are also much more flexible and cleaner to work with than SQL. 

Once you've ran through this script, move on to hana_connector.R, which will explore how to use SQL to retrieve some data from a database. 
Try and code it yourself. Small parts are done for you, but most if it you have to do on your own (follow the 11 EX steps by coding underneath numbered exercises). I am giving some hints along the way. 

Remember there's more than one way to skin a cat - this is just showing you one way of doing it. 

Before start of this exercise, make sure to:
- Request access to HANA
- Install HANA driver
- Configure HANA in ODBC data sources
- Install packages that are being used by running install.packages("<package.name>") in the R console

Next training we'll be exploring the data in a bit more detail.

Good luck!