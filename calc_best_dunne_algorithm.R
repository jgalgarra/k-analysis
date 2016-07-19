# This script compares the outcome of the second extinction experiment
#
# Results are stored at "extinctions/"
#
# Requires:
# Execution of extictions_compare.py

library(stringr)

dunnealgorithm <- TRUE
saveresults <- TRUE

if (dunnealgorithm){
  appstr <- "_byplants"
  strm <- "dunnemethod"
} else{
  appstr <- ""
  strm <- "juanmamethod"
}

ignoreMR <- FALSE
ignoreksh <- TRUE
ignoreKrad <- TRUE
ignoreKriskKdegree <- TRUE
ignoreKshKrad <- TRUE
ignoreNoOrder <- TRUE


  rj <-  read.table(paste0("python/results/",strm,"/DIAM_EXTIN_ALL_",strm,".txt"), quote="\"", comment.char="")
  names(rj) <- c("area_NoOrder","area_Krad","area_KshKrad","area_MR","area_Krisk","area_KriskKdegree","area_Kdegree","area_Degree", "area_eigenc" )
  if (ignoreMR)
    rj$area_MR = 1.0
  if (ignoreKrad)
    rj$area_Krad = 1.0
  if (ignoreKriskKdegree)
    rj$area_KriskKdegree = 1.0
  if (ignoreKshKrad)
    rj$area_KshKrad = 1.0
  if (ignoreNoOrder)
    rj$area_NoOrder = 1.0
  ficheros <- Sys.glob("data/M_*.csv")
  redes <- str_replace(ficheros,"data/","")
  rj$Network <- redes

  rj$best <- apply(rj[,1:7],1,min)
  fsal <- paste0("extinctions/extinctions_dunne_juanma_",strm,"_area.csv")
  write.csv(rj,fsal)
  results_ext <- read.csv(fsal)
  num_redes <- nrow(results_ext)
  print(paste0("Juanma code with ",strm))
  bkrisk <- sum(results_ext$area_Krisk <= results_ext$best)
  print(sprintf("krisk is the best for %d networks (%.2f%%)",bkrisk,100*bkrisk/num_redes))


  if (!ignoreKriskKdegree){
    bkriskkdeg <- sum(results_ext$area_KriskKdegree <= results_ext$best)
    print(sprintf("KriskKdegree is the best for %d networks (%.2f%%)",bkriskkdeg,100*bkriskkdeg/num_redes))
  }

  if(!ignoreKshKrad)
  {
    bkskr <- sum(results_ext$area_KshKrad <= results_ext$best)
    print(sprintf("KshKrad is the best for %d networks (%.2f%%)",bkskr,100*bkskr/num_redes))
  }

  bkdegree <- sum(results_ext$area_Kdegree <= results_ext$best)
  print(sprintf("kdegree is the best for %d networks (%.2f%%)",bkdegree,100*bkdegree/num_redes))

  bdegree <- sum(results_ext$area_Degree <= results_ext$best)
  print(sprintf("degree is the best for %d networks (%.2f%%)",bdegree,100*bdegree/num_redes))

  bMR <- sum(results_ext$area_MR <= results_ext$best)
  print(sprintf("MusRank is the best for %d networks (%.2f%%)",bMR,100*bMR/num_redes))

  if (!ignoreKrad){
  bkrad <- sum(results_ext$area_Krad <= results_ext$best)
  print(sprintf("krad is the best for %d networks (%.2f%%)",bkrad,100*bkrad/num_redes))
  }

  beigenc <- sum(results_ext$area_eigenc <= results_ext$best)
  print(sprintf("eigenc is the best for %d networks (%.2f%%)",beigenc,100*beigenc/num_redes))

  if (saveresults)
    write.csv(paste0("extinctions/results_",strm,".csv"))
