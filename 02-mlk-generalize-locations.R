library(readr)
library(sf)

# Read locations data
locations <- st_as_sf(
  read_csv("recordings_anon.csv", col_types = "--------dd--"),
  coords = c("lon", "lat"), crs = 4326
)

locations$id <- 1:nrow(locations)

locations_north <- locations[st_coordinates(locations)[, "Y"] > 58, ]
locations_north_id <- locations_north$id

locations_south <- locations[st_coordinates(locations)[, "Y"] <= 58, ]
locations_south_id <- locations_south$id

# Transform northern coordinates to EPSG 3067
locations_north <- st_coordinates(st_transform(locations_north, crs = 3067))

# Transform southern coordinates to EPSG 3395
locations_south <- st_coordinates(st_transform(locations_south, crs = 3395))

# Generalize locations to 1, 5, 10, 25, 50 & 100km grid squares
locations <- lapply(
  c(1, 5, 10, 25, 50, 100), # For each grain size
  \(x) {
    l <- x * 1e3
    locations_north <- st_as_sf(
      # Snap coordinates to southwest cnr of grid
      as.data.frame(floor(locations_north / l) * l), #
      coords = c("X", "Y"),
      crs = 3067
    )
    # Convert back to lat-lon
    locations_north <- formatC(
      st_coordinates(st_transform(locations_north, crs = 4326)),
      digits = 3,
      format = "f"
    )
    locations_south <- st_as_sf(
      # Snap coordinates to southwest cnr of grid
      as.data.frame(floor(locations_south / l) * l),
      coords = c("X", "Y"),
      crs = 3395
    )
    # Convert back to lat-lon
    locations_south <- formatC(
      st_coordinates(st_transform(locations_south, crs = 4326)),
      digits = 3,
      format = "f"
    )

    locations <- rbind(locations_north, locations_south)
    locations[order(c(locations_north_id, locations_south_id)), ]
  }
)

saveRDS(locations, "locations.rds")
