# Playing around ---------------------------------------------------------

# How old are these people? We know when they were born, so let's subtract that from todays date and
# calculate the whole number of times they have circled the sun up until today
patients[, age := as.integer((as.IDate(Sys.Date()) - birthdate)) %/% 365.241]
patients[, hist(age)]
# Did we forget something? Maybe we should focus on the living?
patients[is.na(deathdate), hist(age)]
# Hmm, living by the time the data was collected ... but now we look at their age TODAY. Is this right?
# When was the original data set generated?
# Let's say we don't now ... (Yes, you should now if this was your own data, but reality is not always perfect).
# We have data for payer_transitions. Since this is US data, such things are important to their health care.
# We might check when the last transaction was performed and might guess that the data snapshot was taken soon after that.
payer_transitions[, max(end_date)]
# I gues that's close enough! Use that new info if you think it's relevant!

# What would we call those peopple?
# In a daily conversation we might not need to separate between fisrst and middle names etc.
patients[,
  full_name := paste(
    prefix,
    first,
    middle,
    last,
    fifelse(suffix != "", paste0(", ", suffix), "")
  )
]
patients[, full_name]
# Hm, some people got a trailing white space (can you see why this happened?).
# Lets remove all such things for all character columns
patients[, names(.SD) := lapply(.SD, trimws), .SDcols = is.character]

# With this new name variable, we might no longer need some of the original columns
patients[, c("prefix", "first", "middle", "last", "suffix", "maiden") := NULL]

# Data originates from a database. As such, the concept of NA might not have existed in the source
# (NULL is a slightly different concept). Instead empty strings are used to indicate missing data
# in some variables. This could in fact be handled by setting the `na.strings` argument in fread() above,
# but this time we missed it and could instead fix that now:
patients[, names(.SD) := lapply(.SD, \(x) na_if(x, "")), .SDcols = is.character]
# Btw, are empty strings the same as missing data? I think so in this case. But not always!

# Do we have any use of the `drivers` column?
# Mayby if we want to link the data to additional sources. Could be interesting for example to see
# for how long an individual had his/her license before being involved in a traffic accident for example.
# We don't have that info now so the only relevant information might be if an individual has a license or not.
patients[, drivers := !is.na(drivers)]
var_label(patients$drivers) <- "Does the person have a drivers license?"
# The same probably goes for several other columns. It might be good to deleta them when
# working with big data (to save space and therefore computational time etc)
# but in this case we could as well keep some extra columns for now.

# The lat and long columns are probably most relevant if we want to calculate distances to other places.
# Does individuals with a longer/shorter distance to their nearest hospital recieve better/worse care?
# Is the prevalence of skin cancer more prevalent if you live closer to the sea?
# But it might also just be fun to play with visualisations some times (if allowed by the ethical permit etc!).
# This might also be useful to decide how representative the sample is.
leaflet::leaflet(data = patients) |>
  leaflet::addTiles() |>
  leaflet::addMarkers(~lon, ~lat, label = ~full_name)
# Based on this data, would it be reasonable to make statistical inference for the whole of USA? For the whole world?

# Sometimes there might be whole columns or rows missing in a dataset
# We won't have much use for those so let's remove them
patients <- janitor::remove_empty(patients, quiet = FALSE)
# A column with only one constant value is also not very interesting
patients <- janitor::remove_constant(patients, quiet = FALSE)


# Expectations -----------------------------------------------------------

# What are our expectations of the data? Are those expectations full filled or do we need
# some additional modifications or perhaps deletaion of some data?
library(pointblank)

# Read: https://rstudio.github.io/pointblank/articles/VALID-I.html

# This package is not keen on IDates either so let's first convert those to plain Dates
patients[, names(.SD) := lapply(.SD, as.Date), .SDcols = is.Date]

al <- action_levels(warn_at = 1)

# I'll give you some of my expectations but there should probably be more!
# What do you expect for `marital`. Would "kulbo" be a valid value here?
# Is everyone supposed to be either male or female or cashouldn both be included
# (depends on the context, but so far we might have no reason to believe that
# any sex would be missing).
# Add at least five more expectations and describe by the labels what the current ones are for!

patients |>
  create_agent(
    label = "A very *simple* example.",
    actions = al
  ) |>
  col_vals_between(
    where(is.Date),
    as.Date("1900-01-01"),
    as.Date(Sys.Date()),
    na_pass = TRUE,
    label = "WHAT DO WE CHECK HERE? DESCRIBE!"
  ) |>
  col_vals_gte(
    deathdate,
    vars(birthdate),
    na_pass = TRUE,
    label = "ADD SOMETHING!"
  ) |>
  col_vals_regex(
    ssn,
    "^[0-9]{3}-[0-9]{2}-[0-9]{4}$",
    label = "WHAT ON EARTH DOES THIS MEAN?"
  ) |>
  interrogate()


# Factors ----------------------------------------------------------------

# Some columns have just abbriviations for the values. Let's convert those to something more informative.
# In this case we don't actually know what the differnt marital status are but me might have an educated guess.
# NOTE! This is obviously dangerous in a real world scenario!
# Lacking documentation, however, is a very real problem!
patients[, .N, marital]
# My best guess would be:
patients[,
  marital := factor(
    marital,
    levels = c("S", "M", "D", "W"),
    labels = c("Single", "Married", "Divorced", "Widowed")
  )
]
# The abbriviations used for `gender` actually seems to correspond more to what is expected for `sex`.
# Do we actually know if this variable concerns `gender` or `sex`? Does it matter in this case?
# Add factor levels for all variables deemed relevant.
# When looking at race, you might see that one group is quite small compared to the others.
# Whould it be sensible to present data in a later stage where individual persons might
# be able to identify themselves, for example based on a combination of this variable and a rare disease?
# Do you have the ethical permission to present such data (you obviously had the permission to
# retrieve the data, but that might be for other purposes)?
# Should certain groups be combined when analyzed?
# If so, please do.
