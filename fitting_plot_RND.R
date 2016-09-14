# Paint plots of rewiring experiment
# Output data at results_rnd/figs
# Parameters:
#  alldir <- TRUE    Analyisis of all networks at data/M*.csv
# Requires:
# null model  results at "resultsnulls"
# rewiring data at "results_rnd"
# general analysis results "results/datos_analisis.RData"

library(grid)
library(gridExtra)
library(stringr)
library(kcorebip)


paint_zgraph <- function(red,language = "ES", paintnull = TRUE)
{
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
  mresultdf <- resultdf

#   for (k in 1:numexper-1)
#     mresultdf[posorig+k,] <- resultdf[posorig,]

  model <- lm(log(MeanKdistance) ~ NODF, data = mresultdf)
  fitted_model <- data.frame(
    NODF = mresultdf$NODF, MeanKdistance = mresultdf$MeanKdistance,
    predict(model, interval = "confidence")
  )

  layer_line <- geom_line(
    mapping = aes(x = NODF, y = exp(fit)),
    data = fitted_model,
    color = "darkgrey"
  )

  layer_ribbon <- geom_ribbon(
    mapping = aes( ymin = exp(lwr), ymax = exp(upr)),
    data = fitted_model,
    alpha = 0.1
  )

  resultdf <- resultdf[!is.na(resultdf$Species),]
  p <- ggplot(resultdf, aes(y=as.numeric(MeanKdistance),x=as.numeric(NODF)),legendTextFont=c(15, "bold.italic", "red")) +
        geom_point(aes(colour = 100*as.numeric(RemovedLinks)/as.numeric(Interactions[1])), alpha = 0.5) +
        ylab("K-radius medio\n") + xlab("\nNODF")+
        scale_colour_gradient(low="blue", high="red",name = "Recableado (%)")+
        coord_trans(y="log") +
        ggtitle(sprintf("Red %s Correlaci?n: %.02f", red, cor(resultdf$MeanKdistance,resultdf$NODF))) +
        theme_bw() +
        theme(panel.border = element_blank(),
              panel.grid.major.y = element_line(size = 0.3, linetype = 3, color="grey"),
              panel.grid.major.x = element_line(size = 0.3, linetype = 3, color="grey"),
              panel.grid.minor = element_blank(),
              legend.key = element_blank(),
              legend.position = 'right',
              axis.line = element_line(colour = "black"),
              axis.title.x = element_text(color="grey30", size=12),
              axis.title.y = element_text(color="grey30", size=12),
              axis.text.x = element_text(face="bold", color="grey30", size=11),
              axis.text.y = element_text(face="bold", color="grey30", size=11),
              plot.title = element_text(lineheight=.8, face="plain")
              )

tresultdf <- mresultdf
tresultdf$alfa <- 0.5
tresultdf$psize <- 1.5*tresultdf$MaxKcore/kcoreorig
tresultdf$shape <- 16
sizepoint <- 0.8
#tresultdf$psize[posorig] <- sizepoint
tresultdf$shape[posorig] <- 13

tresultdf$psize[posorig] <- 3
tresultdf$alfa[posorig] <- 1

offset <- nrow(resultdf) #+numexper

if (paintnull) {
  for (i in 1:nrow(dfindivs)){
     tresultdf[i+offset,] <- tresultdf[1,]
     tresultdf$RemovedLinks[i+offset] = 0
     tresultdf$NODF[i+offset] = dfindivs$NODF[i]
     tresultdf$MeanKdistance[i+offset] = dfindivs$MeanKradius[i]
     tresultdf$alfa[i+offset] = 0.1
     tresultdf$psize[i+offset] <- 0.8
     tresultdf$shape[i+offset] <- 3
  }
}

title_plot <- list()
title_plot["ES"] <- "Red %s Correlaci?n: %.02f"
title_plot["EN"] <- "Network %s Correlation: %.02f"
text_legend <- list()
text_legend["ES"] <- "Recableado (%)"
text_legend["EN"] <- "Rewiring (%)"
title_Y <- list()
title_Y["ES"] <- "K-radius medio\n"
title_Y["EN"] <- "Mean k-radius\n"


overlap <- ggplot(tresultdf, aes(y=as.numeric(MeanKdistance),x=as.numeric(NODF)),legendTextFont=c(15, "bold.italic", "red")) +
  geom_point(aes(colour = 100*as.numeric(RemovedLinks)/as.numeric(Interactions[1])),
             alpha = tresultdf$alfa, size = tresultdf$psize,
             shape = tresultdf$shape) +
  ylab(title_Y[[language]]) + xlab("\nNODF")+
  scale_colour_gradient(low="blue", high="red",name = text_legend[[language]])+
  coord_trans(y="log") +
  ggtitle(sprintf(title_plot[[language]], red, cor(log(resultdf$MeanKdistance),resultdf$NODF))) +
  theme_bw() +
  theme(panel.border = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        legend.key = element_blank(),
        legend.position = 'right',
        axis.line = element_line(colour = "black"),
        axis.title.x = element_text(color="grey30", size=12),
        axis.title.y = element_text(color="grey30", size=12),
        axis.text.x = element_text(face="bold", color="grey30", size=11),
        axis.text.y = element_text(face="bold", color="grey30", size=11),
        plot.title = element_text(lineheight=.8, face="plain")
  )

mean_nodf <- mean(dfindivs$NODF, na.rm = TRUE)
sd_nodf <- sd(dfindivs$NODF, na.rm = TRUE)
mean_avgkradius <- mean(dfindivs$MeanKradius, na.rm = TRUE)
sd_avgkradius <- sd(dfindivs$MeanKradius, na.rm = TRUE)
tresultdf$z_nodf <- (tresultdf$NODF - mean_nodf)/sd_nodf
tresultdf$z_avgkradius <- (tresultdf$MeanKdistance - mean_avgkradius)/sd_avgkradius


title_plot_1 <- list()
title_plot_2 <- list()
title_plot_1["ES"] <- "%s, %s, Null model %s\n zNODF: %0.2f "
title_plot_1["EN"] <- title_plot_1["ES"]
title_plot_2["ES"] <- ": %0.2f Corr.: %.02f"
title_plot_2["EN"] <- title_plot_2["ES"]
text_legend <- list()
text_legend["ES"] <- "Recableado (%)\n"
text_legend["EN"] <- "Rewiring (%)\n"
title_Y <- list()
title_Y["ES"] <-  expression(paste("z ", bar(k)[radius],"\n"))
title_Y["EN"] <-  title_Y["ES"]

red_znodf <- (data_conf$NODF - mean_nodf)/sd_nodf
red_z_avgkradius <- (data_conf$MeanKradius - mean_avgkradius)/sd_avgkradius
zsum <- red_znodf - red_z_avgkradius

zresultdf <- tresultdf[seq(1,nrow(mresultdf)),]
zresultdf <- zresultdf[!is.na(zresultdf$z_avgkradius),]
zmodel <- lm(z_avgkradius ~ z_nodf, data = zresultdf)
zfitted_model <- data.frame(
  zNODF = zresultdf$z_nodf, zMeanKradius = zresultdf$z_avgkradius,
  predict(zmodel, interval = "confidence")
)

zlayer_line <- geom_line(
  mapping = aes(x = zNODF, y = fit),
  data = zfitted_model,
  color = "darkgrey"
)

overlapz <- ggplot(tresultdf, aes(y=as.numeric(z_avgkradius),x=as.numeric(z_nodf)),
                   legendTextFont=c(15, "bold.italic", "red")) +
  geom_point(aes(colour = 100*as.numeric(RemovedLinks)/as.numeric(Interactions[1])),
             alpha = tresultdf$alfa, size = tresultdf$psize,
             shape = tresultdf$shape) +
  ylab(title_Y[[language]]) + xlab("\nz NODF")+
  scale_colour_gradient(low="blue", high="red",name = text_legend[[language]])+
  #coord_trans(y="log") +
  ggtitle(paste0(
                sprintf(title_plot_1[[language]], red, data_conf$MatrixClass, nullmodels[as.numeric(modelo)],
                  zresultdf$z_nodf),
                "zkradius",
                sprintf(title_plot_2[[language]],zresultdf$z_avgkradius, cor(zresultdf$z_avgkradius,zresultdf$z_nodf))
                )
                ) +
  theme_bw() +
  theme(axis.line.x = element_line(color="black", size = 0.5),
        axis.line.y = element_line(color="black", size = 0.5))+
  theme(panel.border = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        legend.key = element_blank(),
        legend.position = 'right',
        legend.title = element_text(size=11,
                                    face="bold"),
        plot.title = element_text(size = 14),
        #axis.line = element_line(colour = "black"),
        axis.title.x = element_text(face="bold", color="grey30", size=14),
        axis.title.y = element_text(face="bold", color="grey30", size=14),
        axis.text.x = element_text(face="bold", color="grey30", size=13),
        axis.text.y = element_text(face="bold", color="grey30", size=13),
        plot.title = element_text(lineheight=.8, face="plain")
  )

#   ppi <- 300
#   png(paste0("results_rnd/figs/ESTATICA_",red,"_corr_rewiring.png"), width=(6*ppi), height=4*ppi, res=ppi)
#   print(overlap + layer_line)
#   dev.off()

  ppi <- 300
  png(paste0("results_rnd/figs/z_",red,"_rewire_",data_conf$MatrixClass,"_",language,"_model_",modelo,".png"), width=(8*ppi), height=5*ppi, res=ppi)
  print(overlapz+zlayer_line)
  dev.off()
}

alldir <- TRUE
alldir <- FALSE

# Read the general results to query NODF, links, etc
load("results/datos_analisis.RData")
data_networks <- resultdf

if (alldir) {
  tipos_de_red <- c("Binary")
  p<- Sys.glob("data/M*.csv")
  listfiles <- str_replace(p, "data/", "")
  listfiles <- resultdf[is.element(resultdf$MatrixClass,tipos_de_red),]$Network
  rm(resultdf)
  redes <- unlist(strsplit(listfiles,".csv"))

} else
  redes <- c("M_PL_001")

languagetitle <- "ES"
for (red in redes)
{
  print(red)
  paint_zgraph(red,language = languagetitle, paintnull = TRUE)
}
