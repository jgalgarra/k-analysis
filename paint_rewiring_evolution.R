# This script plots the evolution of zkradius vs zNODF for three chosen networks
# results_rnd/figs/zscores_networks_evolution.png
#
# Requires:
# Rewiring experiment data at results_rnd/

library(grid)
library(gridExtra)
library(stringr)
library(kcorebip)

all_zscores<- function(red,language = "ES")
{
  print(sprintf("Red %s",red))

  # Read the general results to query NODF, links, etc
  load("results/datos_analisis.RData")
  data_networks <- resultdf
  rm(resultdf)

  pref <- "RND"

  fd <- Sys.glob(paste0("results_rnd/",pref,"datos_analisis_",red,"_numexper_*.RData"))
  listfiles <- gsub("results_rnd/","",fd)
  file_rewiring <- listfiles[1]
  numexper <- as.integer(str_replace(strsplit(file_rewiring,"_numexper_")[[1]][2],".RData",""))

  load( paste0("results_rnd/",listfiles[1]) )
  resultdf <- resultdf[!is.na(resultdf$MeanKdistance),]

  lf <- Sys.glob(paste0("resultsnulls/",red,"*_dfindivs_*.RData"))
  listfiles <- gsub("resultsnulls/","",lf)
  nullmodels <- c("r2dtable","swap.web","vaznull","suffle.web","mgen")

  load(paste0("resultsnulls/",listfiles[1]))


  data_conf <- data_networks[data_networks$Network == paste0(red,".csv"),]

  # Add original value

  nrowsdf <- nrow(resultdf)
  resultdf <- rbind(resultdf,resultdf[1,])
  resultdf[nrowsdf+1,]$NODF <- data_conf$NODF
  resultdf[nrowsdf+1,]$MeanKdistance <- data_conf$MeanKradius
  resultdf[nrowsdf+1,]$RemovedLinks <- 0
  nrowsdf <- nrowsdf+1
  posorig <- nrowsdf
  kcoreorig <- data_conf$MaxKcore

  # Add original value number of simulations-1 to build predictive model

  intentos <- as.integer(strsplit(strsplit(listfiles[[1]],"cycles_")[[1]],"_method")[[2]][1])
  modelo <- str_replace(strsplit(strsplit(strsplit(listfiles[[1]],"cycles_")[[1]],"_method")[[2]][2],".RData"),"_","")


  mean_nodf <- mean(dfindivs$NODF, na.rm = TRUE)
  sd_nodf <- sd(dfindivs$NODF, na.rm = TRUE)
  mean_avgkradius <- mean(dfindivs$MeanKradius, na.rm = TRUE)
  sd_avgkradius <- sd(dfindivs$MeanKradius, na.rm = TRUE)
  z_nodf_red <- (data_conf$NODF - mean_nodf)/sd_nodf
  z_avgkradius_red <- (data_conf$MeanKradius - mean_avgkradius)/sd_avgkradius
  corr_zs <- cor(resultdf$NODF,resultdf$MeanKdistance)

  print(sprintf("znodf %0.2f zavgkradius %0.2f",z_nodf_red, z_avgkradius_red))
  calc_values <- list("z_nodf_red" = z_nodf_red, "z_avgkradius_red" = z_avgkradius_red,
                      "method" = modelo, "corr_zs" = corr_zs, "zNODF_indivs" = (resultdf$NODF - mean_nodf)/sd_nodf,
                      "zAvgKradius_indivs" = (resultdf$MeanKdistance - mean_avgkradius)/sd_avgkradius )
  return(calc_values)
}

alldir <- FALSE

if (alldir) {
  p<- Sys.glob("data/M*.csv")
  listfiles <- str_replace(p, "data/", "")
  redes <- unlist(strsplit(listfiles,".csv"))
} else
  redes <- c("M_PL_032", "M_PL_012", "M_PL_046")

results_z <- data.frame(Network = NA, zNODF = NA, zAvgKradius = NA, method = NA, corr_zs = NA, zNODF_indivs = NA, zAvgKradius_indivs = NA )
saveresults <- TRUE
languagetitle <- "ES"
i <- 1
for (red in redes){
q <- all_zscores(red,language = languagetitle)
  results_z[i,]$Network <- paste0(red,".csv")
  results_z[i,]$zNODF <- q[["z_nodf_red"]]
  results_z[i,]$zAvgKradius <- q[["z_avgkradius_red"]]
  results_z[i,]$method <- q[["method"]]
  results_z[i,]$corr_zs <- q[["corr_zs"]]
  results_z[i,]$zNODF_indivs <- list(q[["zNODF_indivs"]])
  results_z[i,]$zAvgKradius_indivs <- list(q[["zAvgKradius_indivs"]])
  i <- i+1
}

results_z_todo <- data.frame(Network = NA, zNODF = NA, zAvgKradius = NA, method = NA, corr_zs = NA, zNODF_indivs = NA, zAvgKradius_indivs = NA , pshape = NA, psize = NA)
offset <- 0

for (k in 1:nrow(results_z))
{
for (i in 1:length(results_z$zAvgKradius_indivs[[k]]))
  {
    results_z_todo[i+offset,]$Network <- str_replace(strsplit(results_z$Network[k],".csv")[[1]],"M_","")
    results_z_todo[i+offset,]$zNODF <- results_z$zNODF[k]
    results_z_todo[i+offset,]$zAvgKradius <- results_z$zAvgKradius[k]
    results_z_todo[i+offset,]$method <- results_z$method[k]
    results_z_todo[i+offset,]$corr_zs <- results_z$corr_zs[k]
    results_z_todo[i+offset,]$zNODF_indivs <- results_z$zNODF_indivs[[k]][i]
    results_z_todo[i+offset,]$zAvgKradius_indivs <- results_z$zAvgKradius_indivs[[k]][i]
  }
  offset <- length(results_z$zAvgKradius_indivs[[k]])
}
results_z_todo$pshape <- 19

r <- ggplot(results_z_todo, aes(x = zNODF_indivs, y = zAvgKradius_indivs)) +
  geom_point(aes(color=Network),size=1.5,shape=15) +geom_line(aes(color=Network),size=2, alpha=0.25)+
  geom_vline(aes(xintercept=2), colour="darkgrey", linetype="dashed", size = 0.5)+
  geom_hline(aes(yintercept=-2), colour="darkgrey", linetype="dashed", size = 0.5) +
  geom_point(x=results_z_todo$zNODF[1],y=results_z_todo$zAvgKradius[1],size=4,color="springgreen4",shape=17) +
  geom_point(x=results_z_todo$zNODF[length(results_z$zAvgKradius_indivs[[1]])+1],y=results_z_todo$zAvgKradius[length(results_z$zAvgKradius_indivs[[1]])+1],size=4,color="salmon",shape=17) +
  geom_point(x=results_z_todo$zNODF[length(results_z$zAvgKradius_indivs[[2]])+1],y=results_z_todo$zAvgKradius[length(results_z$zAvgKradius_indivs[[2]])+1],size=4,color="steelblue3",shape=17) +
  xlab("\nz NODF") +
  ylab( expression(paste("z ", bar(k)[radius],"\n"))) +
  #paste0("z ",expression(tilde(k),"-radius")
  theme_bw()+
  theme(axis.title.x = element_text(face="bold",color="grey30", size=16),
    axis.title.y = element_text(face="bold",color="grey30", size=16),
    axis.text.x = element_text(face="bold", color="grey30", size=12),
    axis.text.y = element_text(face="bold", color="grey30", size=12),
    legend.text = element_text(face="bold", size=12),
    legend.title = element_text(face="bold", size=14),
    legend.key = element_rect(colour = 'transparent'))

dir.create("results_rnd/figs/", showWarnings = FALSE)
ppi <- 300
png("results_rnd/figs/zscores_networks_evolution.png", width=(10*ppi), height=7*ppi, res=ppi)
print(r)
dev.off()
