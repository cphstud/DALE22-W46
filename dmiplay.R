library(tidyr)
library(dplyr)
library(purrr)
library(httr)
library(jsonlite)
library(ggplot2)
apikey='f76cb11d-5c0f-494f-abfe-2cbfda38eed5'
dmi.url <-  'https://dmigw.govcloud.dk/v2/metObs/collections/observation/items'

res <- GET(dmi.url, query = list('api-key' = apikey))
data <-  fromJSON(rawToChar(res$content))
names(data)
unique(data$features$properties$parameterId)       

# station-id Aarhus Syd: 06074
# timeformat 2019-01-01T00:00:00Z
stationid=c("06074")
fdate="2022-11-14T00:00:00Z"
tdate="2022-11-21T00:00:00Z"


# get parameter vindstyrke
fparam="wind_max_per10min_past1h"
mywindforce=getdmidata(fdate,tdate,fparam,stationid)

#basepurl='https://dmigw.govcloud.dk/v2/metObs/collections/observation/items?'
#varpurl=paste0('parameterId=',param,'&stationId=',stationid,'&datetime=',fdate,'/',tdate,'&api-key=',apikey)
#totalpurl=paste0(basepurl,varpurl)
#res <- GET(totalpurl, query = list('api-key' = apikey))
#data <-  httr::content(res, as="text")
#rdf <-  (fromJSON(data))
#subdf <- rdf$features


#get parameter vindretning 
param="wind_dir_past1h"
mywinddir=getdmidata(fdate,tdate,param,stationid)

#cbind and filter and sort and cast to timestamp
totnames=c("observed","dir","testobs","force")
totalwind=cbind(mywinddir,mywindforce)
totalwind=totalwind[,c(6,9,15,18)]
colnames(totalwind) <- totnames
totalwinds=arrange(totalwind, observed)
#2022-11-14T00:00:00Z
totalwinds$mt=as.POSIXct(totalwinds$observed, format="%Y-%m-%dT%H:%M:%S")

vp <- ggplot(data=totalwinds, aes(x=mt,y=force, color="red"))+
  geom_line()

vp

getdmidata <- function(fd,td,pr,sid) {
  bpurl='https://dmigw.govcloud.dk/v2/metObs/collections/observation/items?'
  vpurl=paste0('parameterId=',pr,'&stationId=',sid,'&datetime=',fd,'/',td,'&api-key=',apikey)
  ttpurl=paste0(bpurl,vpurl)
  res <- GET(ttpurl, query = list('api-key' = apikey))
  tdata <-  httr::content(res, as="text")
  trdf <-  (fromJSON(tdata))
  tsubdf <- trdf$features
  retvaldf <- unnest_wider(tsubdf,c('properties','geometry'),names_repair = "minimal")
  return(retvaldf)
  
}

