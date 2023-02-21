source("code/01_load_fun_packs.R")
tweets <- readRDS(tweets, file = "data/raw/all_AIS_tweets.RDS")
get_text <- function(x) { x$text }
unfiltered_text = lapply(tweets, get_text) %>% unlist
invasive_id = which(names(tweets)=="#invasivespecies")
goldfish_id = which(names(tweets)=="#goldfish")
filtered_text = lapply(tweets[-c(goldfish_id)], get_text) %>% unlist
filtered_text2 = lapply(tweets[-c(invasive_id, goldfish_id)], get_text) %>% unlist

get_textCorpus <- function(text) {
  ## -- WordCloud from https://mikeyharper.uk/creating-twitter-wordclouds/
  # Clean the data
  text <- str_c(text, collapse = "")
  # continue cleaning the text
  library(tm)            # Text mining cleaning
  library(stringr)       # Removing characters
  library(qdapRegex)     # Removing URLs
  text <- 
    text %>%
    str_remove("\\n") %>%                   # remove linebreaks
    rm_twitter_url() %>%                    # Remove URLS
    rm_url() %>%
    str_remove_all("#\\S+") %>%             # Remove any hashtags
    str_remove_all("@\\S+") %>%             # Remove any @ mentions
    removeWords(stopwords("english")) %>%   # Remove common words (a, the, it etc.)
    removeNumbers() %>%
    stripWhitespace() %>%
    removeWords(c("amp"))                   # Final cleanup of other small changes
  # Convert the data into a summary table
  textCorpus <- 
    Corpus(VectorSource(text)) %>%
    TermDocumentMatrix() %>%
    as.matrix()
  textCorpus <- sort(rowSums(textCorpus), decreasing=TRUE)
  textCorpus <- data.frame(word = names(textCorpus), freq=textCorpus, row.names = NULL)
}
get_word_cloud <- function(textCorpus) {
  library(wordcloud2)    # Creating the wordcloud
  wordcloud <- wordcloud2(data = textCorpus, minRotation = 0, maxRotation = 0, ellipticity = 0.6)
  return(wordcloud)
}

texts = list(unfiltered_text, filtered_text, filtered_text2)
textCorpus = lapply(texts, get_textCorpus)
wordclouds = lapply(textCorpus, get_word_cloud)

names(textCorpus) = c("unfiltered", "filtered", "filtered2")
names(wordclouds) = names(textCorpus)

lapply(textCorpus, head)
lapply(wordclouds, print)

save_word_cloud <- function(my_graph, n) {
  #install webshot
  library(webshot)
  webshot::install_phantomjs(force = T)
  # save it in html
  library("htmlwidgets")
  file_name_html = paste0("images/", n, ".html")
  file_name_png = paste0("images/", n, ".png")
  saveWidget(my_graph, file_name_html,selfcontained = F)
  # and in png
  webshot(file_name_html,file_name_png, delay =5, vwidth = 480, vheight=480) # changed to png. 
}

# Export word clouds
# from https://stackoverflow.com/questions/9950144/access-lapply-index-names-inside-fun
x <- as.list(1:length(wordclouds))
names(x) <- names(wordclouds)
lapply(seq_along(x), function(my_graph, n, i) { 
  save_word_cloud(my_graph[[i]], n[[i]]) 
  },my_graph=wordclouds, n=names(x))

# Write textcorpus
lapply(seq_along(x), function(textCorpus, n, i) {
  write.csv(textCorpus[[i]], file = paste0("data/tidy/textCorpus_", n[[i]], ".csv"))
}, textCorpus = textCorpus, n = names(x))

# Sentiment Analysis
library(syuzhet)
# library(lubridate)
# library(scales)
# library(reshape2)

tweets_clean = list(iconv(unfiltered_text),
                    iconv(filtered_text),
                    iconv(filtered_text2))
names(tweets_clean) <- names(textCorpus)
library(parallel)
sentiments <- mclapply(tweets_clean, get_nrc_sentiment)
names(sentiments) <- names(textCorpus)
lapply(sentiments, head)

sentiment_barplot <- function(sentiment) {
  proportions <- sentiment[,1:8] %>%
    prop.table() %>%
    colSums() %>%
    sort()
  data <- data.frame(emotion=names(proportions),
                     proportion=proportions,
                     row.names = NULL)
  p <- ggplot(data, aes(x=reorder(emotion, -proportion), y=proportion, fill = emotion)) +
    geom_bar(stat="identity") + xlab("Emotion") + ylab("Mean Proportion Across Tweets") + 
    theme(legend.position = "none") + coord_flip()
  return(p)
}

sentiment_plots <- lapply(sentiments, sentiment_barplot)

sentiments <- mclapply(tweets_clean, get_sentiment)

# Step 1: Call the pdf command to start the plot
pdf(file = "images/sentiment_plots.pdf",   # The directory you want to save the file in
    width = 4, # The width of the plot in inches
    height = 4) # The height of the plot in inches

# Step 2: Create the plot with R code
sentiment_plots

# Step 3: Run dev.off() to create the file!
dev.off()



url <- "https://docs.google.com/spreadsheets/d/15axVoP4eLejqTTRj-a15YU3v6AkJv3Y-n5AEQRievEU/edit?usp=sharing"
input <- googlesheets4::read_sheet(url) %>%
  select(type, keyword) %>%
  mutate(hashtag = paste0("#", str_replace_all(keyword, " ", "")))

sentiments_in_context = bind_rows(tweets, .id = "hashtag") %>%
  cbind(valence = sentiments$unfiltered) %>%
  merge(input) %>%
  mutate(date = as.Date(created_at)) %>%
  group_by(type, month = floor_date(date, 'month')) 

sentiment_plots = list()
ggplot(sentiments_in_context, aes(x=date, y=valence, color = type)) +
  geom_point()

sentiments_in_context = sentiments_in_context %>%
  summarize(mean_valence = mean(valence)) %>%
  mutate(month_num = month(month))

temporal_summary <- ggplot(sentiments_in_context, aes(x=month, y=mean_valence, color=type)) +
  geom_point() + geom_smooth() + xlab("Date") + ylab("Mean Monthly Valence")
print(temporal_summary)

temporal_stacked_summary <- ggplot(sentiments_in_context, mapping = aes(x = month_num, y = mean_valence, color = type)) +
  geom_point() + geom_smooth(method=lm) + scale_x_continuous(name="Month", breaks = 1:12, labels = month.abb[1:12]) +
  ylab("Mean Monthly Valence") 
print(temporal_stacked_summary)

## for qualitative analysis
tweets = bind_rows(tweets, .id = "hashtag")
hist(tweets$public_metrics$retweet_count)
hist(tweets$public_metrics$like_count)
sorted_tweets <- tweets[
  with(tweets, order(-tweets$public_metrics$retweet_count,
                     -tweets$public_metrics$reply_count,
                     -tweets$public_metrics$quote_count,
                     -tweets$public_metrics$like_count,
                     -tweets$public_metrics$impression_count)),
]

popular_hashtags = sorted_tweets %>% pull(hashtag)
popular_hashtags %>% table
qual_goldfish = subset(sorted_tweets, hashtag=="#goldfish") %>%
  select(hashtag, text, public_metrics) %>%
  head(15)
qual_invasives = subset(sorted_tweets, hashtag=="#invasivespecies") %>%
  select(hashtag, text, public_metrics) %>%
  head(15)
qual_AIS = subset(sorted_tweets, hashtag!="#goldfish" & hashtag!="#invasivespecies") %>%
  select(hashtag, text, public_metrics) %>%
  head(15)
to_analyze = rbind(qual_goldfish, qual_invasives, qual_AIS)
write.csv(to_analyze, file = "data/tidy/qualitative_analysis_tweets.csv")