
# Clean Chicago boundary file by taking the union of the different community areas
# and covert to the proper crs and sf format
chicago_boundary <- ca_boundaries_raw %>%
  st_union() %>%    # Combine all community area geometries into one
  st_cast("MULTIPOLYGON") %>%
  st_transform(crs) %>%
  st_as_sf() %>%
  rename(geometry = x)

# Reshape and rename Cook County ACS data so that each column represents 
# a different ACS variable
cook_acs <- cook_acs_raw %>%
  # Retain only relevant columns
  select(GEOID, NAME, variable, estimate, geometry) %>%
  # Transform data to wide format
  pivot_wider(
    names_from = variable,
    values_from = estimate
  ) %>%
  
  # Rename ACS variables
  select(GEOID,
         race_total_population = B02001_001,
         race_white_population = B02001_002,
         race_black_population = B02001_003,
         race_hispanic_population = B03002_003,
         median_income = B19013_001,
         poverty_population = B17001_002,
         poverty_total_population = B17001_001,
         median_rent = B25064_001
         ) %>%
  st_transform(crs)


# CTA stops run outside of the City so select only stops that lie within the 
# City limits
cta_stops <- cta_stops_raw %>%
  st_transform(crs) %>%
  st_intersection(chicago_boundary)

# Select all ACS data that is just within the City Limits of Chicago
chicago_acs <- st_intersection(cook_acs, chicago_boundary)




