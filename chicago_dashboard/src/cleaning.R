
ca_boundaries <- ca_boundaries_raw %>%
  st_set_crs(4326) %>%
  mutate(area_num_1 = as.numeric(area_num_1),
         community = str_to_lower(community),
         community = str_to_title(community)) %>%
  select(area_num_1,community, geometry) 

ca_snapshot <- ca_snapshot_raw %>%
  left_join(ca_boundaries, by = c("GEOID" = "area_num_1")) %>%
  rename_with(str_to_lower) %>%
  rename_with(~ paste0("n_", .), .cols = matches("^\\d"))
