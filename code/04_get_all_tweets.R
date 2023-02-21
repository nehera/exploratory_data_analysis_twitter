# load Twitter keys and tokens
source("code/00_Twitter_AIS_keys.R")
# load project functions, packages
source("code/01_load_fun_packs.R")
# get all keywords
url <- "https://docs.google.com/spreadsheets/d/15axVoP4eLejqTTRj-a15YU3v6AkJv3Y-n5AEQRievEU/edit?usp=sharing"
# make hash tags of interest
input <- googlesheets4::read_sheet(url) %>%
  select(type, keyword) %>%
  mutate(hashtag = paste0("#", str_replace_all(keyword, " ", "")))
# get counts
now <- Sys.time()
collect_dates <- c("2012-01-01", "2021-12-31") %>% ymd
collect_times <- paste0(collect_dates, "T00:00:00Z")

tweets <- list()
for (i in 1:nrow(input)) { 
  tweets[[i]] <- get_all_tweets(input$hashtag[i],
                                  start_tweets = collect_times[1],
                                  end_tweets = collect_times[2],
                                  n = 5000,
                                  bearer_token,
                                  country = "US",
                                  lang = "en")
}

names(tweets) <- input$hashtag
saveRDS(tweets, file = "data/raw/all_AIS_tweets.RDS")
