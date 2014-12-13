#load and parse html tables

#load libraries
library(stringr)
library(stringi)
library(XML)
library(dplyr)
library(magrittr)

#function to clean up character vectors- removes punctuation.
get_real_words <- function(word) {
  word[!stringr::str_detect(word, "[^a-z ]")]
}

#Loads all the html tables into one list
table_dir <- "table"
files <- dir(table_dir, "*.html")
tbls <- file.path(table_dir, files) %>%
  lapply(., htmlParse) %>%
  lapply(., readHTMLTable, head = FALSE, stringsAsFactors = FALSE, which = 1) 

#bind the tables together into one large table with 3 columns
all_tbls <- do.call(rbind, tbls)

#Process the text in column to remove non-characters
tbls_words<- gsub("\r", " ", all_tbls$V2)
tbls_words<- gsub("\t", " ", tbls_words) 
tbls_words<- gsub("\n", " ", tbls_words)
tbls_words<- gsub(",", " ", tbls_words)
#Turn into a list -should refactor to do this before then lapply()
tblwords.ls <- list(tbls_words)
#Create lower-case word-token strings with no punctuation
tblwords.ls <- lapply(tbwords.ls, paste, collapse= " ") %>%
  lapply(., tolower) %>%
  lapply(., WordTokenizer) %>%
  lapply(., get_real_words) %>%
  lapply(., unique)
#unlist into character vector
tblword.ch <- unlist(tblwords.ls)

#concatenate new words onto old stoplist (mallet's standard english stopwords with some icc-centric words)
cat(tblword.ch, file= "icc.txt", sep="\n", append = TRUE)
#load old list
stopwords<- scan(file="icc.txt", what= "character", sep="\n")
#Keep only the unique words in the stop list and re-save
stopwords <- unique(stopwords)
cat(stopwords, file="icc.txt", sep="\n", append = FALSE)


#Currently This code isn't necessary #/
#According to Hadley Wickham, creating an empty dataset and populating it is drastically faster in R
"tbl.df <- data.frame((character(length = length(tbls))), stringsAsFactors = FALSE)

#iterate through the list of tables and parse the html structure
i <- 1
for(i in 1:length(tbls)){
  
  i.df <- readHTMLTable(tbls[i], head = FALSE, stringsAsFactors = FALSE)
  tbl.df <- cbind(tbl.df, i.df)

}

readHTMLTable(tbls[1])

"

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

v02tocfinal.df <- 
  iccv02toc.df %>%
  mutate(tribe = str_match(table1.V2, "(.*?)\r\n")[,2]) %>%
  
  View()


v02tocfinal.df <- mutate(v02tocfinal.df, page1 = str_extract(v02tocfinal.df$table1.V3, ".*\r\n"))


#review and save to file
str(iccv02toc)
write.csv(iccv02toc[4], file = "out/iccv02toc.csv")
