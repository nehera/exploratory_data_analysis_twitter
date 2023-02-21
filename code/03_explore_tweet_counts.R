# load project functions, packages
source("code/01_load_fun_packs.R")

# load data
url <- "https://docs.google.com/spreadsheets/d/15axVoP4eLejqTTRj-a15YU3v6AkJv3Y-n5AEQRievEU/edit?usp=sharing"
input <- googlesheets4::read_sheet(url) %>%
  select(type, keyword) %>%
  mutate(hashtag = paste0("#", str_replace_all(keyword, " ", "")))

counts <- readRDS(file = "data/raw/species_counts.RDS")

# summarize
hash_counts <- lapply(counts, function(x) {
  n <- x$tweet_count %>%
    sum
  return(n)
}) %>% unlist 

output <- input %>%
  mutate(hash_frequency = hash_counts) %>%
  arrange(desc(hash_frequency)) %>%
  group_by(type)
print(head(output, 10))

write.csv(output, file = "data/tidy/species_frequency.csv")

# aggregate tweets over time
temporal_table <- bind_rows(counts, .id = "hashtag") %>%
  merge(input) %>%
  mutate(date = as.Date(start)) %>%
  select(-c(start, end, keyword)) %>%
  group_by(type, month = floor_date(date, 'month')) %>%
  summarize(month_count = sum(tweet_count))

temporal_summary <- ggplot(temporal_table, mapping = aes(x = month, y = month_count, color = type)) +
  geom_point() + geom_smooth(se=FALSE) + xlab("Date") + ylab("Tweet Count (Monthly)")
print(temporal_summary)

temporal_stacked_table <- temporal_table %>%
  mutate(month_num = month(month))

temporal_stacked_summary <- ggplot(temporal_stacked_table, mapping = aes(x = month_num, y = month_count, color = type)) +
  geom_point() + geom_smooth(se=FALSE) + scale_x_continuous(name="Month", breaks = 1:12, labels = month.abb[1:12]) +
  ylab("Tweet Count") # + scale_color_manual(labels = c("T999", "T888"), values = c("blue", "red"))
print(temporal_stacked_summary)
  
ggsave(filename = "images/temporal_summary.png", temporal_summary)
ggsave(filename = "images/temporal_stacked_summary.png", temporal_stacked_summary)

# Questions?
# Was there a push related to AIS in 2014 and then 2018? 
# Why might the conversation be trended downward?
