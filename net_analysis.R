# Example usage for igraph: http://michael.hahsler.net/SMU/LearnROnYourOwn/code/igraph.html

# load library for network analysis
library(igraph)
library(RMySQL)
library(dbConnect)

# fetch data from database
connection = dbConnect(MySQL(), user='tante', password='XXXXXXX', dbname='network_proj', host='localhost')
dbListTables(connection)

query1 <- "select * from contribute_connection;"
df1 <- dbGetQuery(connection, query1)
query2 <- "SELECT count(DISTINCT a.a_account_id,a.b_account_id,b.country_code) FROM contribute_connection a,accounts b,accounts c WHERE a.a_account_id=b.id AND a.b_account_id=c.id AND b.country_code=c.country_code;"
num_edge_from_same_country <- dbGetQuery(connection, query2)
query3 <- "SELECT count(DISTINCT a.a_account_id,a.b_account_id) FROM contribute_connection a,accounts b,accounts c WHERE a.a_account_id=b.id AND a.b_account_id=c.id AND b.programming_language_id=c.programming_language_id;"
num_edge_same_language <- dbGetQuery(connection, query3)
#View(df1)
str(num_edge_from_same_country)
str(num_edge_same_language)

# construct undireted networks
relations <- data.frame(from=df1['a_account_id'],
                        to=df1['b_account_id'],
                        weight=df1['counts'])
contributor_net <- graph.data.frame(relations, directed = FALSE)

# visulize networks
V(contributor_net)$color = "skyblue"
V(contributor_net)[articulation.points(contributor_net)]$color = "red"
plot(contributor_net, vertex.label=NA, vertex.size=5, edge.color="black")

# Node level analysis
net_degree <- degree(contributor_net)
sort(net_degree, decreasing = TRUE)[1:20]
net_betweenness <- betweenness(contributor_net)
sort(net_betweenness, decreasing = TRUE)[1:20]
net_closeness <- closeness(contributor_net)
sort(net_closeness, decreasing = TRUE)[1:20]
net_eigenvector <- eigen_centrality(contributor_net)
sort(net_eigenvector$vector, decreasing = TRUE)[1:20]

# Link level analysis
clu <- components(contributor_net)
sort(clu$csize, decreasing = TRUE)[1:10]
decompose_net <- decompose.graph(contributor_net)
largest_net <- decompose_net[[1]]
V(largest_net)$color = "skyblue"
V(largest_net)[articulation.points(largest_net)]$color = "red"
plot(largest_net, vertex.label=NA, vertex.size=5, edge.color="black")

# network level analysis
diameter(contributor_net)
mean(degree(contributor_net))
mean_distance(contributor_net, directed = FALSE, unconnected = TRUE)
transitivity(contributor_net, type="global")
centr_degree(contributor_net)$centralization
edge_density(contributor_net, loops = FALSE)

dbDisconnect(connection)
#query1 <- paste("select * from XX where age between ", age1, " and ", age2, ";", sep = "")
#dbWriteTable(connection, "new_table", df, overwrite=TRUE, append=FALSE)
