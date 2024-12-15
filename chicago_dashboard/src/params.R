
# This sets the spatial operations to use the GEOS package, 
# which operates in 2D preventing 3D calculations which  helps prevent duplicate vertex errors.
sf_use_s2(FALSE)

# Select variables from the American Community Surveys study
# Note that there are multiple total population variables since the ACS keeps track
# of what the response rate was for each question 
acs_vars <-  c(
  "B02001_001",  # Total race population
  "B02001_002",  # White population
  "B02001_003",  # Black or African American population
  "B03002_003",  # Hispanic or Latino population
  "B19013_001",  # Median household income
  "B17001_002",  # Total in poverty
  "B17001_001",  # Total population of those asked about poverty
  "B25064_001")   # Median Rent



# Set Coordinate Reference System
crs <- 3435

# Set how far out the buffer for CTA stops will be in feet. 
buffer_zone <- 5280 / 2