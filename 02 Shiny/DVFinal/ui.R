#ui.R
require(shiny)
require(shinydashboard)
require(DT)
require(leaflet)
require(plotly)

dashboardPage(
  dashboardHeader(
  ),
  dashboardSidebar(
    sidebarMenu(
      menuItem("National Parks Data", tabName = "barchart", icon = icon("dashboard"))
    )
  ),
  dashboardBody(    
    tabItems(
      # Begin Barchart tab content.
      tabItem(tabName = "barchart",
              tabsetPanel(
                tabPanel("Data",  
                         uiOutput("regions2"), # See http://shiny.rstudio.com/gallery/dynamic-ui.html
                         actionButton(inputId = "click2",  label = "To get data, click here"),
                         hr(), # Add space after button.
                         'Here is the National Parks Visitation data, joined with the Census Info. Pull the data before viewing plots.',
                         hr(),
                         DT::dataTableOutput("barchartData1")
                ),
                tabPanel("Visits by State, Colored by Year", plotOutput("barchartPlot1", height=2500)),
                tabPanel("Map", leafletOutput("barchartMap1"), height=900 ),
                tabPanel("Visits by Region, Colored by Year", plotOutput("barchartPlot2", height=700) )
              )
      )
      # End Barchart tab content.
    )
  )
)

