library(targets)
library(tarchetypes) # For extra target archetypes

# Definiera paketlista
pkgs <- c(
  "data.table", # fast data management
  "janitor", # data cleaning
  "labelled", # labeling data
  "pointblank", # data validation and exploration
  "rvest", # get data from web pages
  "tidyverse", # Data management
  "zip" # manipulate zip files
)
# Ladda paketen i interaktiv session (så du kan använda dem i konsolen)
invisible(lapply(pkgs, library, character.only = TRUE))

# Set target options:
tar_option_set(
  # Packages that your targets need for their tasks:
  packages = pkgs,
  format = "qs", # Default storage format. qs is fast.
)

# Run the R scripts in the R/ folder with your custom functions:
tar_source()

# We first download the data file if they not exist
if (!fs::file_exists("data.zip")) {
  message("Downloading data.zip from GitHub")
  curl::curl_download(
    "https://github.com/eribul/cs/raw/refs/heads/main/data.zip",
    "data.zip",
    quiet = FALSE
  )
}


# Define targets pipeline ------------------------------------------------

# Help: https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline

list(
  # make the zipdata object refer to the data.zip file path
  tar_target(zipdata, "data.zip", format = "file"),

  # TODO: Something related to zip should be added here:

  # TODO: uncomment this section when instructed
  # tar_map(
  #  values = tibble::tibble(path = dir("data-fixed", full.names = TRUE)) |>
  #    dplyr::mutate(name = tools::file_path_sans_ext(basename(path))),
  #  tar_target(dt, fread(path)),
  #  names = name,
  #  descriptions = NULL
  #),

  # TODO: something related to codebook should be added here

  # TODO: Something related to data_scans should be added here
)
