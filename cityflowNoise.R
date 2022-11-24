library(httr)
library(zoo)
library(jsonlite)
library(logr)
library(ggplot2)
library(gridExtra)
#  --url https://api.cityflow.live/devices \
#--header 'authorization: Bearer {BEARER_TOKEN}'


token="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6NTQ5LCJpYXQiOjE2NjkxMjAwMzQsImV4cCI6MTY2OTIwNjQzNH0.4uRomIH19RDh4rs6fMmH9IR1x8PpLmLUAkIGlIcYcbY"
deviceurl="https://api.cityflow.live/devices"

# init logging
log_open("./logs/cf.log")

resreq <- httr::GET(deviceurl,add_headers(Authorization = paste0("Bearer ",token)))
resreq$status_code
resraw <- httr::content(resreq, type="text") 
resdf <- fromJSON(resraw)

#get name-vector for filtering
brn=unique(resdf$city)
rn=brn[c(1,3,4,6,9,10)]

subdf = subset(resdf, resdf$city %in% rn)

# now get one weeks obs for three locations
# 'https://api.cityflow.live/measurements/history/location/{LOCATION_ID}?from={ISO8601_TIMESTAMP}&to={ISO8601_TIMESTAMP}&resolution={RESOLUTION}' \
locationsfew=c(237,254,305)
# now loop through list and get observations for each location. 
# Store in list
allobs = list()
baseurl='https://api.cityflow.live/measurements/history/location/'
fromdate="2022-11-14"
todate="2022-11-21"

for (i in (1:length(locationsfew))){
  tmploc=locationsfew[[i]]
  varurl=paste0(tmploc,'?from=',fromdate,'&to=',todate,'&resolution=60m')
  totalurl=paste0(baseurl,varurl)
  log_print(totalurl)
  resreq <- httr::GET(totalurl,add_headers(Authorization = paste0("Bearer ",token)))
  log_print(resreq$status_code)
  resraw <- httr::content(resreq, type="text") 
  resdf <- fromJSON(resraw)
  allobs[[i]] <- resdf
}

testobs=allobs[[1]]

# convert datetime-char to datetime-datatype
for (i in (1:length(allobs))) {
  allobs[[i]]$mt=as.POSIXct(allobs[[i]]$time, format="%Y-%m-%dT%H:%M:%S")
  allobs[[i]]=arrange(allobs[[i]],mt)
}

# plot mt as x and nois as y
p <- ggplot(data=allobs[[1]], aes(x=mt,y=mean_nA))+
  geom_line(color="red")+
  geom_line(data=allobs[[2]], color="green")+
  geom_line(data=allobs[[3]], color="blue")+
  theme(axis.text.x = element_text(angle = 75, hjust = 1))+
  scale_x_datetime(date_breaks = "6 hours")
p

# try zoo

ttest1=allobs[[1]]
ttest1=ttest1[,c(4,10,20)]
ttest2=allobs[[2]]
ttest2=ttest2[,c(4,10,20)]
ttest3=allobs[[3]]
ttest3=ttest3[,c(4,10,20)]

ttest1$ma_24=rollmean(ttest1$mean_nA, k=12, fill=NA, align='right')
ttest2$ma_24=rollmean(ttest2$mean_nA, k=12, fill=NA, align='right')
ttest3$ma_24=rollmean(ttest3$mean_nA, k=12, fill=NA, align='right')

# try std dev
rollapply(df1,width=5,FUN=sd,fill=0,align="r")
ttest1$rma_24=rollapply(ttest1$mean_nA, width=3,FUN=sd,fill=0)
ttest2$rma_24=rollapply(ttest2$mean_nA, width=3,FUN=sd,fill=0)
ttest3$rma_24=rollapply(ttest3$mean_nA, width=3,FUN=sd,fill=0)
 

#p1 <- ggplot(data=ttest1, aes(x=mt,y=mean_nA))+
p1 <- ggplot(data=ttest1, aes(x=mt,y=ma_24))+
  geom_line(color="red")
#p1 <- ggplot(data=ttest1, aes(x=mt,y=ma_24))+
#  geom_line(color="red")+
#  geom_line(data=ttest2, color="green")+
#  geom_line(data=ttest3, color="blue")

p1= p1 + 
  #geom_line(data=ttest1, aes(y=ma_24, color="red"))+
  geom_line(data=ttest2, aes(y=ma_24, color="green"))+
  geom_line(data=ttest3, aes(y=ma_24, color="blue"))+
  scale_x_datetime(date_breaks = "6 hours")+
  theme(axis.text.x = element_text(angle = 75, hjust = 1))

p1

grid.arrange(p,p1, nrow=2)
# try ts
mytsdf=ts(data=allobs[[1]],start = ttud,frequency = 168)

# now get one weeks obs for all Aarhus locations
locations=subdf$location

