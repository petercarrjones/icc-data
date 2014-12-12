#Topic Model script
#Much of this initial workflow is from Jockers Text Analysis for R 
#and Shawn Graham's Ferguson Grand Jury corpus topic model at https://github.com/shawngraham/ferguson
library(mallet)
library(wordcloud)
library(dplyr)
library(tm)
library(Hmisc)

# import the OCR'd ICC decisions from the text folder
# each decision is here its own text file
#decisions <- mallet.read.dir("text") 

#Better is to use load.r file to provide cleaner texts via get_real_words function, etc

mallet.instances <- mallet.import(decisions$id, decisions$text, "icc.txt", token.regexp = "\\p{L}[\\p{L}\\p{P}]+\\p{L}")

#' create topic trainer object
n.topics <- 100
topic.model <- MalletLDA(n.topics)

#' load documents
topic.model$loadDocuments(mallet.instances)

## Get the vocabulary, and some statistics about word frequencies.
## These may be useful in further curating the stopword list.
vocabulary <- topic.model$getVocabulary()
word.freqs <- mallet.word.freqs(topic.model)
#Get additional words for stoplist
#stopwords<- arrange(word.freqs, words, term.freq)
#rank(stopwords)



## Optimize hyperparameters every 20 iterations,
## after 50 burn-in iterations.
topic.model$setAlphaOptimization(20, 50)

## Now train a model. Note that hyperparameter optimization is on, by default.
## We can specify the number of iterations. Here we'll use a large-ish round number.
topic.model$train(400)

## NEW: run through a few iterations where we pick the best topic for each token,
## rather than sampling from the posterior distribution.
topic.model$maximize(40)

#' Get the probability of topics in documents and the probability of words in topics.
#' By default, these functions return raw word counts. Here we want probabilities,
#' so we normalize, and add "smoothing" so that nothing has exactly 0 probability.
doc.topics <- mallet.doc.topics(topic.model, smoothed=T, normalized=T)
topic.words <- mallet.topic.words(topic.model, smoothed=T, normalized=T)  ##adap jockers wordcloud script to use this variable

#' from http://www.cs.princeton.edu/~mimno/R/clustertrees.R
#' transpose and normalize the doc topics
topic.docs <- t(doc.topics)
topic.docs <- topic.docs / rowSums(topic.docs)

#Get shorter versions of the topics
topics.labels <- rep("", n.topics)
for (topic in 1:n.topics) topics.labels[topic] <- paste(mallet.top.words(topic.model, topic.words[topic,], num.top.words=7)$words, collapse=" ")


#output some of the topic model raw data
write.csv(topic.docs, "out/icc-topic-docs.csv") 
write.csv(topics.labels, "out/icc-topic-labels.csv") 

# create data.frame with columns as ids and rows as topics
topic_docs <- data.frame(topic.docs)
plotdocs <- names(topic_docs) 
names(topic_docs) <- decisions$id

## cluster based on shared words
plot(hclust(dist(topic.words)), labels=topics.labels)

#' Calculate similarity matrix
#' Shows which documents are similar to each other
#' by their proportions of topics. Based on Matt Jockers' method

library(cluster)
topic_df_dist <- as.matrix(daisy(t(topic_docs), metric = "euclidean", stand = TRUE))
# Change row values to zero if less than row minimum plus row standard deviation
# keep only closely related documents and avoid a dense spagetti diagram
# that's difficult to interpret (hat-tip: http://stackoverflow.com/a/16047196/1036500)
topic_df_dist[ sweep(topic_df_dist, 1, (apply(topic_df_dist,1,min) + apply(topic_df_dist,1,sd) )) > 0 ] <- 0

#' Use kmeans to identify groups of similar authors

km <- kmeans(topic_df_dist, n.topics)
# get names for each cluster
allnames <- vector("list", length = n.topics)
for(i in 1:n.topics){
  allnames[[i]] <- names(km$cluster[km$cluster == i])
}

#Shawn Graham's topics as wordclouds with some of Jockers print to pdf code
pdf(file="icc-topics.pdf")
for(i in 1:40){
  topic.top.words <- mallet.top.words(topic.model,
                                      topic.words[i,], 15)
  print(wordcloud(topic.top.words$words,
                  topic.top.words$weights,
                  c(4,.8), rot.per=0,
                  random.order=F))
  
}
dev.off()

#create some plots of topics across the range of decisions
library(ggplot2)
library(tidyr)
pdf(file="icc-topics-across-docs.pdf")
n.decisions <- length(raw)
cols <- 1:n.decisions
doc_topics <- data.frame(doc.topics, row.names = decisions$id, stringsAsFactors = FALSE)
doc_topics$docs <- cols

topic.cols <- names(doc_topics)

for(i in 1:100){
print(ggplot(doc_topics) + geom_smooth(aes_string(x="docs", y=(topic.cols[i]))))

}  
dev.off()

ggplot(doc_topics, aes(x=docs, y=X30)) + geom_smooth(span = 20)
