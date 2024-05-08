library(shiny)
library(leaflet)
library(tidyr)
library(dplyr)
library(DBI)
library(RSQLite)
library(DT)
library(shinyjs)
library(ggplot2)
install.packages("rhandsontable")
install.packages("shinydashboard")
install.packages("maps")
postgre_con <- dbConnect(RPostgres::Postgres(),
                         dbname = 'PolicyPortrait', # name of the database
                         host = '127.0.0.1', 
                         port = 5433, 
                         user = 'postgres',
                         password = 'KpmtZ8144122') # PostgreSQL/pgAdmin password
postgres_sql<- "SELECT * FROM policies"

dbGetQuery(postgre_con, postgres_sql) 

policies.df <-dbGetQuery(postgre_con, postgres_sql)
class(policies.df)
