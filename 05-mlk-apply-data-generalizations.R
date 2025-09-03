library(readr)
library(dplyr)

# Read in data generalization specifications
generalization <- read_csv("data-generalizations.csv")

# Read in identifications
species_ids <- readRDS("species_ids.rds")

# Combine identifications and data generalizations
species_ids <- left_join(
  species_ids,
  generalization,
  by = c("species", "winter", "breeding", "natura")
)

# Remove data unneeded columns
species_ids$winter   <- NULL
species_ids$breeding <- NULL
species_ids$natura   <- NULL

# Apply data generalizations
species_ids <- mutate(
  species_ids,

  # Remove values revealing sensitive species locations via links to other data
  rec_id = case_when(
    is.na(treatment) ~ rec_id,
    .default = NA_character_
  ),
  user_anon = case_when(
    is.na(treatment) ~ user_anon,
    .default = NA_character_
  ),
  time = case_when(
    is.na(treatment) ~ time,
    .default = NA_character_
  ),
  len = case_when(
    is.na(treatment) ~ len,
    .default = NA_real_
  ),
  dur = case_when(
    is.na(treatment) ~ dur,
    .default = NA_real_
  ),
  real_obs = case_when(
    is.na(treatment) ~ real_obs,
    .default = NA
  ),
  rec_type = case_when(
    is.na(treatment) ~ rec_type,
    .default = NA_character_
  ),
  point_count_loc = case_when(
    is.na(treatment) ~ point_count_loc,
    .default = NA_character_
  ),

  # Select values of lat & lon according to the appropriate generalization level
  lat = case_match(
    as.character(treatment),
    "-1" ~ NA_character_,
    "5" ~ lat5,
    "10" ~ lat10,
    "25" ~ lat25,
    "50" ~ lat50,
    "100" ~ lat100,
    .default = lat1
  ),
  lon = case_match(
    as.character(treatment),
    "-1" ~ NA_character_,
    "5" ~ lon5,
    "10" ~ lon10,
    "25" ~ lon25,
    "50" ~ lon50,
    "100" ~ lon100,
    .default = lon1
  ),
  # Add a field indicating the level of generalization used
  data_generalization = case_when(
    is.na(treatment) ~ 1,
    .default = treatment
  ),

  # Remove unneeded fields
  treatment = NULL,
  lat1 = NULL,
  lon1 = NULL,
  lat5 = NULL,
  lon5 = NULL,
  lat10 = NULL,
  lon10 = NULL,
  lat25 = NULL,
  lon25 = NULL,
  lat50 = NULL,
  lon50 = NULL,
  lat100 = NULL,
  lon100 = NULL
)

# Randomize order of rows to ensure sensitive locations are not revealed
species_ids <- species_ids[sample(nrow(species_ids)), ]

# Write table to a zip archive
write.csv(species_ids, "mlk-public-data.csv", row.names = FALSE, quote = FALSE)
unlink("mlk-public-data.zip")
zip("mlk-public-data.zip", "mlk-public-data.csv", flags = "-jr9X")
