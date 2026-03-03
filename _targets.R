library(targets)
library(tarchetypes) # For extra target archetypes

# Which packages do you need?
pkgs <- c(
  "janitor", # data cleaning
  "labelled", # labeling data
  "pointblank", # data validation and exploration
  "rvest", # get data from web pages
  "tidyverse", # Data management
  "data.table", # fast data management
  "fs", # to work wit hthe file system
  "zip" # manipulate zip files
)
# Install packages if you don't already have them
install.packages(setdiff(pkgs, row.names(installed.packages())))

# NOTE! The packages specified in `pkgs` will be used by the targets.
# They will, however, not be available within the interactive session unless you also load them here:
invisible(lapply(pkgs, library, character.only = TRUE))

# Set target options:
tar_option_set(
  # Packages that your targets need for their tasks:
  packages = pkgs,
  format = "qs", # Default storage format. qs (which is actually qs2) is fast.
)

# Run the R scripts stored in the R/ folder where your have stored your custom functions:
tar_source()

# We first download the data health care data of interest
if (!fs::file_exists("data.zip")) {
  message("Downloading data.zip from GitHub")
  curl::curl_download(
    "https://github.com/STA220/cs/raw/refs/heads/main/data.zip",
    "data.zip",
    quiet = FALSE
  )
}


# Define targets pipeline ------------------------------------------------

# Help: https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline

list(
  # make the zipdata object refer to the data.zip file path
  tar_target(zipdata, "data.zip", format = "file")

  # TODO: Something related to zip should be added here:
  # And this comment should be replaced by something more useful

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
