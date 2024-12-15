# Create a unioned buffer zone around CTA stops
cta_buffers <- st_union(st_buffer(cta_stops, buffer_zone)) %>%  # Buffer CTA stops by buffer_zone distance and merge overlapping buffers
  st_sf()  # Convert the resulting object to an sf (spatial features) object

# Create a TOD (Transit-Oriented Development) ACS object with two groups: TOD and Non-TOD
tod_acs <- rbind(
  # Group 1: TOD tracts (centroids within the CTA buffer)
  st_centroid(chicago_acs)[cta_buffers, ] %>%  # Get centroids of ACS geometries that intersect with CTA buffers
    st_drop_geometry() %>%  # Drop geometry temporarily
    select(GEOID) %>%  # Select GEOID (identifier for the census tract)
    left_join(chicago_acs, by = "GEOID") %>%  # Rejoin full ACS data by GEOID
    st_sf() %>%  # Convert back to sf object
    mutate(tod = "TOD"),  # Add a column marking these tracts as "TOD"
  
  # Group 2: Non-TOD tracts (centroids outside the CTA buffer)
  st_centroid(chicago_acs)[cta_buffers, op = st_disjoint] %>%  # Find centroids that do NOT intersect with CTA buffers
    st_drop_geometry() %>%  # Drop geometry temporarily
    select(GEOID) %>%  # Select GEOID
    left_join(chicago_acs, by = "GEOID") %>%  # Rejoin full ACS data by GEOID
    st_sf() %>%  # Convert back to sf object
    mutate(tod = "Non-TOD")  # Add a column marking these tracts as "Non-TOD"
) %>%
  # Add the 'side' variable to the TOD sf object using a spatial join
  st_join(chicago_sides, left = TRUE) %>%  # Join with 'chicago_sides' data to assign sides
  st_as_sf()  # Ensure the final object remains an sf object

# Summarize TOD data city-wide by calculating key statistics for each TOD group
tod_acs_summary_city_wide <- tod_acs %>%
  st_drop_geometry() %>%  # Drop geometry to enable summary calculations
  group_by(tod) %>%  # Group data by TOD status ("TOD" or "Non-TOD")
  summarise(
    `Percent White` = sum(race_white_population) / sum(race_total_population),  # Percentage of White population
    `Percent Black` = sum(race_black_population) / sum(race_total_population),  # Percentage of Black population
    `Percent Latine` = sum(race_hispanic_population) / sum(race_total_population),  # Percentage of Latine population
    `Median Yearly Income` = median(median_income, na.rm = TRUE),  # Median yearly income
    `Median Rent` = median(median_rent, na.rm = TRUE),  # Median rent
    `Percent in Poverty` = sum(poverty_population) / sum(poverty_total_population)  # Percentage of population in poverty
  ) %>%
  mutate(side = "City Wide")  # Add a "City Wide" side label to the data

# Summarize TOD data by sides
tod_acs_summary_by_side <- tod_acs %>%
  st_drop_geometry() %>%  # Drop geometry for summary calculations
  group_by(tod, side) %>%  # Group by TOD status and side
  summarise(
    `Percent White` = sum(race_white_population) / sum(race_total_population),  # Percentage of White population
    `Percent Black` = sum(race_black_population) / sum(race_total_population),  # Percentage of Black population
    `Percent Latine` = sum(race_hispanic_population) / sum(race_total_population),  # Percentage of Latine population
    `Median Yearly Income` = median(median_income, na.rm = TRUE),  # Median yearly income
    `Median Rent` = median(median_rent, na.rm = TRUE),  # Median rent
    `Percent in Poverty` = sum(poverty_population) / sum(poverty_total_population)  # Percentage of population in poverty
  ) %>%
  mutate(
    side = factor(  # Convert 'side' column to a factor with specified order
      side,
      levels = c("Far North Side", "Northwest Side", "North Side", "Central", "West Side",
                 "Southwest Side", "Far Southwest Side", "South Side", "Far Southeast Side", "City Wide")
    )
  )

# Combine the city-wide summary and side-level summary into a single dataframe
tod_acs_summary <- rbind(tod_acs_summary_by_side, tod_acs_summary_city_wide)

# Union the geometries for TOD tracts to create a single spatial feature
tod_tracts_union <- tod_acs %>%
  filter(tod == "TOD") %>%  # Filter for "TOD" tracts
  st_union() %>%  # Combine all geometries into one unioned feature
  st_as_sf() %>%  # Convert back to sf object
  mutate(tod = "TOD") %>%  # Add a column for TOD
  rename(geometry = x)  # Rename the geometry column to 'geometry'

# Union the geometries for Non-TOD tracts to create a single spatial feature
non_tod_tracts_union <- tod_acs %>%
  filter(tod == "Non-TOD") %>%  # Filter for "Non-TOD" tracts
  st_union() %>%  # Combine all geometries into one unioned feature
  st_as_sf() %>%  # Convert back to sf object
  mutate(tod = "Non-TOD") %>%  # Add a column for Non-TOD
  rename(geometry = x)  # Rename the geometry column to 'geometry'

# Combine the unioned TOD and Non-TOD geometries into a single spatial dataframe
tod_plot_sf <- rbind(tod_tracts_union, non_tod_tracts_union) %>%
  st_join(chicago_sides)  # Join with 'chicago_sides' data to add the side variable
