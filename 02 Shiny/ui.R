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
      menuItem("Box Plots", tabName = "boxplot", icon = icon("dashboard")),
      menuItem("Histograms", tabName = "histogram", icon = icon("dashboard")),
      menuItem("Scatter Plots", tabName = "scatter", icon = icon("dashboard")),
      menuItem("Crosstabs, KPIs, Parameters", tabName = "crosstab", icon = icon("dashboard")),
      menuItem("Barcharts, Table Calculations", tabName = "barchart", icon = icon("dashboard")),
      menuItem("Interesting Visualizations", tabName = "IV", icon = icon("dashboard"))
    )
  ),
  dashboardBody(
    tags$style(type="text/css",
               ".shiny-output-error { visibility: hidden; }",
               ".shiny-output-error:before { visibility: hidden; }"
    ),    
    tabItems(
      # Begin Interesting Visualizations tab content.
      tabItem(tabName = "IV",
              tabsetPanel(
                tabPanel("Visitor Correlations",
                         plotlyOutput("IV1", height = 500)
                ),
                tabPanel("Population Ratio",
                         plotlyOutput("IV2", height = 500)
                ),
                tabPanel("Map",
                         plotlyOutput("IV3", height = 500)
                )
              )
      ),
      # End IV content.
      # Begin Box Plots tab content.
      tabItem(tabName = "boxplot",
              tabsetPanel(
                tabPanel("Data",  
                         #radioButtons("rb5", "Get data from:",
                         #            c("SQL" = "SQL",
                         #             "CSV" = "CSV"), inline=T),
                         uiOutput("boxplotRegions"), # See http://shiny.rstudio.com/gallery/dynamic-ui.html,
                         actionButton(inputId = "click1",  label = "To get data, click here"),
                         hr(), # Add space after button.
                         DT::dataTableOutput("boxplotData1")
                ),
                tabPanel("Visitor Box Plot", 
                         sliderInput("boxVisitRange1", " Range:", # See https://shiny.rstudio.com/articles/sliders.html
                                     min = min(globals$Visitors), max = max(globals$Visitors), 
                                     value = c(min(globals$Visitors), max(globals$Visitors))),
                         plotlyOutput("boxplotPlot1", height=500))
              )
      ),
      # End Box Plots tab content.
      # Begin Histogram tab content.
      tabItem(tabName = "histogram",
              tabsetPanel(
                tabPanel("Data",  
                         
                         actionButton(inputId = "click2",  label = "To get data, click here"),
                         hr(), # Add space after button.
                         DT::dataTableOutput("histogramData1")
                ),
                tabPanel("Visitor Histogram", plotlyOutput("histogramPlot1", height=1000))
              )
      ),
      # End Histograms tab content.
      # Begin Scatter Plots tab content.
      tabItem(tabName = "scatter",
              tabsetPanel(
                tabPanel("Data",  
                         uiOutput("scatterStates"), # See http://shiny.rstudio.com/gallery/dynamic-ui.html,
                         actionButton(inputId = "click3",  label = "To get data, click here"),
                         hr(), # Add space after button.
                         DT::dataTableOutput("scatterData1")
                ),
                tabPanel("Visitor Scatter Plot", plotlyOutput("scatterPlot1", height=1000))
              )
      ),
      # End Scatter Plots tab content.
      # Begin Crosstab tab content.
      tabItem(tabName = "crosstab",
              tabsetPanel(
                tabPanel("Data",  
                         sliderInput("KPI1", "KPI_Low:", 
                                     min = 0, max = max(globals$Visitors)/mean(globals$avg_Visitors)/3,  value = .1),
                         sliderInput("KPI2", "KPI_Medium:", 
                                     min = max(globals$Visitors)/mean(globals$avg_Visitors)/3, max = 2*max(globals$Visitors)/mean(globals$avg_Visitors)/3,  value = .2),
                         actionButton(inputId = "click4",  label = "To get data, click here"),
                         hr(), # Add space after button.
                         DT::dataTableOutput("data1")
                ),
                tabPanel("Crosstab", plotOutput("plot1", height=1000))
              )
      ),
      # End Crosstab tab content.
      # Begin Barchart tab content.
      tabItem(tabName = "barchart",
              tabsetPanel(
                tabPanel("Data",  
                         uiOutput("regions2"), # See http://shiny.rstudio.com/gallery/dynamic-ui.html
                         actionButton(inputId = "click5",  label = "To get data, click here"),
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

