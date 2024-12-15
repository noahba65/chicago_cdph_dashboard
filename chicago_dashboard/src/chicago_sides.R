# There are no shapefiles for the unofficial "sides" of Chicago. This script
# creates an sf object grouped by the different community areas on each respective
# side. This creates an sf object based on this map from Wikipedia https://en.wikipedia.org/wiki/Community_areas_in_Chicago

far_north_side <- c("OHARE", "EDISON PARK", "NORWOOD PARK", "FOREST GLEN",
                    "NORTH PARK", "ALBANY PARK", "WEST RIDGE", "LINCOLN SQUARE",
                    "ROGERS PARK", "EDGEWATER", "UPTOWN", "JEFFERSON PARK")

northwest_side <- c("DUNNING", "PORTAGE PARK", "IRVING PARK", "HERMOSA",
                    "MONTCLARE", "BELMONT CRAGIN")

north_side <- c("AVONDALE", "LOGAN SQUARE", "NORTH CENTER", "LAKE VIEW",
                "LINCOLN PARK")

west_side <- c("AUSTIN", "HUMBOLDT PARK", "WEST TOWN", "WEST GARFIELD PARK",
               "EAST GARFIELD PARK", "NEAR WEST SIDE", "NORTH LAWNDALE", "SOUTH LAWNDALE", 
               "LOWER WEST SIDE")

south_west_side <- c("GARFIELD RIDGE", "ARCHER HEIGHTS", "BRIGHTON PARK", 
                     "MCKINLEY PARK", "NEW CITY", "WEST ENGLEWOOD", "ENGLEWOOD",
                     "WEST ELSDON", "GAGE PARK", "WEST LAWN", "CHICAGO LAWN", 
                     "WEST LAWN", "CLEARING")

far_south_west_side <- c("ASHBURN", "AUBURN GRESHAM", "WASHINGTON HEIGHTS",
                         "BEVERLY", "MOUNT GREENWOOD", "MORGAN PARK")

far_south_east_side <- c("CHATHAM", "AVALON PARK", "BURNSIDE", "ROSELAND", "WEST PULLMAN",
                         "RIVERDALE", "PULLMAN", "CALUMET HEIGHTS", "SOUTH DEERING",
                         "HEGEWISCH", "EAST SIDE", "SOUTH CHICAGO")

south_side <- c("BRIDGEPORT", "ARMOUR SQUARE", "FULLER PARK", "DOUGLAS", "GRAND BOULEVARD",
                "WASHINGTON PARK", "GREATER GRAND CROSSING", "OAKLAND", "KENWOOD",
                "HYDE PARK", "WOODLAWN", "SOUTH SHORE", "BURNSIDE")

central <- c("NEAR NORTH SIDE", "LOOP", "NEAR SOUTH SIDE")

chicago_sides_ca <- ca_boundaries_raw %>%
  st_transform(crs) %>%
  mutate(side = case_when(
    community %in% far_north_side ~ "Far North Side",
    community %in% northwest_side ~ "Northwest Side",
    community %in% north_side ~ "North Side",
    community %in% west_side ~ "West Side",
    community %in% south_west_side ~ "Southwest Side",
    community %in% far_south_west_side ~ "Far Southwest Side",
    community %in% far_south_east_side ~ "Far Southeast Side",
    community %in% south_side ~ "South Side",
    community %in% central ~ "Central",
    TRUE ~ NA_character_  # Assign NA for any community that does not match
  ))  



# Initialize an empty list to store individual side_sf objects
final_sf <- list()

chicago_sides_list <- c("Far North Side", "Northwest Side", "North Side", 
                        "West Side", "Southwest Side", "Far Southwest Side", 
                        "Far Southeast Side", "South Side", "Central")

# Each "side" still has the community area boundaries so this loop creates sf 
# objects for the union of each side and appends them into one object 
for (side_name in chicago_sides_list) {
  # Dynamically create the variable name and store the result
  side_sf <- chicago_sides_ca %>%
    filter(side == side_name) %>%
    st_union() %>%
    st_as_sf() %>%
    rename(geometry = x) %>%
    mutate(side = side_name)
  
  # Append the result to the list
  final_sf <- append(final_sf, list(side_sf))
}

# Combine all side_sf objects into a single sf object
chicago_sides <- do.call(rbind, final_sf)

  
