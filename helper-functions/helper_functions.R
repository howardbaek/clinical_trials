
# PURPOSE -----------------------------------------------------------------

#' Provide helpful functions for doing very frequent tasks.
#' 



# essential libraries -----------------------------------------------------

if(require("RPostgreSQL")){library(RPostgreSQL)}else{install.packages("RPostgreSQL");library(RPostgreSQL)}
if(require("DBI")){library(DBI)}else{install.packages("DBI");library(DBI)}

# set up databaswe connection ---------------------------------------------

#' Make AACT database connection
#' the credentials file needs your registration information
#' the file needs to be tab separated with one row and column names
#' username is in a column called 'u'
#' password is in a column named 'pw'
aact_connector <- function(credentials_file=".my.aact.cnf"){
  
  drv <- dbDriver('PostgreSQL')
  
  dbConnect(drv,
            dbname="aact",
            host="aact-db.ctti-clinicaltrials.org",
            port=5432,
            user=readr::read_tsv(credentials_file)$u,
            password=readr::read_tsv(credentials_file)$pw
                   
  
  )
}

#' Getting AACT table
#' 
get_table <- function(con,table_name){
  
  try(tbl(con,table_name))
}
