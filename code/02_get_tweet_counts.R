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
n_days <- collect_dates[2] - collect_dates[1]

counts <- list()
for (i in 1:nrow(input)) { 
  counts[[i]] <- count_all_tweets(input$hashtag[i],
                                  start_tweets = collect_times[1],
                                  end_tweets = collect_times[2],
                                  bearer_token,
                                  n = n_days,
                                  country = "US",
                                  lang = "en")
}

names(counts) <- input$hashtag
saveRDS(counts, file = "data/raw/species_counts.RDS")