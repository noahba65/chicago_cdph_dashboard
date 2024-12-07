library(shiny)
library(RSocrata)
library(tidyverse)
library(sf)


source("src/import.R")

source("src/cleaning.R")

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Chicago Data Dashboard"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
          selectizeInput("target_ca",
                        "Select Community Areas to compare:",
                        multiple = TRUE,
                        choices = c(ca_snapshot$geog),
                        options = list(maxItems = 2, placeholder = 'Select up to two community areas')
                        
                        )
        ),

        # Show a plot of the generated distribution
        mainPanel(
           plotOutput("heat_map", height = "600px", width = "100%"),
           plotOutput("pop_bar_chart"),
           tableOutput("summary_table")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$heat_map <- renderPlot({
      
      ca_snapshot %>%
        mutate(target_ca = ifelse(geog %in% input$target_ca, TRUE, FALSE),
               target_ca_label = ifelse(target_ca, geog, NA)) %>%
        ggplot() +
        geom_sf(aes(geometry = geometry, fill = target_ca)) +
        scale_fill_manual(values = c("TRUE" = "#E4002B", "FALSE" = "#FFFFFF")) + 
        geom_sf_label(aes(label = target_ca_label, geometry = geometry), size = 3, color = "black") + # Add labels
        theme(
          legend.position = "none",
          panel.grid = element_blank(),  # Ensures grid lines are removed
          axis.text = element_blank(),   # Removes axis text
          axis.title = element_blank(),  # Removes axis title
          axis.ticks = element_blank()   # Removes axis ticks
        )
    })
    
    
    output$pop_bar_chart <- renderPlot({
      
    
      # Plot the data
      ca_snapshot %>%
        filter(geog %in% input$target_ca) %>%
        ggplot(aes(x = geog, y = tot_pop, fill = geog)) +   # Use geog as the fill variable
        scale_fill_manual(values = c("#E4002B", "#41B6E6")) + 
        geom_col() +
        theme(
          legend.position = "none",
          panel.grid = element_blank(),  # Ensures grid lines are removed
          axis.title = element_blank(),  # Removes axis title
          axis.ticks = element_blank()   # Removes axis ticks
        )
    
      
      })
    
    output$summary_table <- renderTable(ca_snapshot %>%
                                  filter(geog %in% input$target_ca) %>%
                                  rename(
                                    `Total Population` = tot_pop,
                                    `Median Age` = med_age,
                                    `Median Rent` = med_rent,
                                    `Median Income` = medinc
                                  )  %>%
                                  select(geog, `Total Population`, `Median Age`,  `Median Rent`, `Median Income`) %>%
                                  pivot_longer(cols = `Total Population`:`Median Income` , names_to = "Variable", values_to = "value") %>%
                                  pivot_wider(names_from = geog, values_from = value)
                                )
    
    
    
    
}

# Run the application 
shinyApp(ui = ui, server = server)
