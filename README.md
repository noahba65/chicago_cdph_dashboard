# Chicago Transit Analysis 

This project is an interactive dashboard using American Community Survey (ACS) data to visualize differeneces in areas within a halfmile of CTA rail lines in the City ofo Chicago, and areas that are a halfmile outside this buffer. This project builds a lot from the examples and code done in Ken Steif's book [Public Policy Analytics: Code & Context for Data Science in Government](https://urbanspatial.github.io/PublicPolicyAnalytics/) which is a greate resource for geospatial analytics for public sector data science. 

# Data Sets
## ACS Data
Using the `tidycensus` package, the ACS five year survey ending in 2019 is read in. The following variables are selected:

| **Variable**               | **ACS Code** | **Description**                                  |
|----------------------------|--------------|-------------------------------------------------|
| `race_total_population`    | B02001_001   | Total Population: ACS Five-Year Survey (2019).   |
| `race_white_population`    | B02001_002   | White Population: ACS Five-Year Survey (2019).   |
| `race_black_population`    | B02001_003   | Black Population: ACS Five-Year Survey (2019).   |
| `race_hispanic_population` | B03002_003   | Hispanic/Latine Population: ACS Five-Year Survey (2019). |
| `median_income`            | B19013_001   | Median Household Income: ACS Five-Year Survey (2019). |
| `poverty_population`       | B17001_002   | Population in Poverty: ACS Five-Year Survey (2019). |
| `poverty_total_population` | B17001_001   | Total Population for Poverty Estimate: ACS Five-Year Survey (2019). |
| `median_rent`              | B25064_001   | Median Gross Rent: ACS Five-Year Survey (2019).  |

## CTA Stops
The shapefile for CTA L (Elevated Rail) stops was sourced from the [Chicago Data Portal](https://data.cityofchicago.org/Transportation/CTA-L-Rail-Lines/xbyr-jnvx/about_data) and downloaded in GeoJSON format. Locally, it is stored in the [data](chicago_dashboard/data) directory and can be imported using the [import.R](chicago_dashboard/src/import.R) script. This file contains point geometries representing each CTA L stop, which are used to identify census tracts located within a half-mile radius of these stops. 

## Chicago Community Area Boundaries
Chicago is divided into 77 official Community Areas as established by the University of Chicago in the 1920s. These Community Areas were then used to group by "side" of Chicago to create a broder region shape file. The boundaries used in this project can be found on the [Chicago Data Portal](https://data.cityofchicago.org/Facilities-Geographic-Boundaries/Boundaries-Community-Areas-current-/cauq-8yn6). 

![CTA Map](figs/cta_map.png)



