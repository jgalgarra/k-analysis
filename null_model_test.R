# Null model analysis of all the networks
# Output data at resultsnulls
#
# WARNING: The execution of this script for all networks may take several days !!!!
#
# Parameters:
#  analizatodo <- TRUE    Analyisis of all networks at data/M*.csv
# Requires:
# general analysis results "results/datos_analisis.RData"


library(bipartite)
library(kcorebip)


vecnames <- c("Network","type","null_method","cycles","NODF","media_nodf","sd_nodf","z_nodf",
              "Modularity","media_modularity","sd_modularity","z_modularity",
              "MeanKradius","media_MeanKradius", "sd_MeanKradius", "z_MeanKradius",
              "specradius", "media_specradius", "sd_specradius", "z_specradius" )

load("results/datos_analisis.RData")

analizatodo <- TRUE
analizatodo <- FALSE

write_results <- TRUE

tipos_de_red <- c("Weighted","Binary")

if (analizatodo) {
  p<- Sys.glob("data/M*SD*.csv")
  ldir <- gsub("data/","",p)
  listfiles <- resultdf[is.element(resultdf$MatrixClass,tipos_de_red),]$Network
  listfiles <- listfiles[is.element(listfiles,ldir)]
  #listfiles <- c("M_SD_028.csv")
  # "M_SD_021.csv","M_SD_022.csv","M_SD_023.csv","M_SD_024.csv","M_SD_025.csv","M_SD_026.csv","M_SD_027.csv","M_SD_028.csv","M_SD_029.csv")
  #


} else
  listfiles <- c("M_PL_053.csv","M_PL_054.csv","M_PL_055.csv","M_PL_056.csv","M_PL_057.csv","M_PL_058.csv","M_PL_059.csv")


intentos <- 1000

zinit_time <- proc.time()

for (name_red in listfiles)
{
  auxdfnulls <- data.frame(matrix(ncol = length(vecnames), nrow = 0))
  names(auxdfnulls) <- vecnames
  print(name_red)
  tipo_red <- resultdf[resultdf$Network == name_red,]$MatrixClass
  print(tipo_red)
  raw_net <- read.csv(paste0("data/",name_red),header=TRUE,stringsAsFactors=FALSE)
  #raw_net[raw_net>0] <- 1
  rnames <- raw_net[,1]
  raw_matrix <- apply(as.matrix.noquote(raw_net[,seq(2,ncol(raw_net) )]),2,as.numeric)
  dimnames(raw_matrix)[[1]] <- rnames

  result_analysis <- analyze_network(name_red, directory = "data/", guild_a = "Plant", guild_b = "Pollinator", plot_graphs = FALSE, only_NODF = TRUE)
  obsnodf <- result_analysis$nested_values["NODF"]
  obsradius <- result_analysis$meandist
  obswradius <- result_analysis$meandist/(result_analysis$max_core+1)
  obsmodularity <- result_analysis$modularity_measure
  eigc <- eigen(get.adjacency(result_analysis$graph))$values
  obsspecradius <- max(abs(eigc))


  valnodfs <- rep(0,intentos)
  valmodularity <- rep(0,intentos)
  valradius <- rep(0,intentos)
  valspecradius <- rep(0,intentos)
  valwradius <- rep(0,intentos)
  if (tipo_red == "Weighted")
    metodo <- 2   # swap.web
  else
    metodo <- 5   # mgen
  index_row <- 1
  for (i in 1:intentos)
  {
    print(i)
    zend_time <- proc.time()
    print("Tiempo de an?lisis acumulado de esta red")
    print(zend_time - zinit_time)
    o <- bipartite::nullmodel(raw_matrix, N=1, method=metodo)
    write.csv(o,"datatemp/temp.csv")
    result_analysis <- analyze_network("temp.csv", directory = "datatemp/", guild_a = "Plant", guild_b = "Pollinator", plot_graphs = FALSE, only_NODF = TRUE)
    eigc <- eigen(get.adjacency(result_analysis$graph))$values
    ispecradius <- max(abs(eigc))
    print(paste("Spectral radius",max(eigc)))
    valnodfs[i] <- result_analysis$nested_values["NODF"]
    valmodularity[i] <- result_analysis$modularity_measure
    valradius[i] <- result_analysis$meandist
    valwradius[i] <- result_analysis$meandist/(result_analysis$max_core+1)
    valspecradius[i] <- ispecradius
    print(paste("valradius",result_analysis$meandist,"max k core",result_analysis$max_core, "valwradius",  result_analysis$meandist/(result_analysis$max_core) ))
  }

  fvalnodfs <- valnodfs[!is.nan(valnodfs)]
  media_nodf <- mean(fvalnodfs)
  sd_nodf <- sd(fvalnodfs)
  z_nodf <- (obsnodf-media_nodf)/sd_nodf
  if (!analizatodo){
    plot(density(fvalnodfs), xlim=c(min(obsnodf, min(fvalnodfs)), max(obsnodf, max(fvalnodfs))),
        main=sprintf("%s NODF: %0.2f  Mean: %0.2f  Z score: %0.5f method %d",name_red, obsnodf,media_nodf,z_nodf,metodo))
    abline(v=obsnodf, col="red", lwd=2)
  }

  fvalmodularity <- valmodularity[!is.nan(valmodularity)]
  media_modularity <- mean(fvalmodularity)
  sd_modularity <- sd(fvalmodularity)
  z_modularity <- (obsmodularity-media_modularity)/sd_modularity
  if (!analizatodo){
    plot(density(fvalmodularity), xlim=c(min(obsmodularity, min(fvalmodularity)), max(obsmodularity, max(fvalmodularity))),
         main=sprintf("%s modularity: %0.2f  Mean: %0.2f  Z score: %0.5f method %d",name_red, obsmodularity,media_modularity,z_modularity,metodo))
    abline(v=obsmodularity, col="red", lwd=2)
  }

  fvalradius <- valradius[!is.nan(valradius)]
  media_radius <- mean(fvalradius)
  sd_radius <- sd(fvalradius)
  z_radius <- (obsradius-media_radius)/sd_radius
  if (!analizatodo){
    plot(density(fvalradius), xlim=c(min(obsradius, min(fvalradius)), max(obsradius, max(fvalradius))),
        main=sprintf("%s Kradius: %0.2f  Mean: %0.2f  Z score: %0.5f method %d", name_red, obsradius,media_radius,z_radius,metodo))
    abline(v=obsradius, col="red", lwd=2)
  }

  fvalspecradius <- valspecradius[!is.nan(valspecradius)]
  media_specradius <- mean(fvalspecradius)
  sd_specradius <- sd(fvalspecradius)
  z_specradius <- (obsspecradius-media_specradius)/sd_specradius
  if (!analizatodo){
    plot(density(fvalspecradius), xlim=c(min(obsspecradius, min(fvalspecradius)), max(obsspecradius, max(fvalspecradius))),
         main=sprintf("%s specradius: %0.2f  Mean: %0.2f  Z score: %0.5f method %d", name_red, obsspecradius,media_specradius,z_specradius,metodo))
    abline(v=obsspecradius, col="red", lwd=2)
  }


  if (analizatodo | write_results){
    auxdfnulls[index_row,]$Network = name_red
    auxdfnulls[index_row,]$NODF = obsnodf
    auxdfnulls[index_row,]$Modularity = obsmodularity
    auxdfnulls[index_row,]$type = tipo_red
    auxdfnulls[index_row,]$cycles = intentos
    auxdfnulls[index_row,]$null_method = metodo
    auxdfnulls[index_row,]$media_nodf = media_nodf
    auxdfnulls[index_row,]$sd_nodf = sd_nodf
    auxdfnulls[index_row,]$z_nodf = z_nodf
    auxdfnulls[index_row,]$media_modularity = media_modularity
    auxdfnulls[index_row,]$sd_modularity = sd_modularity
    auxdfnulls[index_row,]$z_modularity = z_modularity
    auxdfnulls[index_row,]$MeanKradius = obsradius
    auxdfnulls[index_row,]$media_MeanKradius = media_radius
    auxdfnulls[index_row,]$sd_MeanKradius = sd_radius
    auxdfnulls[index_row,]$z_MeanKradius = z_radius
    auxdfnulls[index_row,]$specradius = obsspecradius
    auxdfnulls[index_row,]$media_specradius = media_specradius
    auxdfnulls[index_row,]$sd_specradius = sd_specradius
    auxdfnulls[index_row,]$z_specradius = z_specradius
    index_row <- index_row+1
  }
  if (analizatodo | write_results){
    dfindivs <- data.frame(     NODF = valnodfs, Modularity = valmodularity, MeanKradius = valradius, Specradius = valspecradius)
    save(auxdfnulls, file=paste0('resultsnulls/',strsplit(name_red,".csv")[[1]],'_auxdfnulls_',tipo_red,'_cycles_',intentos,'_method_',metodo,'.RData'), compress=TRUE)
    save(dfindivs, file=paste0('resultsnulls/',strsplit(name_red,".csv")[[1]],'_dfindivs_',tipo_red,'_cycles_',intentos,'_method_',metodo,'.RData'), compress=TRUE)
  }
}