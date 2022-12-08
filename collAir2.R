library(jsonlite)
library(httr)
library(stringr)
library(RMariaDB)
library(DBI)
library(logr)


condb = dbConnect(MariaDB(),
		  host="localhost",
		  user="root",
		  password="OttoRehagel123!",
		  db="mycollection",
		  port=3306
)

#
log_open("run.log")

un <- "thorwulf"
pw <- "d5pljrt!"
#### POINT REYES ####
lamin=35.841183
lamax=38.228414
lomin=-123.143884
lomax=-119.573969


#lamin=41.930381
#lamax=47.409038
#lomin=24.884060
#lomax=40.616482

fullurl=paste0("https://opensky-network.org/api/states/all?lamin=",lamin,"&lomin=",lomin,"&lamax=",lamax,"&lomax=",lomax)
print(fullurl)

#names
obsname=c("icao24","callsign","origin_country","time_position","last_contact","longitude","latitude","baro_altitude","on_ground","velocity", "true_track","vertical_rate","sensors","geo_altitude","squawk", "spi", "category" )

# lav en taeller
counter=0
limit=2
freq=10
prflightlist = list()
log_print("Ready ..")
testurl="https://opensky-network.org/api/states/all"
while (counter <= limit) {
	restest <- httr::GET(testurl,authenticate("thorwulf","d5pljrtr!"))
	log_print(c("Test ",restest$status_code))
	res <- httr::GET(fullurl,authenticate("thorwulf","d5pljrtr!"))
	log_print(c("Status: ",res$status_code))
	log_print(c("Url: ",fullurl))
	Sys.sleep(freq)
	rescontent <- httr::content(res, as="text")
	resretval <- jsonlite::fromJSON(rescontent)
	statedfpr <- as.data.frame(resretval$states)
	prflightlist <- append(prflightlist,list(statedfpr))
	counter = counter + 1
}

print("DONE")
# save list to file - rds
testdf <- do.call('rbind',prflightlist)
testdf3 <- data.frame(testdf, stringsAsFactors=FALSE)
saveRDS(testdf3, file = "rvymy_flights.rds")
testdf4 = do.call(rbind.data.frame,prflightlist)
colnames(testdf4) = obsname
retval=dbWriteTable(condb,"mycollection",testdf4,append=T)
log_print(c("reswrite: ",retval))
log_close()
