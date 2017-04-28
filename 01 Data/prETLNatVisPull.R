require(dplyr)
require(data.world)



prETLNatVisDF <- query(
  data.world(token = "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJwcm9kLXVzZXItY2xpZW50OmpvbmF0aGFua2tpemVyIiwiaXNzIjoiYWdlbnQ6am9uYXRoYW5ra2l6ZXI6OjlkOWM5MDBlLTc0N2MtNDM5Yi04YmVhLWYwMTRjMzVkZjY1YiIsImlhdCI6MTQ4NDY5NzI4NCwicm9sZSI6WyJ1c2VyX2FwaV93cml0ZSIsInVzZXJfYXBpX3JlYWQiXSwiZ2VuZXJhbC1wdXJwb3NlIjp0cnVlfQ.xVPkWdDyKxmAd6GK2KN8DxRZZCNk23snYhMAgoaMhmPsNO-2XuNQwAwLE2EXyTaJV9xPWg52am1_RmfmUqezVQ", propsfile = "www/.data.world"),
  dataset="jonathankkizer/s-17-dv-final-project", type="sql",
  query="select YearRaw, Parkname as ParkName, Visitors, State, Region, Year as YearTime, `NatParksVisitationpreETL.csv/NatParksVisitationpreETL`.`Unit Name` as UnitName, `NatParksVisitationpreETL.csv/NatParksVisitationpreETL`.`Unit Code` as UnitCode, Geometry, `NatParksVisitationpreETL.csv/NatParksVisitationpreETL`.`Unit Type` as UnitType, `NatParksVisitationpreETL.csv/NatParksVisitationpreETL`.`Gnis Id` as GNIS from NatParksVisitationpreETL where YearRaw != 'Total' and Parkname != 'NA' order by YearRaw"
)

calcFieldsDF <- query(
  data.world(token = "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJwcm9kLXVzZXItY2xpZW50OmpvbmF0aGFua2tpemVyIiwiaXNzIjoiYWdlbnQ6am9uYXRoYW5ra2l6ZXI6OjlkOWM5MDBlLTc0N2MtNDM5Yi04YmVhLWYwMTRjMzVkZjY1YiIsImlhdCI6MTQ4NDY5NzI4NCwicm9sZSI6WyJ1c2VyX2FwaV93cml0ZSIsInVzZXJfYXBpX3JlYWQiXSwiZ2VuZXJhbC1wdXJwb3NlIjp0cnVlfQ.xVPkWdDyKxmAd6GK2KN8DxRZZCNk23snYhMAgoaMhmPsNO-2XuNQwAwLE2EXyTaJV9xPWg52am1_RmfmUqezVQ", propsfile = "www/.data.world"),
  dataset="jonathankkizer/s-17-dv-final-project", type="sql",
  query="SELECT State, avg(Visitors) as avg_Visitors, sum(Visitors) as sum_Visitors from NatParksVisitationpreETL group by State"
)

prETLNatVisDF <- inner_join(prETLNatVisDF, calcFieldsDF)

print("Success!")