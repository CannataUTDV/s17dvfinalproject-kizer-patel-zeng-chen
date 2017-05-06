require(dplyr)
require(data.world)

dfIV1 <- query(
  data.world(token = "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJwcm9kLXVzZXItY2xpZW50OmpvbmF0aGFua2tpemVyIiwiaXNzIjoiYWdlbnQ6am9uYXRoYW5ra2l6ZXI6OjlkOWM5MDBlLTc0N2MtNDM5Yi04YmVhLWYwMTRjMzVkZjY1YiIsImlhdCI6MTQ4NDY5NzI4NCwicm9sZSI6WyJ1c2VyX2FwaV93cml0ZSIsInVzZXJfYXBpX3JlYWQiXSwiZ2VuZXJhbC1wdXJwb3NlIjp0cnVlfQ.xVPkWdDyKxmAd6GK2KN8DxRZZCNk23snYhMAgoaMhmPsNO-2XuNQwAwLE2EXyTaJV9xPWg52am1_RmfmUqezVQ", propsfile = "www/.data.world"), dataset="jonathankkizer/s-17-dv-final-project", type="sql", query="SELECT YearRaw, sum(Visitors) as Visitors FROM NatVisDF group by YearRaw order by YearRaw"
)
dfIV1Gas <- query(
  data.world(token = "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJwcm9kLXVzZXItY2xpZW50OmpvbmF0aGFua2tpemVyIiwiaXNzIjoiYWdlbnQ6am9uYXRoYW5ra2l6ZXI6OjlkOWM5MDBlLTc0N2MtNDM5Yi04YmVhLWYwMTRjMzVkZjY1YiIsImlhdCI6MTQ4NDY5NzI4NCwicm9sZSI6WyJ1c2VyX2FwaV93cml0ZSIsInVzZXJfYXBpX3JlYWQiXSwiZ2VuZXJhbC1wdXJwb3NlIjp0cnVlfQ.xVPkWdDyKxmAd6GK2KN8DxRZZCNk23snYhMAgoaMhmPsNO-2XuNQwAwLE2EXyTaJV9xPWg52am1_RmfmUqezVQ", propsfile = "www/.data.world"), dataset="jonathankkizer/s-17-dv-final-project", type="sql", query="select Year as YearRaw, `GasPrices.csv/GasPrices`.`Retail Gasoline Price 
(Constant 2015 dollars/gallon)` as Price from GasPrices"
)

dfIV1 <- inner_join(dfIV1, dfIV1Gas)
# Note: Previous idea of gas prices rising meant visitors fell disproven; Coefficient of Correlation of only ~.03
print("Correlation test w/ constant 2015 prices:")
print(cor(dfIV1$Visitors, dfIV1$Price,  method = "pearson", use = "complete.obs"))