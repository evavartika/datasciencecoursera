filename <- "Coursera_DS4_Final.zip"

# Checking if archieve already exists.
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
  download.file(fileURL, filename, method="curl")
} 

# Checking if folder exists
if (!file.exists("Household_power_consumption")) { 
  unzip(filename) 
}
NEI <- readRDS("summarySCC_PM25.rds")
SCC <- readRDS("Source_Classification_Code.rds")

head(NEI)

head(SCC)

library(ggplot2)
library(plyr)
## Converting "year", "type", "Pollutant", "SCC", "fips" to factor
colToFactor <- c("year", "type", "Pollutant","SCC","fips")
NEI[,colToFactor] <- lapply(NEI[,colToFactor], factor)

head(levels(NEI$fips))
## The levels have NA as "   NA", so converting that level back to NA
levels(NEI$fips)[1] = NA
NEIdata<-NEI[complete.cases(NEI),]
colSums(is.na(NEIdata))


totalEmission <- aggregate(Emissions ~ year, NEIdata, sum)
totalEmission
barplot(
  (totalEmission$Emissions)/10^6,
  names.arg=totalEmission$year,
  xlab="Year",
  ylab="PM2.5 Emissions (10^6 Tons)",
  main="Total PM2.5 Emissions From All US Sources"
)





NEIdata<-subset(NEIdata, fips== "24510")
totalEmission <- aggregate(Emissions ~ year, NEIdata, sum)
totalEmission

barplot(
  (totalEmission$Emissions)/10^6,
  names.arg=totalEmission$year,
  xlab="Year",
  ylab="PM2.5 Emissions (10^6 Tons)",
  main="Total PM2.5 Emissions From All Baltimore City Sources"
)





g<-ggplot(aes(x = year, y = Emissions, fill = type), data = NEIdata)
g+geom_bar(stat="identity")+
  facet_grid(.~type)+
  labs(x="year", y=expression("Total PM"[2.5]*" Emission (Tons)")) + 
  labs(title=expression("PM"[2.5]*" Emissions, Baltimore City 1999-2008 by Source Type"))+
  guides(fill=FALSE)



names(SCC)<-gsub("\\.","", names(SCC))
SCCcombustion<-grepl(pattern = "comb", SCC$SCCLevelOne, ignore.case = TRUE)
SCCCoal<-grepl(pattern = "coal", SCC$SCCLevelFour, ignore.case = TRUE)

## extracting the SCC in 
SCCCoalCombustionSCC<-SCC[SCCcombustion & SCCCoal,]$SCC
NIECoalCombustionValues<-NEIdata[NEIdata$SCC %in% SCCCoalCombustionSCC,]
NIECoalCombustionTotalEm<-aggregate(Emissions~year, NIECoalCombustionValues, sum)
g<-ggplot(aes(year, Emissions/10^5), data=NIECoalCombustionTotalEm)
g+geom_bar(stat="identity",fill="grey",width=0.75) +
  guides(fill=FALSE) +
  labs(x="year", y=expression("Total PM"[2.5]*" Emission (10^5 Tons)")) + 
  labs(title=expression("PM"[2.5]*" Coal Combustion Source Emissions Across US from 1999-2008"))




SCCvehicle<-grepl(pattern = "vehicle", SCC$EISector, ignore.case = TRUE)
SCCvehicleSCC <- SCC[SCCvehicle,]$SCC

## using this boolean vector get the interested rows from the baltimore data
NEIvehicleSSC <- NEIdata[NEIdata$SCC %in% SCCvehicleSCC, ]
NEIvehicleBaltimore <- subset(NEIvehicleSSC, fips == "24510")
NIEvehicleBaltimoreTotEm<-aggregate(Emissions~year, NEIvehicleBaltimore, sum)

g<-ggplot(aes(year, Emissions/10^5), data=NIEvehicleBaltimoreTotEm)
g+geom_bar(stat="identity",fill="grey",width=0.75) +
  guides(fill=FALSE) +
  labs(x="year", y=expression("Total PM"[2.5]*" Emission (10^5 Tons)")) + 
  labs(title=expression("PM"[2.5]*" Motor Vehicle Source Emissions in Baltimore from 1999-2008"))





NEIvehicleBalti<-subset(NEIvehicleSSC, fips == "24510")
NEIvehicleBalti$city <- "Baltimore City"
NEIvehiclela<-subset(NEIvehicleSSC, fips == "06037")
NEIvehiclela$city <- "Los Angeles County"
NEIBothCity <- rbind(NEIvehicleBalti, NEIvehiclela, sum)


g<-ggplot(NEIBothCity, aes(x=year, y=Emissions, fill=city)) +
  g+geom_bar(aes(fill=year),stat="identity") +
  facet_grid(.~city) +
  guides(fill=FALSE) + theme_bw() +
  labs(x="year", y=expression("Total PM"[2.5]*" Emission (10^5 Tons)")) + 
  labs(title=expression("PM"[2.5]*" Motor Vehicle Source Emissions in Baltimore from 1999-2008"))
aggregateEmissions <- aggregate(Emissions~city+year, data=NEIBothCity, sum)
aggregate(Emissions~city, data=aggregateEmissions, range)

