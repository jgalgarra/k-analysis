# Analysis of all networks
# Creates the file "results/datos_analisis.RData"

library(scales)
library(grid)
library(gridExtra)
library(kcorebip)

directorystr <- "data/"
# red <- "M_PL_001.csv"

red <- "M_SD_028.csv"
result_analysis <- analyze_network(red, directory = directorystr, guild_a = "pl", guild_b = "pol", plot_graphs = FALSE)
numlinks <- result_analysis$links
vecnames <- c("Network","Number","Species","Plants","Pollinators","Interactions","MaxKcore","MeanKdegree",
              "MeanKradius","MaxKradius","NODF","WNODF","wine","Cscore","Ntemperature","Modularity", "RemovedLinks", "SpecRadius","MatrixClass","Type")
resultdf <- data.frame(matrix(ncol = length(vecnames), nrow = 0))
names(resultdf) <- vecnames


analizatodo <- TRUE
#analizatodo <- FALSE
#randomize <- TRUE
randomize <- FALSE
numexper <- 1
wipedperc <- 0.1

vnodf <- rep(0,numexper)
vkdist <- rep(0,numexper)
pref <- ""

if(analizatodo)
{
  unlink(Sys.glob("datarnd/M*.csv"))
  indexrow <- 1
  if (!randomize)
    numexper = 1
  for (e in 1:numexper)
  {
    print(paste0("EXPERIMENTO",e))
    if (randomize){
      pref <- "RND"
      directorystr <- "datarnd/"
      wipelinks <- seq(1,round(numlinks*wipedperc))
      for (qlinks in wipelinks)
      {
        randomize_and_write(result_analysis$matrix,red, bypercentage = TRUE,directory ="datarnd/", rlinks = qlinks)
      }
      nfiles <- Sys.glob(paste0(directorystr,paste0(strsplit(red,"\\.")[[1]][1],"*.csv")))
    }
    else
      nfiles <- Sys.glob(paste0(directorystr,"M*.csv"))
    for (l in nfiles)
    {
      print(l)
      namefile <- strsplit(l,"/")
      namenetwork <- namefile[[1]][2]
      resultdf[indexrow,]$RemovedLinks <- strsplit(strsplit(namefile[[1]][2],"\\.")[[1]][1],"_rnd_")[[1]][2]
      result_analysis <- analyze_network(namenetwork, directory = directorystr, guild_a = "pl", guild_b = "pol", plot_graphs = FALSE)
      resultdf[indexrow,]$Network <- namenetwork
      resultdf[indexrow,]$Number <- strsplit(strsplit(namenetwork,".csv")[[1]],"_")[[1]][3]
      resultdf[indexrow,]$Number <- sprintf("%02d",as.integer(resultdf[indexrow,]$Number))
      if (grepl("_SD_",resultdf[indexrow,]$Network))
        resultdf[indexrow,]$Type <- "Disperser"
      else
        resultdf[indexrow,]$Type <- "Pollinator"
      resultdf[indexrow,]$Plants <- result_analysis$num_guild_a
      resultdf[indexrow,]$Pollinators <- result_analysis$num_guild_b
      resultdf[indexrow,]$Species <-resultdf[indexrow,]$Pollinators + resultdf[indexrow,]$Plants
      resultdf[indexrow,]$Interactions <- length(E(result_analysis$graph))
      resultdf[indexrow,]$MaxKcore <- result_analysis$max_core
      resultdf[indexrow,]$Modularity <- result_analysis$modularity_measure
      radiuss <- V(result_analysis$graph)$kradius
      if (length(radiuss[radiuss!=Inf])>0)
        resultdf[indexrow,]$MaxKradius <- max(radiuss[radiuss!=Inf])
      else {
        print("ALAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAARRRRRRRRRRRRRRRRRRRRRRMAAAAAAAAAAAAAA")
        resultdf[indexrow,]$MaxKradius <- NA
      }
      if (is.na(resultdf[indexrow,]$MeanKradius)){
        resultdf[indexrow,]$MeanKradius <- result_analysis$meandist
      } else {
        resultdf[indexrow,]$MeanKradius <- resultdf[indexrow,]$MeanKradius + result_analysis$meandist
      }
      #resultdf$MeanKradius[indexrow] <- resultdf$MeanKradius[[indexrow]] + result_analysis$meandist
      resultdf[indexrow,]$MeanKdegree <- result_analysis$meankdegree
      resultdf[indexrow,]$NODF <- result_analysis$nested_values["NODF"]
      resultdf[indexrow,]$wine <- result_analysis$nested_values["wine"]
      resultdf[indexrow,]$Cscore <- result_analysis$nested_values["C.score"]
      resultdf[indexrow,]$WNODF <- result_analysis$nested_values["weighted NODF"]
      resultdf[indexrow,]$Ntemperature <- result_analysis$nested_values["binmatnest2.temperature"]
      eigc <- eigen(get.adjacency(result_analysis$graph))$values
      obsspecradius <- max(abs(eigc))
      resultdf[indexrow,]$SpecRadius <- obsspecradius
      if (sum(result_analysis$matrix>1) == 0)
        resultdf[indexrow,]$MatrixClass = "Binary"
      else
        resultdf[indexrow,]$MatrixClass = "Weighted"
      indexrow <- indexrow +1
    }

  }

  resultdf <- resultdf[!is.na(resultdf$MeanKradius),]
  save(resultdf, file=paste0('results/',pref,'datos_analisis.RData'), compress=TRUE)
}
