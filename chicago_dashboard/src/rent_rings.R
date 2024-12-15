# Create rent rings (buffer zones around CTA stops) and calculate median rent for each distance ring
rent_rings <- 
  st_join(  # Perform a spatial join
    st_centroid(dplyr::select(chicago_acs, GEOID)),  # Get centroids of census tracts (GEOID) from chicago_acs data
    multipleRingBuffer(  # Create multiple concentric buffer zones around CTA stops
      st_union(cta_stops),  # Union all CTA stops into a single geometry
      5280 * 2,  # Maximum buffer distance: 2 miles (5280 feet/mile * 2)
      5280 / 2   # Buffer increment: 0.5 miles (5280 feet / 2)
    )
  ) %>%
  st_drop_geometry() %>%  # Drop spatial geometry to work with attribute data
  left_join(  # Join median rent data back to the buffer data
    dplyr::select(chicago_acs, GEOID, median_rent),  # Select GEOID and median_rent columns from chicago_acs
    by = c("GEOID" = "GEOID")  # Join on the GEOID column
  ) %>%
  st_sf() %>%  # Convert back to an sf (spatial features) object
  mutate(distance = distance / 5280)  # Convert buffer distances from feet to miles

# Summarize median rent for each buffer ring city-wide
rent_rings_city_wide <- rent_rings %>%
  st_join(chicago_sides, left = TRUE) %>%  # Spatially join chicago_sides data to add "side" information
  group_by(distance) %>%  # Group data by buffer distance (rings)
  summarize(median_rent = median(median_rent, na.rm = TRUE)) %>%  # Calculate median rent for each distance
  mutate(side = "City Wide")  # Add a "City Wide" label to the summary data

# Summarize median rent for each buffer ring by side
rent_rings_by_side <- rent_rings %>%
  st_join(chicago_sides, left = TRUE) %>%  # Spatially join chicago_sides data to add "side" information
  group_by(distance, side) %>%  # Group data by buffer distance and side
  summarize(median_rent = median(median_rent, na.rm = TRUE))  # Calculate median rent for each group
