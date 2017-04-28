#ETL process and export to .csv
measures <- c("GNIS", "Visitors", "YearRaw")

dimensions <- setdiff(names(prETLNatVisDF),measures)


#removes special characters in each column
for(n in names(prETLNatVisDF)) {
  prETLNatVisDF[n] <- data.frame(lapply(prETLNatVisDF[n], gsub, pattern="[^ -~]",replacement= ""))
}

na2emptyString <- function (x) {
  x[is.na(x)] <- ""
  return(x)
}
if( length(dimensions) > 0) {
  for(d in dimensions) {
    # Change NA to the empty string.
    prETLNatVisDF[d] <- data.frame(lapply(prETLNatVisDF[d], na2emptyString))
    # Get rid of " and ' in dimensions.
    prETLNatVisDF[d] <- data.frame(lapply(prETLNatVisDF[d], gsub, pattern="&",replacement= " and "))
    # Change : to ; in dimensions.
    prETLNatVisDF[d] <- data.frame(lapply(prETLNatVisDF[d], gsub, pattern=":",replacement= ";"))
  }
}

na2zero <- function (x) {
  x[is.na(x)] <- 0
  return(x)
}

ETLNatVisDF <- prETLNatVisDF
write.csv(prETLNatVisDF, file = "NatVisDF.csv")
print("Success!")