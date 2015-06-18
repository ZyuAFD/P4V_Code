address <- "http://quotes.money.163.com/service/chddata.html"
field <- "&fields=TCLOSE;HIGH;LOW;TOPEN;LCLOSE;CHG;PCHG;TURNOVER;VOTURNOVER;VATURNOVER;TCAP;MCAP"

name=600004
start = 19910101
end = ""
url <- paste(address, "?code=0", name, "&start=", start, "&end=", end, field, sep = "")


x=read.table(url,skip=1,stringsAsFactors=F,sep=',',fill=T)

y %>%
  mutate(V1=ymd(V1),V2=gsub("'","",V2)) -> y1
