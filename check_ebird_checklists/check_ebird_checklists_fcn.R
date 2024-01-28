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

# Create function
create_chk <- function(txt_file) {
  
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
      "all_species_reported", "has_media"))
  
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
      chk_ampm = (time_observations_started > hm("22:00") | time_observations_started < hm("4:00")) & 
        (time_observations_started + minutes(duration_minutes) < hm("6:00")) & 
        number_species > 10,
      chk_midnight = time_observations_started == hms("00:00:00"),
      chk_high_number_species = number_species>70,
      chk_only_one_species = all_species_reported & number_species==1 & duration_minutes > 5,
      chk_same_count_all_species = all_species_reported & median_count>0 & number_distinct_count==1 & number_species>2,
      chk_too_long_distance = effort_distance_km > 20,
      chk_multi_day = time_observations_started + minutes(duration_minutes) > hours(24),
      chk_too_many_observers = number_observers > 30,
      chk_too_short_duration = all_species_reported & number_species/duration_minutes > 10,
      chk_too_fast = effort_distance_km/duration_minutes*60 > 60,
      chk_complete_media = all_species_reported & number_media==number_species,
      chk_not_stationary = protocol_type == "Stationary" & number_species>50,
      chk_specialized_protocol = !(protocol_type %in% c("Historical", "Traveling", "Incidental", "Stationary")),
      chk_not_traveling = protocol_type=="Traveling" & effort_distance_km < 0.03
    ) %>% 
    mutate(across(starts_with("chk_"), ~replace_na(., FALSE)))
  
  chk <- chk %>%
    mutate(dubious = ifelse(rowSums(.[,16:29]) >= 1, TRUE, FALSE)) %>%
    filter(dubious == TRUE)
  
  chk <- chk %>%
    select(-c(time_observations_started, all_species_reported, number_distinct_count,
           median_count, number_media, checklist_link, dubious))
  
  return(chk)
}
