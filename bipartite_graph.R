# Auxiliar script to create a bipartite graph in screen

library(kcorebip)

plot_bipartite <- function(bg, aspect_ratio = 9/35, vframecolor = "grey70", vlabelcex = 4,
                           vsize = 4, vcolor = c("lightblue","pink2"), labelcolor = c("blue","red"),
                           framedisp = FALSE,  color_link = "grey50", vertical = FALSE)
{
  l <- layout.bipartite(bg)
  if (vertical)
    la <- l[, c(2,1)]
  else
    la <- l
  plot.igraph(bg, layout= la,asp=aspect_ratio,vertex.frame.color=vframecolor,
              vertex.label.cex=vlabelcex,vertex.label.color="black",
              vertex.size=vsize, edge.color= color_link, frame = framedisp,
              vertex.color=vcolor[V(bg)$type+1])
}

result_analysis <- analyze_network("M_SD_030.csv", directory = "data/", guild_a = "Plant", guild_b = "Pollinator", plot_graphs = FALSE)
bp <- get_bipartite(result_analysis$graph, plot_graphs = FALSE)
plot_bipartite(bp, aspect_ratio = 80/80,vlabelcex=2.0,vsize = 25, vframecolor = "grey20", color_link = "grey20", vertical = FALSE)