source("code/01_load_fun_packs.R")
tweets <- readRDS("data/raw/all_AIS_tweets.RDS")
# https://cran.r-project.org/web/packages/usmap/vignettes/mapping.html
# https://cran.r-project.org/web/packages/usmap/vignettes/advanced-mapping.html

pull_long_lat <- function(coords) {
  long_lat <- data.frame(matrix(nrow=length(coords), ncol=2))
  colnames(long_lat) <- c("longitude", "latitude")
  for (i in 1:2) {
    long_lat[,i] <- coords %>% sapply(function(j) {
      if (is.null(j)) {
        return(NA)
      } else {
        return(j[[i]])
      }
    })
  }
  return(long_lat)
}

geo_data = lapply(tweets, function(x) {
  coords <- x$geo$coordinates$coordinates %>%
    pull_long_lat
  return(coords)
}) %>% bind_rows(.id = "hashtag")

prop_geo = sum(!is.na(geo_data$longitude))/nrow(geo_data)
print(prop_geo)

geo_data = geo_data %>% na.omit()

library(usmap)
geo_transformed = usmap_transform(geo_data, 
                                  input_names = c("longitude", "latitude"))
p1 = plot_usmap(regions = "states") +
  labs(title = "Aquatic Invasive Species Tweet Locations") +
  theme(panel.background = element_rect(color = "black", fill = "lightblue")) +
  geom_point(data = geo_transformed, aes(x, y), colour = 'purple', alpha = .5, size=2)
print(p1)

table(geo_data$hashtag)

# deal with outlier
x_out <- boxplot(geo_transformed$x, plot = FALSE)$out
y_out <- boxplot(geo_transformed$y, plot = FALSE)$out

geo_transformed=geo_transformed[geo_transformed$x!=x_out,]
p2 = plot_usmap(regions = "states") +
  labs(title = "Aquatic Invasive Species Tweet Locations") +
  theme(panel.background = element_rect(color = "black", fill = "lightblue")) +
  geom_point(data = geo_transformed, aes(x, y), colour = 'purple', alpha = .5, size=2)
print(p2)

p3 = plot_usmap(regions = "states") +
  labs(title = "Aquatic Invasive Species Tweet Locations (excluding #goldfish)") +
  theme(panel.background = element_rect(color = "black", fill = "lightblue")) +
  geom_point(data = geo_transformed[geo_transformed$hashtag!='#goldfish',], aes(x, y), colour = 'purple', alpha = .5, size=2)
print(p3)
