library(tidyverse)
tweet_ids <- readRDS("data/raw/all_AIS_tweets.RDS") %>%
  bind_rows(.id = "hashtag") %>%
  pull(id)
write.csv(tweet_ids,
          file = "data/tidy/tweet_ids.csv",
          row.names = FALSE)
