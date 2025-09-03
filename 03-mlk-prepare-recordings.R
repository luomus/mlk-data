library(readr)

# Read in recordings data
recordings_anon <- read_csv("recordings_anon.csv", col_types = "cccddlcc---c")

# Extract and transform date and time data
recordings_anon <- transform(
  recordings_anon,
  year  = as.integer(substr(date, 1, 4)),
  month = as.integer(substr(date, 6, 7)),
  day   = as.integer(substr(date, 9, 10)),
  time  = paste(date, time, sep = "T"),
  date  = NULL # Date no longer needed
)

# Determine which recordings were made during breeding and/or winter seasons
recordings_anon <- transform(
  recordings_anon,
  breeding = month %in% 2:8, # From Feb to Aug
  winter = month %in% c(11:12, 1:2) | month == 3 & day %in% 1:10, # From Nov to March (the 10th)
  month = NULL, # Month no longer needed
  day = NULL # Day no longer needed
)

# Read in locations data
locations <- readRDS("locations.rds")

# Combine generalised locations and recording data
recordings_anon$lat1   <- locations[[1]][, "Y"]
recordings_anon$lon1   <- locations[[1]][, "X"]
recordings_anon$lat5   <- locations[[2]][, "Y"]
recordings_anon$lon5   <- locations[[2]][, "X"]
recordings_anon$lat10  <- locations[[3]][, "Y"]
recordings_anon$lon10  <- locations[[3]][, "X"]
recordings_anon$lat25  <- locations[[4]][, "Y"]
recordings_anon$lon25  <- locations[[4]][, "X"]
recordings_anon$lat50  <- locations[[5]][, "Y"]
recordings_anon$lon50  <- locations[[5]][, "X"]
recordings_anon$lat100 <- locations[[6]][, "Y"]
recordings_anon$lon100 <- locations[[6]][, "X"]

# Read in Natura 2000 area data and combine with recordings data
recordings_anon$natura <- readRDS("natura.rds")

saveRDS(recordings_anon, "recordings_anon.rds")
