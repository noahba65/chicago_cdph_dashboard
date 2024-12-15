

# ca_snapshot_raw <- read_csv("data/community_data_snapshots_2024.csv")
cta_stops_raw <- read_sf("data/CTA_L_Lines.geojson")

# Read in Chicago Boundary file
ca_boundaries_raw <- read_sf("data/boundaries_community_areas.geojson")

# Import ACS data with tidycensus
cook_acs_raw <- get_acs(
  geography = "tract", 
  variables = acs_vars, 
  state = "IL",
  county = "Cook",
  year = 2019,
  survey = "acs5",
  geometry = TRUE
)

