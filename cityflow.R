library(DBI)
library(RMariaDB)
library(ggplot2)
library(dplyr)
library(httr)
library(jsonlite)
library(logr)


#make a httr-post-request
loginurl="https://api.cityflow.live/users/login"
             
#credential
pars = list( 
 email ="youmail"
 password ="yourpw"
)
resp <- POST(
  loginurl,
  body=pars,
  encode="json"
)
resp$status_code

token="<get your token from resp">

# få en list over alle devices
baseurl="https://api.cityflow.live/devices"
res=httr::GET(baseurl, add_headers(Authorization = paste0("Bearer ",token)))
res$status_code
devicelist <- res %>%  
  httr::content(as = "text") %>% 
  jsonlite::fromJSON()

#lav en get-request der henter de nyeste målinger 
#https://api.cityflow.live/measurements/latest 

latesturl="https://api.cityflow.live/measurements/latest"
res=httr::GET(latesturl, add_headers(Authorization = paste0("Bearer ",token)))
res$status_code
latestlist <- res %>%  
  httr::content(as = "text") %>% 
  jsonlite::fromJSON()

obsdf=latestlist$`150`


#Find hvad de enkelte observationer betyder
obsurl="https://api.cityflow.live/devices/types"
res=httr::GET(obsurl, add_headers(Authorization = paste0("Bearer ",token)))
res$status_code
obslist <- res %>%  
  httr::content(as = "text") %>% 
  jsonlite::fromJSON()


#'https://api.cityflow.live/measurements/history/device-type/{DEVICE_TYPE_ID}?from={ISO8601_TIMESTAMP}&to={ISO8601_TIMESTAMP}&resolution={RESOLUTION}' \
#noise=33
#lumen=3
nurl='https://api.cityflow.live/measurements/history/device-type/3?from=2021-11-14&to=2021-11-21&resolution=60m'
res=httr::GET(nurl, add_headers(Authorization = paste0("Bearer ",token)))
res$status_code
noise <- httr::content(res,as = "text")


bbase="https://api.cityflow.live/"

# Find lysintensitet o
#device-type/{device_type_id}?from={ISO8601_TIMESTAMP}&to={ISO8601_TIMESTAMP}
#&resolution={RESOLUTION}
#GET /measurements/history/location/{LOCATION_ID}?from={ISO8601_TIMESTAMP}&to={ISO8601_TIMESTAMP}&resolution=10m HTTP/1.1
fdate="2022-11-14"
tdate="2022-11-21"
log_open()
log_print("test")

locid="237"
url=paste0("measurements/history/location/",locid,"?from=",fdate,"&to=",tdate,"&resolution=60m")
toturl=paste0(bbase,url)
res=httr::GET(toturl, add_headers(Authorization = paste0("Bearer ",token)))
res$status_code
rivangnoise <- res %>%  
  httr::content(as = "text") %>% 
  jsonlite::fromJSON()

allobs=list()

log_open()
#for (i in (1:length())) {
for (i in (1:3)) {
  locid=dfarhid[i]
  url=paste0("measurements/history/location/",locid,"?from=",fdate,"&to=",tdate,"&resolution=60m")
  toturl=paste0(bbase,url)
  log_print(toturl)
  res=httr::GET(toturl, add_headers(Authorization = paste0("Bearer ",token)))
  res$status_code
  log_print(res$status_code)
  tmpdf <- res %>%  
    httr::content(as = "text") %>% 
    jsonlite::fromJSON()
  
  allobs[[i]] <- tmpdf
}

# now plot lumen
tdf2=allobs[[2]]
tdf3=allobs[[3]]
tdf3$mt=gsub("\\.000Z","",tdf3$time)
tdf3$mt=as.POSIXct(tdf3$mt,format = "%Y-%m-%dT%H:%M:%S")
tdf3$log_l=log(tdf3$mean_l)
tdf3$log_l=log(tdf3$mean_l)

tdf2$mt=gsub("\\.000Z","",tdf2$time)
tdf2$mt=as.POSIXct(tdf2$mt,format = "%Y-%m-%dT%H:%M:%S")
tdf2$log_l=log(tdf2$mean_l)
tdf2$log_l=log(tdf2$mean_l)

tdf$mt=gsub("\\.000Z","",tdf$time)
tdf$mt=as.POSIXct(tdf$mt,format = "%Y-%m-%dT%H:%M:%S")
p = ggplot(data=tdf, aes(x=mt,y=log(mean_l),group=1))
p = p + geom_line(colour="red")+
  geom_line(data=tdf2, color="blue")+
  geom_line(data=tdf3, color="green")
p= p + theme(axis.text.x = element_text(angle = 75, hjust = 1))
p= p + scale_x_datetime(date_breaks = "12 hours")
p

# now plot noise
#254 305 216 
colors <- c("Januarvej" = "blue", "Osthavnsvej" = "red", "Norrebrogade" = "green")
p = ggplot(data=tdf, aes(x=mt,y=mean_nA,group=1))
p = p + geom_line(aes(color="Osthavnsvej"))+
  geom_line(data=tdf2,aes(color="Januarvej"))+
  geom_line(data=tdf3, aes(color="Norrebrogade"))
p= p + theme(axis.text.x = element_text(angle = 75, hjust = 1))
p= p + scale_x_datetime(date_breaks = "1 day")
p= p + scale_color_manual(name="noise in 3 places",breaks=c("Januarvej","Osthavnsvej","Norrebrogade"), values = colors)
p
  
