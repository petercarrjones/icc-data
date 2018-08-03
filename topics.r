#Topic Model script
#Much of this initial workflow is from Jockers Text Analysis for R 
#and Shawn Graham's Ferguson Grand Jury corpus topic model at https://github.com/shawngraham/ferguson
library(mallet)
library(wordcloud2)
library(dplyr)
library(tm)
library(Hmisc)

# import the OCR'd ICC decisions from the text folder
# each decision is here its own text file
decisions <- mallet.read.dir("text") 

#Better is to use load.r file to provide cleaner texts via get_real_words function, etc
#Update: OKstate has now changed their icc file structure, not allowing wget downloading. Use the raw txt files of the decisions and skip load.r
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
jpeg(filename="topic-hcluster.jpeg", width = 960, height = 600, )
print(plot(hclust(dist(topic.words)), labels=topics.labels))
dev.off()

#' Calculate similarity matrix
#' Shows which documents are similar to each other
#' by their proportions of topics. Based on Matt Jockers' method

library(cluster)
topic_df_dist <- as.matrix(daisy(t(topic_docs), metric = "euclidean", stand = TRUE))
# Change row values to zero if less than row minimum plus row standard deviation
# keep only closely related documents and avoid a dense spagetti diagram
# that's difficult to interpret (hat-tip: http://stackoverflow.com/a/16047196/1036500)
topic_df_dist[ sweep(topic_df_dist, 1, (apply(topic_df_dist,1,min) + apply(topic_df_dist,1,sd) )) > 0 ] <- 0



#Shawn Graham's topics as wordclouds with some of Jockers print to pdf code
jpeg(filename="out/images/icc-topic-%03d.jpeg")
for(i in 1:100){
  topic.top.words <- mallet.top.words(topic.model,
                                      topic.words[i,], 15)
  print(wordcloud2(data = topic.top.words$words,
                  topic.top.words$weights,
                  c(4,.8), rot.per=0,
                  random.order=F))
  
}
dev.off()

#create some plots of topics across the range of decisions
library(ggplot2)
library(tidyr)
jpeg(filename="out/images/icc-topics-across-docs-%03d.jpeg")
n.decisions <- length(raw)
cols <- 1:n.decisions
doc_topics <- data.frame(doc.topics, row.names = decisions$id, stringsAsFactors = FALSE)
doc_topics$docs <- cols

topic.cols <- names(doc_topics)

for(i in 1:100){
print(ggplot(doc_topics) + geom_smooth(aes_string(x="docs", y=(topic.cols[i]))) + xlab("ICC Decisions in Order"))

}  
dev.off()

#print(ggplot(doc_topics, aes(x=docs, y=X30), title = c("Topic " + "30")) + geom_smooth()

      ##Create a term document matrix to plot word similarities
      # library(tm)
      # library(igraph)
# corpus<- Corpus(VectorSource(decisions$text))
# corpus<- tm_map(corpus, removeWords, stopwords("english"))
# icc.tdm <- TermDocumentMatrix(corpus)
# clean.tdm <- removeSparseTerms(icc.tdm, .995)     
#plot(clean.tdm, terms = findFreqTerms(tdm, lowfreq = 6)[1:25], corThreshold = 0.5) #need Rgraphviz, only for R 3.1

# toi <- "history" # term of interest
# corlimit <- 0.44 #  lower correlation bound limit.
# expert_0.7 <- data.frame(corr = findAssocs(icc.tdm, toi, corlimit)[,1],
                      # terms = row.names(findAssocs(icc.tdm, toi, corlimit)))
# expert_0.7$terms <- factor(expert_0.7$terms ,levels = expert_0.7$terms)

# jpeg(filename="wordsim-history.jpeg", width=900, height = 800)
# ggplot(expert_0.7, aes( y = terms  ) ) +
  # geom_point(aes(x = corr), data = expert_0.7) +
  # xlab(paste0("Correlation with the term ", "\"", toi, "\""))
# dev.off()

# toi <- "award" # term of interest
# corlimit <- 0.36 #  lower correlation bound limit.
# expert_0.7 <- data.frame(corr = findAssocs(icc.tdm, toi, corlimit)[,1],
                         # terms = row.names(findAssocs(icc.tdm, toi, corlimit)))
# expert_0.7$terms <- factor(expert_0.7$terms ,levels = expert_0.7$terms)

# jpeg(filename="wordsim-award.jpeg", width=900, height = 800)
# ggplot(expert_0.7, aes( y = terms  ) ) +
  # geom_point(aes(x = corr), data = expert_0.7) +
  # xlab(paste0("Correlation with the term ", "\"", toi, "\""))
# dev.off()
