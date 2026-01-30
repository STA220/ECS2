# Introduction -----------------------------------------------------------

# The common work flow in R is to load all data needed into the random access memory (RAM)
# and then to work with it. For small and medium size prjects such data wrangling can
# "easily" be performed by the {tidyverse} packages and associated syntax.
# I wanted to use {data.table} instead in `cs1_data.table.R`, since this is more efficient
# for larger data sets (and its syntax is also very expressive and consise).
# When working with "big data", however, it might not even be possible
# to fit all the necessary data into RAM.
# In such cases, one might want to use a database.
# Some data bases are costly, requires a lot of administration and are not primarly designed for
# data analysis or statistics.
# ADuckDB, however is!
# https://duckdb.org/

# There is an exciting package called {duckplyr} with the goal to make working with DuckDB
# easier and more efficient for R users. This seems really promising, although it might still
# be a less established/mature work flow compared to data.table
# (which has been around since even before tidyverse).

# This exercise is just to introduce the basic work flow and to get you started with DuckDB.
# Otherwise, the focus of the course will be to handle data in memory.

library(tidyverse)
library(duckdb)
library(duckplyr)
library(DBI)

# Create the database!
con <- dbConnect(duckdb::duckdb(), "sta220.duckdb")

# List all the data files we have to work with
csv_files <- dir("data-fixed", ".csv", full.names = TRUE)

# Function to create a table from a .csv file
# By 2025-05-28 you still had to use some query language to create the table
# This might have changed already so fell free to improve the code if possible!
copy_file <- function(csv_file, con) {
  tabellnamn <- tools::file_path_sans_ext(basename(csv_file))
  query <- sprintf(
    "CREATE TABLE \"%s\" AS SELECT * FROM read_csv_auto('%s')",
    tabellnamn,
    csv_file
  )
  dbExecute(con, query)
}

# Copy all CSV-files to the database
walk(csv_files, copy_file, con, .progress = TRUE)

# We can create references to all tables in the data base for easier access
(tab_names <- dbListTables(con))
walk(tab_names, \(name) assign(name, tbl(con, name), envir = .GlobalEnv))

# Now we can use the tables (almost) as if they were data frames
patients |> skimr::skim()

# Any difference in income between marital status for the living?
patients |>
  filter(!is.na(deathdate)) |>
  summarise(mean(income, na.rm = TRUE), .by = marital)

# Keys and indices?
# We used the id column as a key when using data.table
# It seems natural to do the same here (since the concept is often associated with data bases),
# but the fact is that DuckDB does not need it. All columns are primary keys by default.

# Your path forward? -----------------------------------------------------

# You could try to mimic some of the steps from the code in `cs1_data.table.R` and see if you can
# get the same result using tidyverse syntax with DuckDB and duckplyr.
# Instead of copying all files from `data-fixed` you could instead also create a
# database based on your files from `data-fixed`.

# Note, however, that less help might be provided if you choose this path.
# Hence, this option should only be considered if you are prepared to take the challenge!
# Further instructions will assume that you use the data.table option with cached qs files.
# In this case, you have to deviate from those instructions and be more active to
# get similar result as for the data.table approach.

# On the other hand, this is a good opportunity to get some hands-on experience with
# the duckplyr package and to get some experience with the duckdb database.
# data.table is a very good R-approach but DuckDB has a wider use base and therefore benefits of
# code optimasations and other things from outside the R community.
# You might for example consider working in a field where Python is preffered to R.
# If so, the DuckDB might be a better choice (no one knows, since things happen so fast in
# the field and new technology may appear and change things rapidly).
