# Check eBird Checklist
# Author: Linus Blomqvist
# Adaptation of code from Raphaël Nussbaumer
# See https://github.com/Zoziologie/Check-eBird-Checklist

# Check if pacman is installed; if not, install it
if (!requireNamespace("pacman", quietly = TRUE)) {
  install.packages("pacman")
}

# Load packages
pacman::p_load(tidyverse, auk, DT, writexl, glue, sf, lubridate, hms, lutz, suncalc)

# Load continents buffer object
continents_buffer <- readRDS("continents_buffer.rds")

# Create function
create_chk <- function(txt_file, too_many_species, too_many_species_stationary, too_long_land, too_many_observers, too_long_offshore) {

  obs_0 <- read_ebd(txt_file) %>%
    filter(all_species_reported == TRUE)

  # Normalize protocol column name
  if ("protocol_type" %in% names(obs_0)) {
    obs_0 <- obs_0 %>% rename(protocol_name = protocol_type)
  }

  obs <- obs_0 %>%
    mutate(
      group_id = checklist_id,
      checklist_id = sampling_event_identifier
    ) %>%
    select(c(
      "group_id", "checklist_id", "taxonomic_order", "common_name", "observation_count",
      "locality", "observation_date", "time_observations_started", "observer_id",
      "protocol_name", "duration_minutes", "effort_distance_km", "number_observers",
      "all_species_reported", "has_media", "latitude", "longitude")) %>%
    mutate(url = str_c("https://ebird.org/checklist/", str_extract(checklist_id, "[^,]+"), sep = ""))

  c <- obs %>%
    mutate(
      observation_count_num = as.numeric(ifelse(observation_count == "X", NA, observation_count))
    ) %>%
    group_by(group_id) %>%
    mutate(
      number_species = n(),
      number_distinct_count = n_distinct(observation_count),
      median_count = median(observation_count_num, na.rm = T),
      number_media = sum(has_media)
    ) %>%
    mutate(no_checklists = sapply(str_extract_all(checklist_id, "S\\d+"),
                                  function(x) length(unique(x)))) %>%
    ungroup() %>%
    select(-c(group_id, taxonomic_order, common_name, observation_count, observation_count_num, has_media)) %>%
    unique()

  c <- c %>%
    mutate(
      observation_date = ymd(observation_date),
      time_observations_started = as_hms(time_observations_started),
      checklist_link = paste0("<a href='https://ebird.org/checklist/",
                              str_extract(checklist_id, "^[^,]+"), "' target='_blank'>", checklist_id, "</a>"),
      all_species_reported = all_species_reported & protocol_name != "Incidental"
    ) %>%
    mutate(time_observations_ended = as_hms(as.POSIXct(time_observations_started) + minutes(duration_minutes)))

  c_sf <- st_as_sf(c, coords = c("longitude", "latitude"), crs = 4326) %>%
    st_transform(crs = 3857) %>%
    st_join(continents_buffer) %>%
    st_transform(crs = 4326)

  # Extract latitude, longitude, and dates from your sf object
  latitudes <- st_coordinates(c_sf)[,2]  # Latitude
  longitudes <- st_coordinates(c_sf)[,1]  # Longitude
  dates <- c_sf$observation_date  # Dates

  # Step 1: Round the coordinates to reduce precision (e.g., 2 decimal places)
  rounded_latitudes <- round(latitudes, 1)
  rounded_longitudes <- round(longitudes, 1)

  # Combine rounded lat, lon into a dataframe and find unique rounded coordinates
  coords_df <- data.frame(lat = rounded_latitudes, lon = rounded_longitudes)
  unique_coords <- distinct(coords_df)

  # Step 2: Lookup time zones only for unique rounded coordinates
  unique_coords$time_zone <- tz_lookup_coords(unique_coords$lat, unique_coords$lon, method = "accurate")

  # Step 3: Join the time zones back to the original data based on rounded lat/lon
  coords_df <- left_join(coords_df, unique_coords, by = c("lat", "lon"))

  # Step 4: Now calculate dawn and dusk times in local time zone
  dawn_dusk_times <- mapply(function(lat, lon, date, tz) {
    # Calculate dawn and dusk in UTC (civil twilight)
    sun_times <- getSunlightTimes(date = date, lat = lat, lon = lon, keep = c("dawn", "dusk"))

    # Convert to local time zone
    sun_times$dawn <- with_tz(as.POSIXct(sun_times$dawn), tzone = tz)
    sun_times$dusk <- with_tz(as.POSIXct(sun_times$dusk), tzone = tz)

    return(sun_times)
  }, latitudes, longitudes, dates, coords_df$time_zone, SIMPLIFY = FALSE)

  # Combine the results into a dataframe
  dawn_dusk_df <- do.call(rbind, dawn_dusk_times)

  # Keep only dawn and dusk columns
  dawn_dusk_df <- dawn_dusk_df[, c("dawn", "dusk")]

  c <- bind_cols(c_sf, dawn_dusk_df) %>%
    st_drop_geometry()

  c <- c %>%
    mutate(
      # Convert dusk and dawn POSIXct to time of day (hms)
      dusk_time = as_hms(dusk),
      dawn_time = as_hms(dawn),

      # Subtract 30 minutes from dawn by manually converting 30 minutes to seconds (30 * 60 = 1800 seconds)
      dawn_minus_30 = as_hms(as.numeric(dawn_time) - 1800),

      # Compare the time of day (ignoring the date)
      nocturnal = time_observations_started > dusk_time | time_observations_started < dawn_minus_30
    )

  chk <- c %>%
    mutate(
      ampm = nocturnal == TRUE & number_species > 10,
      midnight = time_observations_started == hms(0, 0, 0),
      high_number_species = number_species > too_many_species,
      only_one_species = nocturnal == FALSE & all_species_reported & number_species == 1 & duration_minutes > 5,
      same_count_all_species = all_species_reported & median_count > 0 & number_distinct_count == 1 & number_species > 5,
      multi_day = nocturnal == FALSE & as.numeric(time_observations_started) + (duration_minutes * 60) > 86400,
      too_many_observers = number_observers > too_many_observers,
      too_short_duration = all_species_reported & number_species/duration_minutes > 10,
      too_fast = effort_distance_km/duration_minutes*60 > 60,
      complete_media = nocturnal == FALSE & all_species_reported & number_media == number_species,
      not_stationary = protocol_name == "Stationary" & number_species > too_many_species_stationary,
      not_traveling = protocol_name=="Traveling" & effort_distance_km < 0.03
    ) %>%
    mutate(pelagic_too_long = ifelse(protocol_name == "eBird Pelagic Protocol" & duration_minutes > 75, TRUE, FALSE)) %>%
    mutate(specialized_protocol = !(protocol_name %in% c("Historical", "Traveling", "Incidental", "Stationary"))) %>%
    mutate(no_observer_mismatch = ifelse(no_checklists > number_observers, TRUE, FALSE)) %>%
    mutate(too_long_distance_land = ifelse(!is.na(continent) & effort_distance_km > too_long_land,
                                           TRUE, FALSE)) %>%
    mutate(too_long_distance_offshore = ifelse(is.na(continent) & effort_distance_km > too_long_offshore,
                                               TRUE, FALSE))

  chk <- chk %>%
    select(url, locality:time_observations_started, protocol_name, duration_minutes,
           effort_distance_km, number_observers, number_species, observer_id,
           ampm:too_long_distance_offshore) %>%
    distinct()

  return(chk)
}
