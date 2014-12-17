#Load Packages

library(XML)
library(tidyr)
library(stringr)
library(magrittr)
library(plyr)
library(dplyr)
library(RWeka)

#Remove non-words from the raw icc texts
get_real_words <- function(word) {
  word[!stringr::str_detect(word, "[^a-z ]")]
}

#' Remove unreasonable n-grams containing characters other than letters and spaces
#' @param ngrams A list of n-grams
#' @return Returns a list of filtered n-grams
filter_unreasonable_ngrams <- function(ngrams) {
  require(stringr)
  ngrams[!str_detect(ngrams, "[^a-z ]")]
}

#load OCR'd ICC Deceisions data into R
icc_dir <- "text"
files <- dir(icc_dir, "*.txt")
raw <- file.path(icc_dir, files) %>%
  lapply(., scan, "character", sep = "\n")
names(raw) <- files
icc_texts <- lapply(raw, paste, collapse = " ") %>%
  lapply(., tolower) %>%
  lapply(., WordTokenizer) %>%
  lapply(., get_real_words) %>%
  lapply(., paste, collapse = " ")

#Create an N-gram maker with Rweka's function
#ngrammify <- function(data, n) { 
 # NGramTokenizer(data, Weka_control(min = n, max = n))
#}

#Turn text list into N-grams, in this case 5-grams
#icc_grams <- lapply(icc_texts, ngrammify, 5)
#every_grams <- icc_grams %>% unlist() %>% unique()

#attach the texts to a data.frame instead of list.
icc.df <- ldply(icc_texts)

#have to use the old plyr package- currently a bug in dplyr with rename_ function- but it creates the correct data.frame all the same
decisions <- icc.df %>%
                    plyr::rename(c(".id" = "id",
                          "V1" = "text"))
#decisions will be the variable used in topics.r, do not clear environment before loading topics.r

#Run the filter_unreasonable_ngrams function
#fix_grams <- filter_unreasonable_ngrams(icc_grams)
#head(fix_grams)

#Save the data
write.csv(icc.df, file = "out/icc_texts.csv")
