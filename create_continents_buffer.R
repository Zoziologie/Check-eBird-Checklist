library(sf)
library(tidyverse)
library(janitor)

continents <- read_sf("WB_countries_Admin0_10m/WB_countries_Admin0_10m.shp") %>%
  clean_names() %>%
  select(geometry, continent) %>%
  st_make_valid() %>%
  st_transform(crs = 3857)

continents_buffer <- continents %>%
  st_buffer(3219) %>%
  st_make_valid()

saveRDS(continents_buffer, "check_ebird_checklists/continents_buffer.rds")


library(sf)
library(ggplot2)

# Assuming 'world_continents' is the original sf object and 'world_continents_buffered' is the buffered object

# Define the zoom area by specifying the bounding box (xmin, xmax, ymin, ymax)
zoom_area <- c(xmin = -120, xmax = -118, ymin = 33, ymax = 35)

if (st_crs(continents)$epsg != 4326) {
  world_continents <- st_transform(continents, crs = 4326)
  world_continents_buffered <- st_transform(continents_buffer, crs = 4326)
}

# Decimal degree coordinates
latitude <- 34.407139
longitude <- -119.878306

# Create an sf object for the point
point_sf <- st_as_sf(data.frame(lon = longitude, lat = latitude),
                     coords = c("lon", "lat"), crs = 4326)


# Assuming 'world_continents' and 'world_continents_buffered' are already defined
ggplot() +
  geom_sf(data = world_continents, fill = "lightblue", color = "black", alpha = 0.3) +  # Original continents
  geom_sf(data = world_continents_buffered, fill = NA, color = "red", alpha = 0.8) +  # Buffered continents
  geom_sf(data = point_sf, color = "blue", size = 3) +  # Add the point
  coord_sf(xlim = c(zoom_area["xmin"], zoom_area["xmax"]),
           ylim = c(zoom_area["ymin"], zoom_area["ymax"])) +
  theme_minimal() +
  labs(title = "Comparison of Buffered and Original Continents",
       subtitle = "Including Specific Point of Interest")
