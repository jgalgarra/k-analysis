# Computes the zscores of kradius and NODF for all the networks
# Output data at results_rnd/figs/
#
# Parameters:
#  alldir <- TRUE    Analyisis of all networks at data/M*.csv
# Requires:
# general analysis results "results/datos_analisis.RData"
# null model analysis at "resultsnulls"

library(grid)
library(gridExtra)
library(stringr)
library(kcorebip)

calc_zscores<- function(red,language = "ES")
{
  print(sprintf("Red %s",red))
  
  # Read the general results to query NODF, links, etc
  load("results/datos_analisis.RData")
  isbinary <- resultdf[resultdf$Network==paste0(red,".csv"),]$MatrixClass == "Binary"
  print(paste("isbinary",isbinary))
  rm(resultdf)
  pref <- "RND"
  if (isbinary)
  {
    fd <- Sys.glob(paste0("results_rnd/",pref,"datos_analisis_",red,"_numexper_*.RData"))
    listfiles <- gsub("results_rnd/","",fd)
    file_rewiring <- listfiles[1]
    numexper <- as.integer(str_replace(strsplit(file_rewiring,"_numexper_")[[1]][2],".RData",""))
    load( paste0("results_rnd/",listfiles[1]) )
  }
  
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
  if (isbinary){
    corr_zs <- cor(resultdf$NODF,resultdf$MeanKdistance)
  } else
    corr_zs = 0
  
  print(sprintf("znodf %0.2f zavgkradius %0.2f",z_nodf_red, z_avgkradius_red))
  calc_values <- list("z_nodf_red" = z_nodf_red, "z_avgkradius_red" = z_avgkradius_red, 
                      "method" = modelo, "corr_zs" = corr_zs)
  return(calc_values)
}

alldir <- TRUE

if (alldir) {
  load("results/datos_analisis.RData")
  p <- resultdf$Network
  listfiles <- str_replace(p, "data/", "")
  redes <- unlist(strsplit(listfiles,".csv"))
} else
  redes <- c("M_PL_046")

results_z <- data.frame(Network = NA, zNODF = NA, zAvgKradius = NA, method = NA, corr_zs = NA)
saveresults <- TRUE
languagetitle <- "ES"
i <- 1
for (red in redes){
  q <- calc_zscores(red,language = languagetitle)
  results_z[i,]$Network <- paste0(red,".csv")
  results_z[i,]$zNODF <- q[["z_nodf_red"]]
  results_z[i,]$zAvgKradius <- q[["z_avgkradius_red"]]
  results_z[i,]$method <- q[["method"]]
  results_z[i,]$corr_zs <- q[["corr_zs"]]
  i <- i+1
}
m <- results_z
r <- ggplot(results_z, aes(x = zNODF, y = zAvgKradius)) + geom_point(aes(color=method),size=0.5)+
  geom_vline(aes(xintercept=2), colour="darkgrey", linetype="dotted", size = 0.5)+
  geom_hline(aes(yintercept=-2), colour="darkgrey", linetype="dotted", size = 0.5) +
  geom_text(aes(colour = factor(method), 
                label = str_replace(str_replace(unlist(strsplit(results_z$Network,".csv")),"M_",""), "_0","")),
            hjust= -0.07, 
            fontface="bold", size=3)+
  xlab("\nz NODF") +
  ylab( expression(paste("z ", bar(k)[radius],"\n"))) +
  theme_bw()+
  theme(axis.title.x = element_text(face="bold",color="grey30", size=16),
        axis.title.y = element_text(face="bold",color="grey30", size=16),
        axis.text.x = element_text(face="bold", color="grey30", size=12),
        axis.text.y = element_text(face="bold", color="grey30", size=12),
        legend.text = element_text(face="bold", size=12),
        legend.title = element_text(face="bold", size=14),
        legend.key = element_rect(colour = 'transparent'))


ppi <- 300
png("results_rnd/figs/zscores.png", width=(8*ppi), height=8*ppi, res=ppi)
print(r)
dev.off()

results_z_s <- m[m$method == 5,]
s <- ggplot(results_z_s, aes(x = zNODF, y = zAvgKradius)) +# geom_point(color="salmon",size=1)+
  geom_vline(aes(xintercept=2), colour="violetred1", linetype="dashed", size = 0.4)+
  geom_hline(aes(yintercept=-2), colour="violetred1", linetype="dashed", size = 0.4) +
  geom_text(aes(label = str_replace(str_replace(unlist(strsplit(results_z_s$Network,".csv")),"M_",""), "_0","")),
            hjust= 0.5, colour = "salmon",angle = 0,
            fontface="bold", size=5, alpha = 0.7)+
  scale_x_continuous(breaks = seq(0,18,by=2)) +
  xlab("\nz NODF") + ggtitle("Binary")+
  ylab( expression(paste("z ", bar(k)[radius],"\n"))) +
  theme_bw()+
  theme(axis.title.x = element_text(face="bold",color="grey30", size=20),
        axis.title.y = element_text(face="bold",color="grey30", size=22),
        axis.text.x = element_text(face="bold", color="grey30", size=20),
        axis.text.y = element_text(face="bold", color="grey30", size=20),
        legend.position="none",
        panel.grid.minor = element_blank(),
        plot.title=element_text( face="bold", size=20),
        axis.line = element_line(colour = "grey"),
        legend.text = element_text(face="bold", size=12),
        legend.title = element_text(face="bold", size=14),
        legend.key = element_rect(colour = 'transparent'))

ppi <- 300
png("results_rnd/figs/zscores_binary.png", width=(8*ppi), height=8*ppi, res=ppi)
print(s)
dev.off()

results_z_t <- m[m$method == 2,]
t <- ggplot(results_z_t, aes(x = zNODF, y = zAvgKradius)) +# geom_point(color="salmon",size=1)+
  geom_vline(aes(xintercept=2), colour="violetred1", linetype="dashed", size = 0.4)+
  geom_hline(aes(yintercept=-2), colour="violetred1", linetype="dashed", size = 0.4) +
  geom_text(aes(label = str_replace(str_replace(unlist(strsplit(results_z_t$Network,".csv")),"M_",""), "_0","")),
            hjust= 0.5, colour = "blue",angle = 0,
            fontface="bold", size=5, alpha = 0.7)+
  scale_x_continuous(breaks = seq(-8,6,by=2)) +
  xlab("\nz NODF") + ggtitle("Weighted")+
  scale_y_continuous(breaks = seq(-8,6,by=2)) +
  ylab( expression(paste("z ", bar(k)[radius],"\n"))) +
  theme_bw()+
  theme(axis.title.x = element_text(face="bold",color="grey30", size=20),
        axis.title.y = element_text(face="bold",color="grey30", size=22),
        axis.text.x = element_text(face="bold", color="grey30", size=20),
        axis.text.y = element_text(face="bold", color="grey30", size=20),
        legend.position="none",
        panel.grid.minor = element_blank(),
        plot.title=element_text( face="bold", size=20),
        axis.line = element_line(colour = "grey"),
        legend.text = element_text(face="bold", size=12),
        legend.title = element_text(face="bold", size=14),
        legend.key = element_rect(colour = 'transparent'))
ppi <- 300
png("results_rnd/figs/zscores_weighted.png", width=(8*ppi), height=8*ppi, res=ppi)
print(t)
dev.off()

ppi <- 300
png("graphs/zscores_ALL.png", width=(16*ppi), height=10*ppi, res=ppi)
grid.arrange(t,s,ncol=2,nrow=1)
dev.off()