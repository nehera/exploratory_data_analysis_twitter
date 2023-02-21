# load project functions, packages
source("code/01_load_fun_packs.R")
# load tweets
file_path <- "~/Documents/GitHub/Twitter_AIS/data/raw/2022-08-02 12/54/53/query.rds"
tweets <- readRDS(file_path)
# how are people tweeting?
get_how <- function(tweets) {
  n <- nrow(tweets)
  prop <- tweets$referenced_tweets %>%
    lapply(is.null) %>% # if null, type == tweet
    unlist %>%
    table/n
  report <- as.numeric(prop) %>%
    percent %>%
    c(n)
  names(report) <- c("retweet", "tweet", "n")
  return(report)
}
# print table
how_table <- get_how(tweets)
# get common words
tokens <- tweets$text %>%
  tokenize_tweets %>%
  unlist
tokens <- tokens[str_length(tokens) >= 3]

# install.packages("wordcloud")
library(wordcloud)
# install.packages("RColorBrewer")
library(RColorBrewer)
# install.packages("wordcloud2")
library(wordcloud2)

clean_text <- function(text) {
  text <- gsub("https\\S*", "", text) 
  text <- gsub("@\\S*", "", text) 
  text <- gsub("amp", "", text) 
  text <- gsub("[\r\n]", "", text)
  text <- gsub("[[:punct:]]", "", text)
  return(text)
}

tidy_text <- tweets$text %>%
  clean_text

tweets_words <- tweets %>%
  select(text) %>%
  mutate(text = clean_text(text)) %>%
  unnest_tokens(word, text) %>%
  filter(str_length(word) >= 3) %>%
  filter(!(word %in% stopwords(source = "snowball")))
words <- tweets_words %>% count(word, sort=TRUE)

top_words <- head(words, 10) 
bot_words <- tail(words, 10)

set.seed(1234) # for reproducibility 
word_cloud <- wordcloud2(data=words, size=1.6, color='random-dark')

# frequency over time
date_freq <- tweets$created_at %>%
  as.Date %>%
  table %>%
  data.frame %>%
  rename(Date = ".") %>%
  mutate(Date = as.Date(Date))

p <- ggplot(data = date_freq, aes(x=Date, y=Freq)) +
  geom_line()

# top and bot users
author_freq <- tweets$author_id %>%
  table %>%
  data.frame %>%
  rename(Author_ID = ".") %>%
  arrange(-Freq)

head(author_freq)
d <- ggplot(data = author_freq, aes(x=Freq)) +
  geom_density()