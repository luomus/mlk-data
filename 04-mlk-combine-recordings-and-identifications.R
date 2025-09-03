library(readr)
library(dplyr)

# Read in recordings data
recordings_anon <- readRDS("recordings_anon.rds")

# Read in identifications
species_ids <- read_csv("species_ids.csv", col_types = "cdddcclll-")

# Combine recordings and identifications
species_ids <- full_join(species_ids, recordings_anon, by = "rec_id")

saveRDS(species_ids, "species_ids.rds")
