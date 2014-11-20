#load and parse html tables

#load libraries
library(stringr)
library(XML)
library(magrittr)

#Parse a sample table
doc <-"table/v02toc.html"

p <- htmlParse(doc)

iccv02toc <- readHTMLTable(p, header = FALSE, stringsAsFactors = FALSE)
str(iccv02toc)
write.csv(iccv02toc[4], file = "out/iccv02toc.csv")
