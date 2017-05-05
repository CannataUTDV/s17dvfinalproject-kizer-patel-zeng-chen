# server.R
require(ggplot2)
require(dplyr)
require(shiny)
require(shinydashboard)
require(data.world)
require(readr)
require(DT)
require(leaflet)
require(plotly)
require(lubridate)

online0 = TRUE

natVisDF = query(
  data.world(token = "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJwcm9kLXVzZXItY2xpZW50OmpvbmF0aGFua2tpemVyIiwiaXNzIjoiYWdlbnQ6am9uYXRoYW5ra2l6ZXI6OjlkOWM5MDBlLTc0N2MtNDM5Yi04YmVhLWYwMTRjMzVkZjY1YiIsImlhdCI6MTQ4NDY5NzI4NCwicm9sZSI6WyJ1c2VyX2FwaV93cml0ZSIsInVzZXJfYXBpX3JlYWQiXSwiZ2VuZXJhbC1wdXJwb3NlIjp0cnVlfQ.xVPkWdDyKxmAd6GK2KN8DxRZZCNk23snYhMAgoaMhmPsNO-2XuNQwAwLE2EXyTaJV9xPWg52am1_RmfmUqezVQ", propsfile = "www/.data.world"),
  dataset="jonathankkizer/s-17-dvproject-6", type="sql",
  query="SELECT * FROM NatVisDF s join `censusInfo.csv/censusInfo` r ON (s.State = r.State) join `stateLatLong.csv/stateLatLong` l ON (s.State = l.STATE)"
)
############################### Start shinyServer Function ####################

shinyServer(function(input, output) {   
  
  # These widgets are for the Crosstabs tab.
  KPI_Low = reactive({input$KPI1})     
  KPI_Medium = reactive({input$KPI2})
  
  # Begin IV Plot Tab
  dfIV1 <-query(data.world(token = "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJwcm9kLXVzZXItY2xpZW50OmpvbmF0aGFua2tpemVyIiwiaXNzIjoiYWdlbnQ6am9uYXRoYW5ra2l6ZXI6OjlkOWM5MDBlLTc0N2MtNDM5Yi04YmVhLWYwMTRjMzVkZjY1YiIsImlhdCI6MTQ4NDY5NzI4NCwicm9sZSI6WyJ1c2VyX2FwaV93cml0ZSIsInVzZXJfYXBpX3JlYWQiXSwiZ2VuZXJhbC1wdXJwb3NlIjp0cnVlfQ.xVPkWdDyKxmAd6GK2KN8DxRZZCNk23snYhMAgoaMhmPsNO-2XuNQwAwLE2EXyTaJV9xPWg52am1_RmfmUqezVQ", propsfile = "www/.data.world"), 
                dataset="jonathankkizer/s-17-dv-final-project", type="sql", 
                query="SELECT YearRaw, sum(Visitors) as Visitors
                FROM NatVisDF 
                group by YearRaw
                order by YearRaw"
  )

  output$IV1 <- renderPlotly({
    dfIV1Gas <- query(data.world(token = "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJwcm9kLXVzZXItY2xpZW50OmpvbmF0aGFua2tpemVyIiwiaXNzIjoiYWdlbnQ6am9uYXRoYW5ra2l6ZXI6OjlkOWM5MDBlLTc0N2MtNDM5Yi04YmVhLWYwMTRjMzVkZjY1YiIsImlhdCI6MTQ4NDY5NzI4NCwicm9sZSI6WyJ1c2VyX2FwaV93cml0ZSIsInVzZXJfYXBpX3JlYWQiXSwiZ2VuZXJhbC1wdXJwb3NlIjp0cnVlfQ.xVPkWdDyKxmAd6GK2KN8DxRZZCNk23snYhMAgoaMhmPsNO-2XuNQwAwLE2EXyTaJV9xPWg52am1_RmfmUqezVQ", propsfile = "www/.data.world"), 
                      dataset="jonathankkizer/s-17-dv-final-project", type="sql", 
                      query="select Year as YearRaw, `GasPrices.csv/GasPrices`.`Retail Gasoline Price 
(Constant 2015 dollars/gallon)` as Price from GasPrices"
    )
    
    dfIV1 <- inner_join(dfIV1, dfIV1Gas)
    # Note: Previous idea of gas prices rising meant visitors fell disproven; Coefficient of Correlation of only ~.03
    #print(cor(dfIV1$Visitors, dfIV1$Price,  method = "pearson", use = "complete.obs"))
    p <- ggplot(data=dfIV1) + 
      geom_line(aes(x=YearRaw, y=Visitors)) + 
      scale_y_continuous(labels = scales::comma) +
      theme(axis.text.x=element_text(size=10, vjust=0.5))
    ggplotly(p)
  })
  
  dfIV2 <-query(data.world(token = "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJwcm9kLXVzZXItY2xpZW50OmpvbmF0aGFua2tpemVyIiwiaXNzIjoiYWdlbnQ6am9uYXRoYW5ra2l6ZXI6OjlkOWM5MDBlLTc0N2MtNDM5Yi04YmVhLWYwMTRjMzVkZjY1YiIsImlhdCI6MTQ4NDY5NzI4NCwicm9sZSI6WyJ1c2VyX2FwaV93cml0ZSIsInVzZXJfYXBpX3JlYWQiXSwiZ2VuZXJhbC1wdXJwb3NlIjp0cnVlfQ.xVPkWdDyKxmAd6GK2KN8DxRZZCNk23snYhMAgoaMhmPsNO-2XuNQwAwLE2EXyTaJV9xPWg52am1_RmfmUqezVQ", propsfile = "www/.data.world"), 
                dataset="jonathankkizer/s-17-dv-final-project", type="sql", 
                query="SELECT YearRaw, censusInfo.State as State, sum(Visitors) as Visitors, sum(Visitors) / censusInfo.population as Ratio FROM NatVisDF s join `censusInfo.csv/censusInfo` r ON (s.State = r.State) where YearRaw = 2016 group by censusInfo.State"
  )
  
  output$IV2 <- renderPlotly({
    p <- ggplot(data=dfIV2, aes(x=State, y=Visitors, fill = Ratio)) +
      geom_bar(stat = "identity") +
      scale_y_continuous(labels = scales::comma) +
      theme(axis.text.x=element_text(angle=90, size=10, vjust=0.5))
    ggplotly(p)
  })
  
  # Begin Box Plot Tab ------------------------------------------------------------------
  dfbp1 <- eventReactive(input$click1, {
    print("Getting from data.world")
    natVisDF = query(
      data.world(token = "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJwcm9kLXVzZXItY2xpZW50OmpvbmF0aGFua2tpemVyIiwiaXNzIjoiYWdlbnQ6am9uYXRoYW5ra2l6ZXI6OjlkOWM5MDBlLTc0N2MtNDM5Yi04YmVhLWYwMTRjMzVkZjY1YiIsImlhdCI6MTQ4NDY5NzI4NCwicm9sZSI6WyJ1c2VyX2FwaV93cml0ZSIsInVzZXJfYXBpX3JlYWQiXSwiZ2VuZXJhbC1wdXJwb3NlIjp0cnVlfQ.xVPkWdDyKxmAd6GK2KN8DxRZZCNk23snYhMAgoaMhmPsNO-2XuNQwAwLE2EXyTaJV9xPWg52am1_RmfmUqezVQ", propsfile = "www/.data.world"),
      dataset="jonathankkizer/s-17-dv-final-project", type="sql",
      query="SELECT YearRaw, stateLatLong.STATE as State, Visitors, Region, UnitType, avg_Visitors, sum_Visitors, stateLatLong.LATITUDE, stateLatLong.LONGITUDE, stateLatLong.Location FROM NatVisDF s join `censusInfo.csv/censusInfo` r ON (s.State = r.State) join `stateLatLong.csv/stateLatLong` l ON (s.State = l.STATE)"
    )
    print("Creating window, joining data")
    natVisDF1 = natVisDF %>% group_by(Region) %>% summarize(window_avg_visitors = mean(sum_Visitors))
    dplyr::inner_join(natVisDF, natVisDF1, by = "Region")
  }
  
  )
  
  output$boxplotData1 <- renderDataTable({DT::datatable(dfbp1(), rownames = FALSE,
                                                        extensions = list(Responsive = TRUE, 
                                                                          FixedHeader = TRUE)
  )
  })
  
  dfbp2 <- eventReactive(c(input$click1, input$boxVisitRange1), {
    dfbp1() %>% dplyr::filter(Visitors >= input$boxVisitRange1[1] & Visitors <= input$boxVisitRange1[2]) # %>% View()
  })
  
  output$boxplotPlot1 <- renderPlotly({
    #View(dfbp3())
    p <- ggplot(dfbp2()) + 
      geom_boxplot(aes(x=Region, y=Visitors, colour=YearRaw)) + 
      ylim(0, input$boxVisitRange1[2]) +
      scale_y_continuous(labels = scales::comma) +
      theme(axis.text.x=element_text(angle=90, size=10, vjust=0.5))
    ggplotly(p)
  })
  # End Box Plot Tab ___________________________________________________________
  
  # Begin Histogram Tab ------------------------------------------------------------------
  dfh1 <- eventReactive(input$click2, {
    print("Getting from data.world")
    natVisDF = query(
      data.world(token = "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJwcm9kLXVzZXItY2xpZW50OmpvbmF0aGFua2tpemVyIiwiaXNzIjoiYWdlbnQ6am9uYXRoYW5ra2l6ZXI6OjlkOWM5MDBlLTc0N2MtNDM5Yi04YmVhLWYwMTRjMzVkZjY1YiIsImlhdCI6MTQ4NDY5NzI4NCwicm9sZSI6WyJ1c2VyX2FwaV93cml0ZSIsInVzZXJfYXBpX3JlYWQiXSwiZ2VuZXJhbC1wdXJwb3NlIjp0cnVlfQ.xVPkWdDyKxmAd6GK2KN8DxRZZCNk23snYhMAgoaMhmPsNO-2XuNQwAwLE2EXyTaJV9xPWg52am1_RmfmUqezVQ", propsfile = "www/.data.world"),
      dataset="jonathankkizer/s-17-dv-final-project", type="sql",
      query="SELECT YearRaw, stateLatLong.STATE as State, Visitors, Region, UnitType, avg_Visitors, sum_Visitors, stateLatLong.LATITUDE, stateLatLong.LONGITUDE, stateLatLong.Location FROM NatVisDF s join `censusInfo.csv/censusInfo` r ON (s.State = r.State) join `stateLatLong.csv/stateLatLong` l ON (s.State = l.STATE)"
    )
    print("Creating window, joining data")
    natVisDF1 = natVisDF %>% group_by(Region) %>% summarize(window_avg_visitors = mean(sum_Visitors))
    dplyr::inner_join(natVisDF, natVisDF1, by = "Region")
  }
  
  )
  
  output$histogramData1 <- renderDataTable({DT::datatable(dfh1(), rownames = FALSE,
                                                          extensions = list(Responsive = TRUE, 
                                                                            FixedHeader = TRUE)
  )
  })
  
  output$histogramPlot1 <- renderPlotly({p <- ggplot(dfh1()) +
    geom_histogram(aes(x=Visitors)) +
    scale_x_continuous(labels = scales::comma) + 
    theme(axis.text.x=element_text(angle=90, size=10, vjust=0.5))
  ggplotly(p)
  })
  # End Histogram Tab ___________________________________________________________
  
  # Begin Scatter Plots Tab ------------------------------------------------------------------
  dfsc1 <- eventReactive(input$click3, {
    print("Getting from data.world")
    natVisDF = query(
      data.world(token = "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJwcm9kLXVzZXItY2xpZW50OmpvbmF0aGFua2tpemVyIiwiaXNzIjoiYWdlbnQ6am9uYXRoYW5ra2l6ZXI6OjlkOWM5MDBlLTc0N2MtNDM5Yi04YmVhLWYwMTRjMzVkZjY1YiIsImlhdCI6MTQ4NDY5NzI4NCwicm9sZSI6WyJ1c2VyX2FwaV93cml0ZSIsInVzZXJfYXBpX3JlYWQiXSwiZ2VuZXJhbC1wdXJwb3NlIjp0cnVlfQ.xVPkWdDyKxmAd6GK2KN8DxRZZCNk23snYhMAgoaMhmPsNO-2XuNQwAwLE2EXyTaJV9xPWg52am1_RmfmUqezVQ", propsfile = "www/.data.world"),
      dataset="jonathankkizer/s-17-dv-final-project", type="sql",
      query="SELECT YearRaw, stateLatLong.STATE as State, Visitors, Region, UnitType, avg_Visitors, sum_Visitors, stateLatLong.LATITUDE, stateLatLong.LONGITUDE, stateLatLong.Location FROM NatVisDF s join `censusInfo.csv/censusInfo` r ON (s.State = r.State) join `stateLatLong.csv/stateLatLong` l ON (s.State = l.STATE)"
    )
    print("Creating window, joining data")
    natVisDF1 = natVisDF %>% group_by(Region) %>% summarize(window_avg_visitors = mean(sum_Visitors))
    dplyr::inner_join(natVisDF, natVisDF1, by = "Region")
  }
  )
  output$scatterData1 <- renderDataTable({DT::datatable(dfsc1(), rownames = FALSE,
                                                        extensions = list(Responsive = TRUE, 
                                                                          FixedHeader = TRUE)
  )
  })
  output$scatterPlot1 <- renderPlotly({p <- ggplot(dfsc1()) + 
    theme(axis.text.x=element_text(angle=90, size=10, vjust=0.5)) + 
    theme(axis.text.y=element_text(size=10, hjust=0.5)) +
    scale_y_continuous(labels = scales::comma) +
    geom_point(aes(x=YearRaw, y=Visitors, colour=Region), size=1)
  ggplotly(p)
  })
  # End Scatter Plots Tab ___________________________________________________________
  
  # Begin Crosstab Tab ------------------------------------------------------------------
  dfct1 <- eventReactive(input$click4, {
    print("Getting from data.world")
    query(
      data.world(token = "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJwcm9kLXVzZXItY2xpZW50OmpvbmF0aGFua2tpemVyIiwiaXNzIjoiYWdlbnQ6am9uYXRoYW5ra2l6ZXI6OjlkOWM5MDBlLTc0N2MtNDM5Yi04YmVhLWYwMTRjMzVkZjY1YiIsImlhdCI6MTQ4NDY5NzI4NCwicm9sZSI6WyJ1c2VyX2FwaV93cml0ZSIsInVzZXJfYXBpX3JlYWQiXSwiZ2VuZXJhbC1wdXJwb3NlIjp0cnVlfQ.xVPkWdDyKxmAd6GK2KN8DxRZZCNk23snYhMAgoaMhmPsNO-2XuNQwAwLE2EXyTaJV9xPWg52am1_RmfmUqezVQ", propsfile = "www/.data.world"),
      dataset="jonathankkizer/s-17-dv-final-project", type="sql",
      query="select YearRaw as Year, State, Visitors, Region, UnitType, avg_Visitors, sum_Visitors,
      
      case
      when Visitors / avg_Visitors < ? then '03 Low'
      when Visitors / avg_Visitors < ? then '02 Medium'
      else '01 High'
      end AS kpi
      
      from NatVisDF
      group by UnitType
      ",
      queryParameters = list(KPI_Low(), KPI_Medium())
    ) # %>% View()
    
  })
  output$data1 <- renderDataTable({DT::datatable(dfct1(), rownames = FALSE,
                                                 extensions = list(Responsive = TRUE, FixedHeader = TRUE)
  )
  })
  output$plot1 <- renderPlot({ggplot(dfct1()) + 
      theme(axis.text.x=element_text(angle=90, size=10, vjust=0.5)) + 
      theme(axis.text.y=element_text(size=10, hjust=0.5)) +
      geom_text(aes(x=Region, y=UnitType, label=Visitors), size=4) +
      geom_tile(aes(x=Region, y=UnitType, fill=kpi), alpha=0.50)
  })
  # End Crosstab Tab ___________________________________________________________
  # Begin Barchart Tab ------------------------------------------------------------------
  df2 <- eventReactive(input$click5, {
    print("Getting from data.world")
    natVisDF = query(
      data.world(token = "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJwcm9kLXVzZXItY2xpZW50OmpvbmF0aGFua2tpemVyIiwiaXNzIjoiYWdlbnQ6am9uYXRoYW5ra2l6ZXI6OjlkOWM5MDBlLTc0N2MtNDM5Yi04YmVhLWYwMTRjMzVkZjY1YiIsImlhdCI6MTQ4NDY5NzI4NCwicm9sZSI6WyJ1c2VyX2FwaV93cml0ZSIsInVzZXJfYXBpX3JlYWQiXSwiZ2VuZXJhbC1wdXJwb3NlIjp0cnVlfQ.xVPkWdDyKxmAd6GK2KN8DxRZZCNk23snYhMAgoaMhmPsNO-2XuNQwAwLE2EXyTaJV9xPWg52am1_RmfmUqezVQ", propsfile = "www/.data.world"),
      dataset="jonathankkizer/s-17-dv-final-project", type="sql",
      query="SELECT YearRaw, stateLatLong.STATE as State, Visitors, Region, UnitType, avg_Visitors, sum_Visitors, stateLatLong.LATITUDE, stateLatLong.LONGITUDE, stateLatLong.Location FROM NatVisDF s join `censusInfo.csv/censusInfo` r ON (s.State = r.State) join `stateLatLong.csv/stateLatLong` l ON (s.State = l.STATE)"
    )
    print("Creating window, joining data")
    natVisDF1 = natVisDF %>% group_by(Region) %>% summarize(window_avg_visitors = mean(sum_Visitors))
    dplyr::inner_join(natVisDF, natVisDF1, by = "Region")
  })
  #Output for Data tab
  output$barchartData1 <- renderDataTable({DT::datatable(df2(),
                                                         rownames = FALSE,
                                                         extensions = list(Responsive = TRUE, FixedHeader = TRUE) )
  })
  # Plot for Tab
  
  output$barchartPlot1 <- renderPlot({ggplot(df2(), aes(x=State, y=sum_Visitors)) +
      scale_y_continuous(labels = scales::comma) + # no scientific notation
      theme(axis.text.x=element_text(angle=0, size=12, vjust=0.5)) + 
      theme(axis.text.y=element_text(size=12, hjust=0.5)) +
      geom_bar(stat = "identity") + 
      #facet_wrap(~Region) + 
      coord_flip() + 
      # Add sum_sales, and (sum_sales - window_avg_sales) label.
      geom_text(mapping=aes(x=State, y=sum_Visitors, label=round(sum_Visitors)),colour="black", hjust=-.5) +
      geom_text(mapping=aes(x=State, y=sum_Visitors, label=round(sum_Visitors - window_avg_visitors)),colour="blue", hjust=-2) +
      # Add reference line with a label.
      geom_hline(aes(yintercept = round(window_avg_visitors)), color="red") +
      geom_text(aes( -1, window_avg_visitors, label = window_avg_visitors, vjust = -.5, hjust = -.25), color="red")
  })
  #  output$barchartPlot1 <- renderPlot({ggplot(df2(), aes(x=State, y=sum_Visitors)) +
  #     geom_point(aes(color = sum_Visitors)) + 
  #    facet_wrap(~Region) + 
  #   scale_y_continuous(labels = scales::comma) + # no scientific notation 
  #  coord_flip() + 
  # geom_hline(aes(yintercept = round(avg_Visitors)), color="red")
  #})
  
  output$barchartMap1 <- renderLeaflet({leaflet(width = 400, height = 800) %>% 
      setView(lng = -98.35, lat = 39.5, zoom = 4) %>% 
      addTiles() %>% 
      #addProviderTiles("MapQuestOpen.Aerial") %>%
      addMarkers(lng = natVisDF$LONGITUDE,
                 lat = natVisDF$LATITUDE,
                 options = markerOptions(draggable = TRUE, riseOnHover = TRUE),
                 popup = as.character(paste(natVisDF$ParkName, 
                                            ", ", natVisDF$sum_Visitors,
                                            ", ", natVisDF$State)) )
  })
  
  output$barchartPlot2 <- renderPlot({ggplot(df2(), aes(x=Region, y=sum_Visitors)) +
      scale_y_continuous(labels = scales::comma) + 
      geom_point(aes(mapping = sum_Visitors, color = YearRaw)) + 
      theme(axis.text.x=element_text(angle=90, size=12, vjust=0.5))
  })
  # End Barchart Tab ___________________________________________________________
  
})
