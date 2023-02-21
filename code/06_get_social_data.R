source("code/00_Twitter_AIS_keys.R")
source("code/01_load_fun_packs.R")
tweets <- readRDS("data/raw/all_AIS_tweets.RDS")
get_author_ids <- function(x) {
  x$author_id
}
author_ids = lapply(tweets, get_author_ids) %>% unlist
author_df = data.frame(ais_tweet_id = names(author_ids),
                       author_id = author_ids,
                       row.names = NULL)
author_df$ais_tweet_id %>% str_starts("#invasivespecies") %>% sum()
author_df$ais_tweet_id %>% str_starts("#goldfish") %>% sum()
# Exclude #goldfish
author_df = author_df %>%
  filter(str_starts(ais_tweet_id, "#goldfish")!=TRUE) %>%
  filter(str_starts(ais_tweet_id, '#invasivespecies')!=TRUE)
author_df$author_id %>% n_distinct

unique_authors = unique(author_df$author_id)
# break authors to query into parts
unique_authors_list = split(unique_authors, ceiling(seq_along(unique_authors)/15))

followers_list = list()
for (i in 1:length(unique_authors_list)) {
  print(paste("Starting Piece", i))
  followers_list[[i]] = get_user_followers(unique_authors_list[[i]],
                                           bearer_token = bearer_token)
}
saveRDS(followers_list, file = "data/raw/followers_list.RDS")

following_list = list()
for (i in 1:length(unique_authors_list)) { 
  print(paste("Starting Piece", i))
  following_list[[i]] = get_user_following(unique_authors_list[[i]],
                                           bearer_token = bearer_token)
}
saveRDS(following_list, file = "data/raw/following_list.RDS")
