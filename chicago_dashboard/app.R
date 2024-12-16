library(shiny)
library(RSocrata)
library(tidyverse)
library(sf)
library(tidycensus)
library(mapview)
library(leaflet)
library(glue)
library(ggrepel)

# census_api_key("YOUR KEY HERE", install = TRUE, overwrite = TRUE)

source("src/params.R")

source("src/functions.R")

source("src/import.R")

source("src/cleaning.R")

source("src/chicago_sides.R")

source("src/build_tod_sf.R")

source("src/rent_rings.R")

ui <- fluidPage(
  # Application title
  titlePanel("Chicago Data Dashboard"),
  # Add a documentation tab/link
  fluidRow(
    column(
      width = 12,
      tags$div(
        style = "text-align: left; margin-top: 10px; margin-bottom: 10px;",
        tags$a(
          href = "https://github.com/noahba65/chicago_dashboard/blob/main/README.md", 
          target = "_blank", 
          "Click here to view documentation",
          style = "font-size: 18px; font-weight: bold; color: #005899; text-decoration: none;"
        )
      )
    )
  ),
  
  
  # First row: Select Area and its corresponding map
  fluidRow(
    column(
      width = 2,  # Sidebar width
      checkboxGroupInput(
        "selected_areas", 
        "Select Area:", 
        choices = c("Far North Side", "Northwest Side", "North Side", "Central", 
                    "West Side", "Southwest Side", "Far Southwest Side", "South Side", 
                    "Far Southeast Side"),
        selected = NULL  # Initially no areas selected
      )
    ),
    column(
      width = 5,  # Main panel width
      plotOutput("selected_area_map")
    ),
    column(
      width = 5,
      plotOutput("tod_map")
    )
  ),
  
  # Second row: Select Variable and its corresponding bar chart
  fluidRow(
    column(
      width = 2,  # Sidebar width
      radioButtons(
        "selected_variable", 
        "Select Variable:", 
        choices = c("Percent White", "Percent Black", "Percent Latine", 
                    "Percent in Poverty", "Median Yearly Income", "Median Rent"),
        selected = NULL  # Initially no variable selected
      )
    ),
    column(
      width = 10,  # Main panel width
      plotOutput("indicator_bar_plot")
    ), 
    column(width = 10,
           plotOutput("rent_line_plot") 
           )
  )
)



# Define server logic
server <- function(input, output, session) {
  
  
  
  # Custom color palette with Chicago branded colors 
  chicago_color_pallete <- c("#41B6E6", "#510C76", "#EF002B",
                             "#005899", "#fff1d2", "#FBD9DF",
                             "#fdb81e", "#981b1e", "#E1F3F8", "grey")  
  
  # Reactive value to store selected community area
  selected_areas <- reactiveVal(character())
  
  # Observe the dropdown selection and update the reactive value
  observeEvent(input$selected_areas, {
    selected_areas(input$selected_areas)
  })
  
  # Render the plot based on selected areas
  output$selected_area_map <- renderPlot({
    chicago_sides %>%
      rbind(chicago_boundary %>% mutate(side = "City Wide")) %>%
      filter(side %in% input$selected_areas) %>%
      ggplot() +
      geom_sf(data = chicago_boundary, aes(geometry = geometry)) +
      geom_sf(aes(geometry = geometry, fill = side))  +
      scale_fill_manual(values = chicago_color_pallete) +
      # Add labels for each selected  side
      geom_sf_label(aes(label = side), size = 3, color = "black", fontface = "bold") +
      ggtitle("Selected Area Plot") +
      labs(x = "", y = "") +
      theme_minimal() +
      theme(
        legend.position = "none",   # Hide the legend
        panel.grid = element_blank(),
        axis.text = element_blank(),
        plot.title = element_text(face = "bold", size = 30),
        axis.ticks = element_blank(),
        panel.border = element_blank(),
        plot.margin = margin(0, 0, 0, 0)
      )
  })
  
  output$tod_map <- renderPlot({
    
    # Plot the Transit Oriented Development Map
    tod_plot_sf %>%
      ggplot() +
      geom_sf(aes(geometry = geometry, fill = tod))  +
      scale_fill_manual(values = c("Non-TOD" = "#41B6E6", "TOD" = "#EF002B")) +
      ggtitle("Transit Oriented Area Map") +
      labs(x = "", y = "", fill = "TOD") +
      theme_minimal() +
      theme(
        panel.grid = element_blank(),
        axis.text = element_blank(),
        plot.title = element_text(face = "bold", size = 30),
        axis.ticks = element_blank(),
        panel.border = element_blank(),
        legend.title = element_text(18, face = "bold"),
        legend.text = element_text(size = 16),
        plot.margin = margin(0, 0, 0, 0)
      )
    
    
  })
  
  
  output$indicator_bar_plot <- renderPlot({
    
    selected_variable <- input$selected_variable
    
    # If the variable contains the word percent, createa a percent bar chart
    if(str_detect(selected_variable, "Percent")){
      tod_acs_summary %>%
        mutate(label = round(!!sym(selected_variable), 2) * 100,
               label = glue("{label}%")) %>% 
        filter(side %in% c(input$selected_areas, "City Wide")) %>%
        ggplot() +
        geom_col(aes(x = side, y = !!sym(selected_variable), fill = tod),
                 position = "dodge") +
        scale_y_continuous(labels = scales::percent_format())  +
        ggtitle("Indicator Bart Chart") +
        geom_label(
          aes(label = label, x = side, y = !!sym(selected_variable), group = tod),
          position = position_dodge(width = 0.9),  # Apply the same dodge as in geom_col
          size = 4,  # Adjust size if necessary
          label.padding = unit(0.1, "lines") ) +
        labs(fill = "TOD") +
        scale_fill_manual(values = c("Non-TOD" = "#41B6E6", "TOD" = "#EF002B")) +
        theme(
          panel.grid = element_blank(),          
          plot.title = element_text(face = "bold", size = 35),
          axis.title = element_text(size = 18),
          axis.text = element_text(size = 14),
          axis.text.x = element_text(angle = 45, vjust = .9, hjust = .9),
          legend.title = element_text(18, face = "bold"),
          legend.text = element_text(size = 14)
        )
      
    # If the variable does not contain the word percent, make the default bar chart
    } else{
      tod_acs_summary %>%
        mutate(label = round(!!sym(selected_variable)),
               label = glue("${label}")) %>% 
        filter(side %in% c(input$selected_areas, "City Wide")) %>%
        ggplot() +
        geom_col(aes(x = side, y = !!sym(selected_variable), fill = tod),
                 position = "dodge") +
        geom_label(
          aes(label = label, x = side, y = !!sym(selected_variable), group = tod),
          position = position_dodge(width = 0.9),  # Apply the same dodge as in geom_col
          size = 4,  # Adjust size if necessary
          label.padding = unit(0.1, "lines") ) +
        scale_fill_manual(values = c("Non-TOD" = "#41B6E6", "TOD" = "#EF002B")) +
        labs(fill = "TOD") +
        theme(
          panel.grid = element_blank(),          
          plot.title = element_text(face = "bold", size = 35),
          axis.title = element_text(size = 18),
          axis.text = element_text(size = 14),
          axis.text.x = element_text(angle = 45, vjust = .9, hjust = .9),
          legend.title = element_text(18, face = "bold"),
          legend.text = element_text(size = 14)
        )
    }
    
    
    
  })
  
  # Create rent line plot comparing rent as a function of distance to transit
  output$rent_line_plot <- renderPlot({
    rent_rings_by_side %>%
      filter(side %in% input$selected_areas) %>%
      rbind(rent_rings_city_wide) %>%
      ggplot() +
      geom_line( aes(x = distance, y = median_rent, color = side), linewidth = 2) +
      labs(color = "Side", y = "Median Rent ($)", x = "Distance from Train Stops (miles)") +
      scale_color_manual(values = chicago_color_pallete) +
      ggtitle("Change in Rent with Distance From Transit") +
      theme(
        panel.grid = element_blank(),          
        plot.title = element_text(face = "bold", size = 35),
        axis.title = element_text(size = 18),
        axis.text = element_text(size = 14),
        legend.title = element_text(18, face = "bold"),
        legend.text = element_text(size = 14)
      )
  })
}
# Add a nice tab somehwere on the UI that says "Documentation" linking to this https://github.com/noahba65/chicago_dashboard/blob/dev/README.md

# Run the application
shinyApp(ui = ui, server = server)

