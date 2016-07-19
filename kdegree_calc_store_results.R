# Creates degree analysis table
#
# Requires:
# general analysis results "results/datos_analisis.RData"

library(kcorebip)

kdegree.distribution <- function (kdegl, cumulative = FALSE, ...) 
{
  cs <- kdegl
  hi <- hist(cs, max(cs), plot = FALSE)$density
  if (!cumulative) {
    res <- hi
  }
  else {
    res <- rev(cumsum(rev(hi)))
  }
  res
}


load("results/datos_analisis.RData")
redes <- resultdf$Network
resultdf$kdegDIVdeg <- 0
resultdf$kdegdegRsq <- 0
#redes <- c("M_PL_001.csv")#,"M_PL_002.csv","M_PL_003.csv","M_PL_004.csv","M_PL_005.csv")
redes <- resultdf$Network

for (nred in redes)
{
  result_analysis <- analyze_network(nred, directory = "data/", guild_a = "Plant", guild_b = "Pollinator", plot_graphs = FALSE)
  jg <- result_analysis$graph
  deg <- igraph::degree(result_analysis$graph)
  dd <-degree.distribution(jg,mode="in")
  kdeg <- V(jg)$kdegree
  # hist(log(dd),breaks=10)
  # plot(degree.distribution(jg, mode="in"), log="xy")
  # plot(kdegree.distribution(kdeg),log="xy")
  odeg <- sort(as.numeric(unlist(deg)))
  okdeg <- sort(as.numeric(unlist(kdeg)))
  modeld <- lm(okdeg ~ odeg)
  rsquared <- summary(modeld)$r.squared
  resultdf[resultdf$Network==nred,]$kdegDIVdeg <- modeld$coefficients["odeg"]
  resultdf[resultdf$Network==nred,]$kdegdegRsq <- summary(modeld)$r.squared
  print(sprintf("%s qot:%0.2f rsq:%0.4f",nred,modeld$coefficients["odeg"],rsquared))
}

save(resultdf, file='results/datos_analisis_condegs.RData', compress=TRUE) 

# bp <- get_bipartite(result_analysis$graph, plot_graphs = FALSE)
# plot_bipartite(bp, aspect_ratio = 9/45,vlabelcex=1.5,vsize = 5, vframecolor = "grey40", color_link = "black")


