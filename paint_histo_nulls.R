# This script generates the distribution plots of zKradius and zNODF of 
# the null model of one network
#
# Parameters:
# red               Network name
#
# Requires:
#
# Results of the null model experiment stored at resultsnulls

library(ggplot2)
library(grid)
library(gridExtra)

red <- "M_PL_022"
load("results/datos_analisis.RData")
resreal <- resultdf[resultdf$Network == paste0(red,".csv"),]
load(paste0("resultsnulls/",red,"_dfindivs_Binary_cycles_1000_method_5.RData"))
dftrans <- dfindivs[!is.nan(dfindivs$MeanKradius),]
mean_NODF <- mean(dftrans$NODF)
sd_NODF <- sd(dftrans$NODF)
z_NODF <- (resreal$NODF - mean_NODF)/sd_NODF
dftrans$NODF <- (dftrans$NODF - mean_NODF)/sd_NODF

p <- ggplot() + geom_density(aes(x=NODF), color = "violet", fill = "violet", alpha = .3,
                               data=dftrans)+ xlab("zNODF")+ylab("Density\n")+
  geom_vline(xintercept=z_NODF, size = 1, linetype = "dashed", color = "violetred1", alpha= 0.9) +
  geom_text(data = data.frame(z_NODF),aes(x = z_NODF-0.35, y= 0.1,
                                                   label = sprintf("Network zNODF = %1.2f",z_NODF)
  ), color= "violetred1", alpha= 0.9, hjust= 0, size = 4.5, angle = 90) +
  ggtitle(red)+
  theme_bw() +
  theme(panel.border = element_blank(),
        legend.key = element_blank(),
        panel.grid.minor.x = element_blank(),
        panel.grid.minor.y = element_blank(),
        panel.grid.major.y = element_line(linetype = 2, color="ivory3"),
        panel.grid.major.x = element_blank(), #,element_line(linetype = 2, color="slategray"),
        panel.border = element_blank(),
        legend.title = element_text(size=14, face="bold"),
        legend.text = element_text(size=8, face="bold"),
        axis.line = element_line(colour = "black"),
        plot.title = element_text(lineheight=.8, face="bold"),
        axis.text = element_text(face="bold", size=14),
        axis.title.x = element_text(face="bold", size=15),
        axis.title.y  = element_text(face="bold", size=15) )

mean_MeanKradius <- mean(dftrans$MeanKradius)
sd_MeanKradius <- sd(dftrans$MeanKradius)
z_MeanKradius <- (resreal$MeanKradius - mean_MeanKradius)/sd_MeanKradius
dftrans$MeanKradius <- (dftrans$MeanKradius - mean_MeanKradius)/sd_MeanKradius
load(paste0("resultsnulls/",red,"_dfindivs_Binary_cycles_1000_method_5.RData"))
q <- ggplot() + geom_density(aes(x=MeanKradius), color = "lightblue", fill = "lightblue", alpha = .3,
                             data=dftrans)+ xlab(expression(paste("z ", bar(k)[radius])))+ylab("Density\n")+
  geom_vline(xintercept=z_MeanKradius, size = 1, linetype = "dashed", color = "blue", alpha= 0.9) +
  geom_text(data = data.frame(z_MeanKradius),aes(x = z_MeanKradius+0.25, y= 0.05,
                                                 label = sprintf("Network zKradius = %1.2f",z_MeanKradius)
  ), color= "blue", alpha= 0.9, hjust= 0, size = 4.5, angle = 90) +  ggtitle(red)+

  theme_bw() +
  theme(panel.border = element_blank(),
        legend.key = element_blank(),
        panel.grid.minor.x = element_blank(),
        panel.grid.minor.y = element_blank(),
        panel.grid.major.y = element_line(linetype = 2, color="ivory3"),
        panel.grid.major.x = element_blank(), #,element_line(linetype = 2, color="slategray"),
        panel.border = element_blank(),
        legend.title = element_text(size=14, face="bold"),
        legend.text = element_text(size=8, face="bold"),
        axis.line = element_line(colour = "black"),
        plot.title = element_text(lineheight=.8, face="bold"),
        axis.text = element_text(face="bold", size=14),
        axis.title.x = element_text(face="bold", size=15),
        axis.title.y  = element_text(face="bold", size=15) )

ppi <- 300
png(paste0("graphs/",red,"_zALL.png"), width=(12*ppi), height=3.7*ppi, res=ppi)
grid.arrange(q,p, nrow=1, ncol=2)
dev.off()

ppi <- 300
png(paste0("graphs/",red,"_zNODF.png"), width=(6*ppi), height=3.7*ppi, res=ppi)
print(p)
dev.off()

ppi <- 300
png(paste0("graphs/",red,"_zKradius.png"), width=(6*ppi), height=3.7*ppi, res=ppi)
print(q)
dev.off()