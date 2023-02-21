# This script gets a list of aquatic invasive species (AIS) species 
# of specific concern to Minnesota from the MN DNR's Guide to AIS:
# https://www.dnr.state.mn.us/invasives/ais/id.html

# load packages for web scrape and data tidying
library(rvest)
library(xml2)
library(dplyr)
library(stringr)

# make input
types <- c("animal", "plant", "disease")
urls <- c("https://www.dnr.state.mn.us/invasives/aquaticanimals/index.html",
          "https://www.dnr.state.mn.us/invasives/aquaticplants/index.html",
          "https://www.dnr.state.mn.us/fish_diseases/index.html")

## -- get mostly tidy vector of species
get_species <- function(url) {
  x <- read_html(url) %>% 
    html_nodes("div.region.region-content") %>% 
    html_text
  # find capitalized letters
  split_where <- sapply(gregexpr("[A-Z]", x), `[`) %>%
    c(nchar(x)+1) # for split fx
  raw_species <- as.character()
  for (i in 1:(length(split_where)-1)) {
    raw_species[i] <- substring(x, split_where[i], split_where[i+1]-1)
  }
  # remove at and after "Resources"
  keep_point <- which(raw_species=="Resources")-1
  species <- raw_species[1:keep_point] %>% 
    tolower %>%
    trimws
  return(species)
}

output <- matrix(nrow = 0, ncol = 2)
for (j in 1:2) { #- disease # hold on for now
  vec <- get_species(urls[j])
  output <- output %>%
    rbind(data.frame(type=types[j], species=vec))
}

## -- small fixes
# fix new zealand mud snail
output <- 
  output %>%
  filter(species != 'new') %>%
  mutate(species = replace(species, species == "zealand mud snail", "new zealand mud snail"))
# fix zebra mussel, yellow iris
nms <- c("zebra mussel", "yellow iris")
ids <- which(str_detect(output$species, nms))
output$species[ids] <- nms

## -- write tidy data
write.csv(output, file = "data/tidy/species_of_interest.csv", row.names = FALSE)
