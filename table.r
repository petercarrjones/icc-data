#load and parse html tables

#load libraries
library(stringr)
library(XML)
library(dplyr)
library(magrittr)

#Parse a sample table, this is the path
doc <-"table/v02toc.html"

#Pull in html files
p <- htmlParse(doc)



#iccv02toc.df <- xmlToDataFrame(p, collectNames = FALSE, stringsAsFactors = FALSE, nodes= iccv02toc[4] )

iccv02toc <- readHTMLTable(p, header = FALSE, stringsAsFactors = FALSE)

iccv02toc.df <- as.data.frame(iccv02toc[4], stringsAsFactors = FALSE)

str(iccv02toc)
write.csv(iccv02toc[4], file = "out/iccv02toc.csv")
