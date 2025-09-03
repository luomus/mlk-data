library(readr)
library(sf)

# Read locations data
locations <- st_as_sf(
  read_csv("recordings_anon.csv", col_types = "--------dd--"),
  coords = c("lon", "lat"), crs = 4326
)

# Determine which locations are in Natura 2000 areas
natura <- as.vector(
  st_intersects(
    st_union(
      st_read(
        "Natura2000_end2021_rev1.gpkg", # source: https://www.eea.europa.eu/data-and-maps/data/natura-14/natura-2000-spatial-data
        query = "SELECT geom FROM \"NaturaSite_polygon\" WHERE MS = \"FI\""
      )
    ),
    st_transform(locations, crs = 3035), # Convert locations to EPSG:3035
    sparse = FALSE
  )
)

saveRDS(natura, "natura.rds")
