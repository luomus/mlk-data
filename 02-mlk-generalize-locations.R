library(readr)
library(sf)

# Read locations data
locations <- st_as_sf(
  read_csv("recordings_anon.csv", col_types = "--------dd--"),
  coords = c("lon", "lat"), crs = 4326
)

# Transform coordinates to EPSG 3395 world mercator
locations <- st_coordinates(st_transform(locations, crs = 3395))

# Generalize locations to 1, 5, 10, 25, 50 & 100km grid squares
locations <- lapply(
  c(1, 5, 10, 25, 50, 100), # For each grain size
  \(x) {
    l <- x * 1e3
    locations <- st_as_sf(
      as.data.frame(floor(locations / l) * l), # Snap coordinates to southwest cnr of grid
      coords = c("X", "Y"),
      crs = 3395
    )
    # Convert back to lat-lon
    locations <- formatC(
      st_coordinates(st_transform(locations, crs = 4326)),
      digits = 3,
      format = "f"
    )
  }
)

saveRDS(locations, "locations.rds")
