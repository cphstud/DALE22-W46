library(httr)
library(jsonlite)
library(dplyr)
library(ggplot2)
library(DBI)
library(RMariaDB)

condb <- dbConnect(MariaDB(),
                   db="news",
                   host="localhost",
                   user="root",
                   password="root123"
                   )

apinewskey="d02cbfbac75e4967ac4c66a1d2ff3085"
qparam = "Mette+Frederiksen"
adate=as.Date("2022-10-25")

dftotal = data.frame(matrix(nrow=0,ncol=7))
colnames(dftotal) <- n2


for (counter in (1:10)) {
  tmpdf = data.frame(matrix(nrow=0,ncol=8))
  bdate=adate
  adate=adate+1
  tmpdf=getnews(bdate,adate,qparam)
  tmpdf=tmpdf[,-1]
  colnames(tmpdf) <- n2
  dftotal=rbind(dftotal,tmpdf)
}

p <- ggplot(dftotal, aes(x=date)) +
  geom_bar(stat="count")
p + labs(title="Omtaler af Mette Frederiksen")

dbWriteTable(condb,"dknews",dftotal,overwrite=T)
getnews <- function(xdate,ydate,kw) {
  url=paste0("https://newsapi.org/v2/everything?q=",qparam,"&from=",fdate,"&to=",tdate,"&language=en&sortBy=publishedAt&apiKey=",apinewskey)
  res=httr::GET(url)
  dfnews <- res %>%  
    httr::content(as = "text") %>% 
    jsonlite::fromJSON()
  dfcontent=dfnews$articles
  return(dfcontent)
}

