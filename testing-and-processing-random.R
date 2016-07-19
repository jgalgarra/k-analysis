# Rewiring experiment
# Output data at results_rnd/
#
# Parameters:
#  alldir <- TRUE    Analyisis of all networks at data/M*.csv
# Requires:
# general analysis results "results/datos_analisis.RData"

library(scales)
library(grid)
library(gridExtra)
library(stringr)
library(kcorebip)

prandomize_and_write <- function(matrix, namenetwork, rlinks = 0,  directory = "", bypercentage = TRUE)
{
  if (bypercentage)
    filesuf <- paste0("_rnd_",rlinks)
  else
    filesuf <- paste0("_lnk_",rlinks)
  if (rlinks > 0)
  {
    links <- matrix > 0
    nolinks <- matrix == 0
    rows <- nrow(matrix)
    cols <- ncol(matrix)
    if (bypercentage)
      extractions <- round(rlinks*sum(links)/100)
    else
      extractions <- rlinks
    onestozeroes <- sample(which(links),extractions)
    zeroestoones <- sample(which(nolinks),extractions)
    matrix[onestozeroes] = 0
    matrix[zeroestoones] = 1
  }
  nfile <- paste0(directory,strsplit(namenetwork,"\\.")[[1]][1],filesuf,".csv")
  write.csv(matrix,nfile)
}

wipe_random <- function(red, analizatodo = TRUE, numexper = 10, wipedperc = 0.1, maxlinks = 10000, num_hops = 0)
{

  print(paste("RED",red))
  directorystr <- "data/"
  result_analysis <- analyze_network(red, directory = directorystr, guild_a = "pl", guild_b = "pol", plot_graphs = FALSE, only_NODF = TRUE)
  matrix_orig <- result_analysis$matrix
  numlinks <- result_analysis$links
  if (numlinks >= maxlinks)
    return()
  vecnames <- c("Network","Number","Species","Plants","Pollinators","Interactions","MaxKcore","MeanKdegree","MeanKdistance","MaxKdistance","NODF","Cscore","RemovedLinks", "Type") #"wine","Cscore")
  resultdf <- data.frame(matrix(ncol = length(vecnames), nrow = numexper*max(1,round(numlinks*wipedperc)) ))
  names(resultdf) <- vecnames
  vnodf <- rep(0,numexper)
  vkdist <- rep(0,numexper)
  pref <- ""
  limsup <- round(numlinks*wipedperc)
  rseed <- runif(numexper)
  if(analizatodo)
  {

    indexrow <- 1

    for (e in 1:numexper)
    {
      unlink(Sys.glob("datarnd/M*.csv"))
      if (num_hops == 0)
        intervalo = 1
      else
        intervalo <- round(max(1,(0.25*((rseed[e]>0.75)-(rseed[e]<0.25))+1)*round(limsup/max(1,num_hops))))
      print(paste0("EXPERIMENTO",e))
      pref <- "RND"
      directorystr <- "datarnd/"
      limsup <- round(numlinks*wipedperc)

      wipelinks <- seq(1,max(1,round(numlinks*wipedperc)),by = intervalo)
      # Ad points in the first and second intervals
      if (num_hops > 0){
        if (wipelinks[2]>5){
          addpoints1 <- sample(seq(1,wipelinks[2]),min(5,round(wipelinks[2]/5)))
          addpoints2 <- sample(seq(wipelinks[2]),min(4,round(wipelinks[3]/4)))
          wipelinks <- unique(c(addpoints1,addpoints2,wipelinks))
        }
      }
      for (qlinks in wipelinks)
        prandomize_and_write(matrix_orig, red, bypercentage = FALSE,directory = directorystr, rlinks = qlinks)
      nfiles <- Sys.glob(paste0(directorystr,paste0(strsplit(red,"\\.")[[1]][1],"*.csv")))
      if (e == 1){
        if (grepl("_SD_",nfiles[1]))
          Tipo <- "Disperser"
        else
          Tipo <- "Pollinator"
      }
      resultdf$Type <- Tipo
      for (l in nfiles)
      {
        print(l)
        namefile <- strsplit(l,"/")
        namenetwork <- namefile[[1]][2]
        resultdf$RemovedLinks[indexrow] <- strsplit(strsplit(namefile[[1]][2],"\\.")[[1]][1],"_lnk_")[[1]][2]
        result_analysis <- analyze_network(namenetwork, directory = directorystr, guild_a = "pl", guild_b = "pol", plot_graphs = FALSE, only_NODF = TRUE)
        resultdf$Network[indexrow] <- namenetwork
        resultdf$Plants[indexrow] <- result_analysis$num_guild_a
        resultdf$Pollinators[indexrow] <- result_analysis$num_guild_b
        resultdf$Species[indexrow] <- resultdf$Pollinators[indexrow] + resultdf$Plants[indexrow]
        resultdf$Interactions[indexrow] <- numlinks
        resultdf$MaxKcore[indexrow] <- result_analysis$max_core
        distances <- V(result_analysis$graph)$kradius
        if (length(distances[distances!=Inf])>0)
          resultdf$MaxKdistance[indexrow] <- max(distances[distances!=Inf])
        else {
          print("ALAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAARRRRRRRRRRRRRRRRRRRRRRMAAAAAAAAAAAAAA")
          resultdf$MaxKdistance[indexrow] <- NA
        }
        if (is.na(resultdf$MeanKdistance[indexrow])){
          resultdf$MeanKdistance[indexrow] <- result_analysis$meandist
        } else {
          resultdf$MeanKdistance[indexrow] <- resultdf$MeanKdistance[indexrow] + result_analysis$meandist
        }
        resultdf$MeanKdegree[indexrow] <- result_analysis$meankdegree
        if (is.na(resultdf$NODF[indexrow])){
          resultdf$NODF[indexrow] <- result_analysis$nested_values["NODF"]
        } else  {
          resultdf$NODF[indexrow] <- resultdf$NODF[indexrow] + result_analysis$nested_values["NODF"]
        }
        print(paste("NODF",resultdf$NODF[indexrow]))
        resultdf$Cscore[indexrow] <- result_analysis$nested_values["C.score"]
        indexrow <- indexrow +1
      }

    }
    save(resultdf, file=paste0('results_rnd/',pref,'datos_analisis_',unlist(strsplit(red,".csv")),'_numexper_',numexper,'.RData'), compress=TRUE)
  }
}

alldir <- TRUE
#alldir <- FALSE

load("results/datos_analisis.RData")

if (alldir) {
  tipos_de_red <- c("Binary")
  p<- Sys.glob("data/M*.csv")
  listfiles <- gsub("data/","",p)
  listfiles <- resultdf[is.element(resultdf$MatrixClass,tipos_de_red),]$Network
} else
  listfiles <-c("M_PL_012.csv")

for (i in listfiles)
    wipe_random(i,analizatodo = TRUE, numexper = 10, wipedperc = 0.5, num_hops = 20)
