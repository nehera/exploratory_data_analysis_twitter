# https://eehh-stanford.github.io/SNA-workshop/intro-igraph.html#getting-started

library(igraph)

require(igraph)
g <- make_graph(c(1,2, 1,3, 2,3, 2,4, 3,5, 4,5), n=5, dir=FALSE)
plot(g, vertex.color="lightblue")

g <- graph_from_literal(Fred-Daphne:Velma-Shaggy, Fred-Shaggy-Scooby)
plot(g, vertex.shape="none", vertex.label.color="black")

#Make directed edges using -+ where the plus indicates the direction of the arrow, i.e., A --+ B creates a directed edge from A to B
#A mutual edge can be created using +-+

# empty graph
g0 <- make_empty_graph(20)
plot(g0, vertex.color="lightblue", vertex.size=10, vertex.label=NA)

# full graph
g1 <- make_full_graph(20)
plot(g1, vertex.color="lightblue", vertex.size=10, vertex.label=NA)

# ring
g2 <- make_ring(20)
plot(g2, vertex.color="lightblue", vertex.size=10, vertex.label=NA)

# lattice
g3 <- make_lattice(dimvector=c(10,10))
plot(g3, vertex.color="lightblue", vertex.size=10, vertex.label=NA)

# tree
g4 <- make_tree(20, children = 3, mode = "undirected")
plot(g4, vertex.color="lightblue", vertex.size=10, vertex.label=NA)

# star
g5 <- make_star(20, mode="undirected")
plot(g5, vertex.color="lightblue", vertex.size=10, vertex.label=NA)

# Erdos-Renyi Random Graph
g6 <- sample_gnm(n=100,m=50)
plot(g6, vertex.color="lightblue", vertex.size=5, vertex.label=NA)

# Power Law
g7 <- sample_pa(n=100, power=1.5, m=1,  directed=FALSE)
plot(g7, vertex.color="lightblue", vertex.size=5, vertex.label=NA)

# Plot 2 Graphs Together
plot(g4 %du% g7, vertex.color="lightblue", vertex.size=5, vertex.label=NA)

# Rewiring means rearranging the ties in a graph. It randomizes the connections between nodes without changing the degree distribution
gg <- g4 %du% g7
gg <- rewire(gg, each_edge(prob = 0.3))
plot(gg, vertex.color="lightblue", vertex.size=5, vertex.label=NA)

## retain only the connected component
gg <- induced.subgraph(gg, subcomponent(gg,1))
plot(gg, vertex.color="lightblue", vertex.size=5, vertex.label=NA)

## look at the structure
g4

V(g4)$name <- LETTERS[1:20]
## see how it's changed
g4

V(g4)$vertex.color <- "Pink"
E(g4)$edge.color <- "SkyBlue2"
plot(g4, vertex.size=10, vertex.label=NA, vertex.color=V(g4)$vertex.color, 
     edge.color=E(g4)$edge.color, edge.width=3)

# Edge Lists are More Efficient than Adjacency Matrices
## who is the most central?
# cb <- betweenness(gf2f)