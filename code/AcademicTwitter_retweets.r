library(dplyr)
library(academictwitteR)
library(igraph)

## Building a SNA of Retweet Activity

#whatever other set-up is needed before you get data from Twitter
bearer_token <- 'YOUR TOKEN HERE'
twitter_data <- get_all_tweets('YOUR TWEET PULL HERE')

twitter_data <- tweets # for now
tweet_ids <- twitter_data %>% 
  filter(public_metrics$retweet_count > 0) %>% 
  pull(id)
# retweeters <- get_retweeted_by(tweet_ids, bearer_token = bearer_token) #75 tweets / 15 min....this can take a long time
retweeters <- get_retweeted_by(tweet_ids[1:5], bearer_token = bearer_token)

users_to_lookup <- twitter_data %>% 
  filter(public_metrics$retweet_count > 0) %>% 
  pull(author_id)
retweeted_users <- get_user_profile(users_to_lookup, bearer_token = bearer_token)

rt_df <- right_join(twitter_data %>% 
                     select(id, author_id),
                   retweeters %>% 
                     select(from_tweet_id, username),
                   by = c('id'='from_tweet_id')
                   ) %>% 
          rename(retweet_screen_name = username) %>% 
          left_join(retweeted_users %>% 
                      select(id, username),
                    by = c('author_id' = 'id')) %>% 
          rename(screen_name = username) %>% 
          select(screen_name, retweet_screen_name)

#no self-references, remove the few 'loops' of lines pointing to themselves
rt_df <- rt_df[rt_df$screen_name!=rt_df$retweet_screen_name,]

matrx <- as.matrix(rt_df)
nw_retweet <- graph_from_edgelist(el = matrx, directed = TRUE)

#remove nodes with 10 or fewer connections to reduce clutter
simplified <- delete.vertices(simplify(nw_retweet), degree(simplify(nw_retweet))<=10)

set.seed(1234)
#part 1 of fix the weird scaling/positioning of the graph
#part two include the margins, rescale, and layout (where this is used) options below
lay = norm_coords(layout_nicely(simplified), ymin=-.3, ymax=.7, xmin=-.4, xmax=.6)

plot(simplified,
     vertex.label = ifelse(degree(nw_retweet)>500, V(nw_retweet)$name, NA), #only label 500 connections
     vertex.size  = degree(nw_retweet)*0.007, #size nodes based on this
     vertex.label.cex = 1,
     edge.arrow.size = 0.09, #make the arrows small
     margins = c(0,0,0,0),
     rescale = F,
     layout = lay*3)


#other notes from converting rtweet to academictwitteR:
#
#not sure what the old $location brought up but you could likely get similar data with 
#twitter_data$geo$place_id
#there's also the coordinates in twitter_data$geo$coordinates

#text stuff should work the same

#for retweet_counts etc, you can't just use "retweet_count" etc, but public_metrics$retweet_count
#with public_metrics$ in front of them, that stuff should work
