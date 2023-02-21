source("code/01_load_fun_packs.R")
followers_list <- readRDS(file = "data/raw/followers_list.RDS")
following_list <- readRDS(file = "data/raw/following_list.RData")
# format data
followers = bind_rows(followers_list) %>%
  select(id, from_id) %>%
  setNames(c("from", "to"))
followings = bind_rows(following_list) %>%
  select(id, from_id) %>%
  setNames(c("to", "from"))
# from https://www.r-bloggers.com/2021/07/quick-and-dirty-analysis-of-a-twitter-social-network/
relations = rbind(followers, followings) %>% na.omit
nodes = stack(relations)$values %>% unique
library(igraph)
library(tidygraph)
library(ggraph)
network_ego1 <- graph_from_data_frame(relations, nodes, directed = F) %>%
  as_tbl_graph()

set.seed(123)
network_ego1 <- network_ego1 %>%
  activate(nodes) %>%
  mutate(community = as.factor(group_louvain())) %>%
  mutate(degree_c = centrality_degree()) %>%
  mutate(betweenness_c = centrality_betweenness(directed = F,normalized = T)) %>%
  mutate(closeness_c = centrality_closeness(normalized = T)) %>%
  mutate(eigen = centrality_eigen(directed = F))
network_ego_df <- as.data.frame(network_ego1)

# get users with highest metrics
kp_ego <- data.frame(
  network_ego_df %>% arrange(-degree_c) %>% select(name),
  network_ego_df %>% arrange(-betweenness_c) %>% select(name),
  network_ego_df %>% arrange(-closeness_c) %>% select(name),
  network_ego_df %>% arrange(-eigen) %>% select(name)) %>%
  setNames(c("degree","betweenness","closeness","eigen"))
head(kp_ego)

write.csv(kp_ego, "data/tidy/kp_ego.csv")

# filter nodes
n_nodes = nrow(kp_ego)
n_cut = floor(n_nodes/10:1)
n_cut = n_cut[1] # for now
influential_ids = kp_ego$eigen[1:n_cut]

# visualize network
options(ggrepel.max.overlaps = Inf)
network_viz <- network_ego1 %>%
  activate(nodes) %>%
  filter(name %in% influential_ids) %>% # filter nodes
  filter(community %in% 1:3) %>%
  mutate(node_size = ifelse(degree_c >= 50,degree_c,0)) %>%
  mutate(node_label = ifelse(betweenness_c >= 0.01,name,NA))
plot_ego <- network_viz %>%
  ggraph(layout = "stress") +
  geom_edge_fan(alpha = 0.05) +
  geom_node_point(aes(color = as.factor(community),size = node_size)) +
  geom_node_label(aes(label = node_label),nudge_y = 0.1,
                  show.legend = F, fontface = "bold", fill = "#ffffff66") +
  theme_graph() +
  theme(legend.position = "none") +
  labs(title = "Top 3 communities")
# Error: vector memory exhausted (limit reached?)
plot_ego

# investigate author status
author_df = subset(network_ego_df, network_ego_df$name %in% unique_authors)
author_community_tbl = author_df$community %>%
  table %>%
  sort(decreasing = T)

author_influence_ids = which(kp_ego$eigen %in% unique_authors)[1:10]

# lookup influential id
# tweets <- readRDS("data/raw/all_AIS_tweets.RDS") %>%
#   bind_rows(.id = hashtag)

source("code/00_Twitter_AIS_keys.R")
influential_author_profiles = get_user_profile(kp_ego$eigen[author_influence_ids], 
                                               bearer_token)
influential_authors = influential_author_profiles %>%
  select(id, username, name, description)
write.csv(influential_authors, file = "data/tidy/influential_authors.csv")

author_relations_index = which(relations$from %in% influential_authors$id[2:nrow(influential_authors)] | 
        relations$to %in% influential_authors$id[2:nrow(influential_authors)]) # exclude the most influential node

relations = relations[author_relations_index,]

network_ego1 <- graph_from_data_frame(relations, nodes, directed = F) %>%
  as_tbl_graph()

set.seed(123)
network_ego1 <- network_ego1 %>%
  activate(nodes) %>%
  mutate(community = as.factor(group_louvain())) %>%
  mutate(degree_c = centrality_degree()) %>%
  mutate(betweenness_c = centrality_betweenness(directed = F,normalized = T)) %>%
  mutate(closeness_c = centrality_closeness(normalized = T)) %>%
  mutate(eigen = centrality_eigen(directed = F))
network_ego_df <- as.data.frame(network_ego1)

# get users with highest metrics
kp_ego <- data.frame(
  network_ego_df %>% arrange(-degree_c) %>% select(name),
  network_ego_df %>% arrange(-betweenness_c) %>% select(name),
  network_ego_df %>% arrange(-closeness_c) %>% select(name),
  network_ego_df %>% arrange(-eigen) %>% select(name)) %>%
  setNames(c("degree","betweenness","closeness","eigen"))
head(kp_ego)

# write.csv(kp_ego, "data/tidy/kp_ego.csv")

# investigate author status
author_df = subset(network_ego_df, network_ego_df$name %in% unique_authors)
author_community_tbl = author_df$community %>%
  table %>%
  sort(decreasing = T)

# visualize network
options(ggrepel.max.overlaps = Inf)
network_viz <- network_ego1 %>%
  activate(nodes) %>%
  filter(community %in% author_community_tbl[1:3]) %>%
  mutate(node_size = ifelse(degree_c >= 50,degree_c,0)) %>%
  mutate(node_label = ifelse(betweenness_c >= 0.01,name,NA))
plot_ego <- network_viz %>%
  ggraph(layout = "stress") +
  geom_edge_fan(alpha = 0.05) +
  geom_node_point(aes(color = as.factor(community),size = node_size)) +
  geom_node_label(aes(label = node_label),nudge_y = 0.1,
                  show.legend = F, fontface = "bold", fill = "#ffffff66") +
  theme_graph() +
  theme(legend.position = "none") +
  labs(title = "Top 3 communities")
# Error: vector memory exhausted (limit reached?)
plot_ego
