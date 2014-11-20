#Load Packages

library(XML)
library(tidyr)
library(stringr)
library(magrittr)
library(dplyr)
library(RWeka)

#load OCR'd ICC Deceisions data into R
icc_dir <- "text"
files <- dir(icc_dir, "*.txt")
raw <- file.path(icc_dir, files) %>%
  lapply(., scan, "character", sep = "\n")
names(raw) <- files
icc_texts <- lapply(raw, paste, collapse = " ") %>%
  lapply(., tolower) %>%
  lapply(., WordTokenizer) %>%
  lapply(., paste, collapse = " ")

#Create an N-gram maker with Rweka's function
ngrammify <- function(data, n) { 
  NGramTokenizer(data, Weka_control(min = n, max = n))
}

#Turn text list into N-grams, in this case 5-grams
icc_grams <- lapply(icc_texts, ngrammify, 5)
every_grams <- icc_grams %>% unlist() %>% unique()



#Remove non-words from the raw icc texts
filter_unreasonable_ngrams <- function(ngrams) {
  require(stringr)
  ngrams[!str_detect(ngrams, "[^a-z ]")]
}

#Run the filter_unreasonable_ngrams function
fix_grams <- filter_unreasonable_ngrams(every_grams)
head(fix_grams)
