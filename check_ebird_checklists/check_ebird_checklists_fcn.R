# Check eBird Checklist
# Author: Linus Blomqvist
# Adaptation of code from Raphaël Nussbaumer
# See https://github.com/Zoziologie/Check-eBird-Checklist

# Load packages
library(tidyverse)
library(auk)
library(DT)
library(ggplot2)
library(writexl)
library(glue)
library(sf)

continents_buffer <- readRDS("continents_buffer.rds")

# Create function
create_chk <- function(txt_file, too_many_species, too_many_species_stationary, too_long_land, too_many_observers, too_long_offshore) {

  obs_0 <- read_ebd(txt_file)

  obs_0 <- obs_0 %>%
    filter(all_species_reported == TRUE)

  obs <- obs_0 %>%
    mutate(
      group_id = checklist_id,
      checklist_id = sampling_event_identifier
    ) %>%
    select(c(
      "group_id", "checklist_id", "taxonomic_order", "common_name", "observation_count",
      "locality", "observation_date", "time_observations_started", "observer_id",
      "protocol_type", "duration_minutes", "effort_distance_km", "number_observers",
      "all_species_reported", "has_media", "latitude", "longitude")) %>%
    mutate(url = str_c("https://ebird.org/checklist/", str_extract(checklist_id, "[^,]+"), sep = "")) %>%
    relocate(url, .after = checklist_id)

  # coordinates <- obs %>%
  #   distinct(checklist_id, .keep_all = TRUE) %>%
  #   select(checklist_id, latitude, longitude)

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
      time_observations_started = hms(time_observations_started, quiet = T),
      checklist_link = paste0("<a href='https://ebird.org/checklist/", str_extract(checklist_id, "^[^,]+"), "' target='_blank'>", checklist_id, "</a>"),
      all_species_reported = all_species_reported & protocol_type != "Incidental"
    )

  chk <- c %>%
    mutate(
      ampm = (time_observations_started > hm("22:00") | time_observations_started < hm("4:00")) &
        (time_observations_started + minutes(duration_minutes) < hm("6:00")) &
        number_species > 10,
      midnight = time_observations_started == hms("00:00:00"),
      high_number_species = number_species > too_many_species,
      only_one_species = all_species_reported & number_species==1 & duration_minutes > 5,
      same_count_all_species = all_species_reported & median_count>0 & number_distinct_count==1 & number_species > 5,
      multi_day = time_observations_started + minutes(duration_minutes) > hours(24),
      too_many_observers = number_observers > too_many_observers,
      too_short_duration = all_species_reported & number_species/duration_minutes > 10,
      too_fast = effort_distance_km/duration_minutes*60 > 60,
      complete_media = all_species_reported & number_media==number_species,
      not_stationary = protocol_type == "Stationary" & number_species > too_many_species_stationary,
      not_traveling = protocol_type=="Traveling" & effort_distance_km < 0.03
    ) %>%
    mutate(pelagic_too_long = ifelse(protocol_type == "eBird Pelagic Protocol" & duration_minutes > 75, TRUE, FALSE)) %>%
    mutate(specialized_protocol = !(protocol_type %in% c("Historical", "Traveling", "Incidental", "Stationary"))) %>%
    mutate(no_observer_mismatch = ifelse(no_checklists > number_observers, TRUE, FALSE))

  chk <- st_as_sf(chk, coords = c("longitude", "latitude"), crs = 4326) %>%
    st_transform(crs = 3857)

  chk <- chk %>%
    st_join(continents_buffer) %>%
    mutate(too_long_distance_land = ifelse(!is.na(continent) & effort_distance_km > too_long_land,
                                      TRUE, FALSE)) %>%
    mutate(too_long_distance_offshore = ifelse(is.na(continent) & effort_distance_km > too_long_offshore,
                                               TRUE, FALSE)) %>%
    st_drop_geometry() %>%
    select(-continent)

  chk <- chk %>%
    select(-c(time_observations_started, all_species_reported, number_distinct_count,
              median_count, number_media, checklist_link, checklist_id, observer_id)) %>%
    relocate(no_checklists, .after = number_observers)

  return(chk)
}
