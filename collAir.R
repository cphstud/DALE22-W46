library(jsonlite)
library(httr)
library(stringr)


un <- "user"
pw <- "password"
#### POINT REYES ####
lamin=37.841183
lamax=38.228414
lomin=-123.143884
lomax=-121.573969


#lamin=41.930379
#lamax=47.409038
#lomin=24.884060
#lomax=40.616482

fullurl=paste0("https://opensky-network.org/api/states/all?lamin=",lamin,"&lomin=",lomin,"&lamax=",lamax,"&lomax=",lomax)
print(fullurl)


# lav en tÃ¦ller som tÃ¦ller op til en grÃ¦nse
counter=0
limit=1
freq=20
prflightlist = list()
while (counter <= limit) {
    res <- httr::GET(fullurl,authenticate(un,pw))
    rescontent <- httr::content(res, as="text")
    resretval <- jsonlite::fromJSON(rescontent)
    statedfpr <- as.data.frame(resretval$states)
    prflightlist <- append(prflightlist,list(statedfpr))
    print("sleep")
    Sys.sleep(freq)
  counter = counter + 1
}

print("DONE")
# save list to file - rds
testdf <- do.call('rbind',prflightlist)
testdf3 <- data.frame(testdf, stringsAsFactors=FALSE)
saveRDS(testdf3, file = "rvymy_flights.rds")
