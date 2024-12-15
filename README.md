# Chicago Transit Analysis 
This project is an interactive dashboard using American Community Survey (ACS) data to visualize differeneces in areas within a halfmile of CTA rail lines in the City ofo Chicago, and areas that are a halfmile outside this buffer. This project builds a lot from the examples and code done in Ken Steif's book [Public Policy Analytics: Code & Context for Data Science in Government](https://urbanspatial.github.io/PublicPolicyAnalytics/) which is a greate resource for geospatial analytics for public sector data science. 

# Importing the Data
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


## Chicago Community Areas and Broader Regions
Chicago is officially divided into **77 Community Areas**, a system established by the University of Chicago in the 1920s. These Community Areas serve as stable geographic boundaries for analysis, planning, and research. The boundary data used in this project is available on the [Chicago Data Portal](https://data.cityofchicago.org/Facilities-Geographic-Boundaries/Boundaries-Community-Areas-current-/cauq-8yn6).

While there are no *official* broader regions of Chicago, commonly used regional groupings exist. For this project, the "Chicago Sides" shapefile was created to group Community Areas into familiar broader regions (e.g., North Side, South Side, West Side). These groupings were based on the map below, accessed from [Wikimedia Commons](https://commons.wikimedia.org/wiki/File:Chicago_community_areas_map.svg):

![Map of Chicago Sides](figs/Chicago_community_areas_map.svg)

## Data Cleaning and Standardization  
After importing all datasets, the following broad cleaning steps were performed in `cleaning.R`:  

- **Coordinate Reference System (CRS) Standardization**:  
  All spatial data were standardized to the **EPSG:3435** coordinate system (NAD83 / Illinois East, ftUS). This projection ensures accuracy when analyzing spatial data within the City of Chicago by minimizing distortion and providing precise local measurements.  

- **Clipping to Chicago Boundaries**:  
  Both the ACS data and the CTA stops shapefile extend beyond Chicago's official boundaries. Using the **sf** package, all datasets were intersected with the Chicago boundary shapefile to retain only data within the city limits.  

- **Constructing the "Chicago Sides" Spatial Object**:  
  In a separate script, [`chicago_sides.R`](chicago_dashboard/src/sides.R), the unofficial "sides" of Chicago were created by grouping Community Areas into broader regions (e.g., North Side, West Side) using the **sf** package and union operations. This custom spatial object enables regional-level analysis and visualization.  


## Constructing the Analysis Dataset  
Once the data were cleaned, the analysis dataset was constructed by grouping census tracts based on **Chicago side** (e.g., North Side, South Side) and their proximity to CTA train lines (within or beyond a half-mile radius). Key summary metrics were calculated:  

- **Percent White**: Proportion of the White population relative to the total population.  
- **Percent Black**: Proportion of the Black population relative to the total population.  
- **Percent Latine**: Proportion of the Hispanic/Latine population relative to the total population.  
- **Median Yearly Income**: Median household income, excluding missing values.  
- **Median Rent**: Median gross rent, excluding missing values.  
- **Percent in Poverty**: Proportion of the population living below the poverty threshold.  

This grouping and metric calculation process is implemented in the [`build_tod.R`](chicago_dashboard/src/build_tod.R) script.  

To further analyze spatial rent trends, a separate script, [`rent_rings.R`](chicago_dashboard/src/rent_rings.R), creates **incremental half-mile buffers** around CTA train stops. At each buffer distance, the median rent is calculated, enabling the visualization of rent patterns as a function of proximity to train lines. This analysis is presented in a line plot to illustrate how rent values change with increasing distance from train stops.  

## Building the Dashboard  
The final product is an interactive data dashboard that allows users to explore various demographic and economic factors within different areas of Chicago. The dashboard provides the following functionality:

- **Variable Selection**: Users can choose from several key metrics for analysis, including:  
  - **Percent White**  
  - **Percent Black**  
  - **Percent Latine**  
  - **Median Yearly Income**  
  - **Median Rent**  
  - **Percent in Poverty**  

- **Data Visualization**: Once the user selects a variable, the dashboard displays a bar chart comparing the selected variable across different Chicago regions, including the areas within a half-mile of CTA rail stops (transit-oriented areas) and those outside of this buffer (non-transit areas). This allows for an easy comparison of demographic and economic characteristics by proximity to public transit.

- **Rent Trend Visualization**: The dashboard also features a line chart that illustrates how **median rent** changes as distance from CTA train stops increases. This chart visualizes rent trends as users interact with different areas, helping to highlight spatial patterns of rent variations near transit hubs.

By offering these visualizations, the dashboard facilitates a deeper understanding of how proximity to public transportation influences socio-economic factors in Chicago.
