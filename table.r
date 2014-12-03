#load and parse html tables

#load libraries
library(stringr)
library(stringi)
library(XML)
library(dplyr)
library(magrittr)

table_dir <- "table"
files <- dir(table_dir, "*.html")
tbls <- file.path(table_dir, files) 
tbls <- lapply(tbls, htmlParse) %>%
  lapply(., readHTMLTable, head = FALSE, stringsAsFactors = FALSE, which = 4)

#According to Hadley Wickham, creating an empty dataset and populating it is drastically faster in R
tbl.df <- data.frame((character(length = length(tbls))), stringsAsFactors = FALSE)

#iterate through the list of tables and parse the html structure
i <- NULL
for(i in 1:length(tbls)){
  
  i.df <- readHTMLTable(tbls[i], head = FALSE, stringsAsFactors = FALSE)
  tbl.df <- cbind(tbl.df, i.df)

}

readHTMLTable(tbls[1])

stopwords <- unique(tbls)

#Parse a sample table, this is the path
doc <-"table/v02toc.html"

#Pull in html files
p <- htmlParse(doc)



#iccv02toc.df <- xmlToDataFrame(p, collectNames = FALSE, stringsAsFactors = FALSE, nodes= iccv02toc[4] )

iccv02toc <- readHTMLTable(p, header = FALSE, stringsAsFactors = FALSE)

#Turn the HtmlInternalDocument into a data.frame
iccv02toc.df <- as.data.frame(iccv02toc[4], stringsAsFactors = FALSE)

#Use dplyr to munge the data from 3 columns of information into several columns of information
#First is to move plaintiff tribe into a separate column.
#iccv02toc.df$table1.V2 <- str_replace_all(iccv02toc.df$table1.V2, "[\t]", "")

v02tocfinal.df <- mutate(iccv02toc.df, tribe = str_extract(iccv02toc.df$table1.V2, ".*\r\n"))
v02tocfinal.df <- mutate(v02tocfinal.df, page1 = str_extract(v02tocfinal.df$table1.V3, ".*\r\n"))



str(iccv02toc)
write.csv(iccv02toc[4], file = "out/iccv02toc.csv")
