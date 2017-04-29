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

natVisDF = query(
  data.world(token = "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJwcm9kLXVzZXItY2xpZW50OmpvbmF0aGFua2tpemVyIiwiaXNzIjoiYWdlbnQ6am9uYXRoYW5ra2l6ZXI6OjlkOWM5MDBlLTc0N2MtNDM5Yi04YmVhLWYwMTRjMzVkZjY1YiIsImlhdCI6MTQ4NDY5NzI4NCwicm9sZSI6WyJ1c2VyX2FwaV93cml0ZSIsInVzZXJfYXBpX3JlYWQiXSwiZ2VuZXJhbC1wdXJwb3NlIjp0cnVlfQ.xVPkWdDyKxmAd6GK2KN8DxRZZCNk23snYhMAgoaMhmPsNO-2XuNQwAwLE2EXyTaJV9xPWg52am1_RmfmUqezVQ", propsfile = "www/.data.world"),
  dataset="jonathankkizer/s-17-dv-final-project", type="sql",
  query="SELECT * FROM NatVisDF s join `censusInfo.csv/censusInfo` r ON (s.State = r.State) join `stateLatLong.csv/stateLatLong` l ON (s.State = l.STATE)"
)

shinyServer(function(input, output) { 
  # These widgets are for the Barcharts tab.
  online2 = reactive({input$rb2})
  # Pulls data for data tab, rest of tabs; joins census data to national parks data
  df2 <- eventReactive(input$click2, {
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
  
  
  

  output$barchartMap1 <- renderLeaflet({leaflet() %>% 
      setView(lng = -98.35, lat = 39.5, zoom = 4) %>% 
      addTiles() %>%
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
