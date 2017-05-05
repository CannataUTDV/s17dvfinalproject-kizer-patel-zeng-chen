require(readr)
require(lubridate)
require(dplyr)
require(data.world)

online0 = TRUE


globals = query(
    data.world(token = "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJwcm9kLXVzZXItY2xpZW50OmpvbmF0aGFua2tpemVyIiwiaXNzIjoiYWdlbnQ6am9uYXRoYW5ra2l6ZXI6OjlkOWM5MDBlLTc0N2MtNDM5Yi04YmVhLWYwMTRjMzVkZjY1YiIsImlhdCI6MTQ4NDY5NzI4NCwicm9sZSI6WyJ1c2VyX2FwaV93cml0ZSIsInVzZXJfYXBpX3JlYWQiXSwiZ2VuZXJhbC1wdXJwb3NlIjp0cnVlfQ.xVPkWdDyKxmAd6GK2KN8DxRZZCNk23snYhMAgoaMhmPsNO-2XuNQwAwLE2EXyTaJV9xPWg52am1_RmfmUqezVQ", propsfile = "www/.data.world"),
               dataset="jonathankkizer/s-17-dv-final-project", type="sql",
               query="SELECT YearRaw, stateLatLong.STATE as State, Visitors, Region, UnitType, avg_Visitors, sum_Visitors, stateLatLong.LATITUDE, stateLatLong.LONGITUDE, stateLatLong.Location FROM NatVisDF s join `censusInfo.csv/censusInfo` r ON (s.State = r.State) join `stateLatLong.csv/stateLatLong` l ON (s.State = l.STATE)"
)