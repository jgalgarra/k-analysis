# Normalized area extinction plots for the second destruction algorithm
# Output data at graphs
#
#
# Parameters:
#  red                  Network name
#  languaEl             Language "ES","EN"
#  metodo               "juanmamethod" (measures remaining GC), "dunnemethod" (measures surviving plant species)
# Requires:
#   Extinctions data at "extinctions/"

library(ggplot2)
library(grid)
library(gridExtra)

red <- "M_PL_001"

languageEl <- "EN"
crit <- "MusRank"

metodo <- "dunnemethod"
if (metodo == "juanmamethod") {
  if (languageEl == "EN"){
    ytext <- "Remaining Giant Component (%)\n"
  } else {
    ytext <- "Componente gigante que queda (%)\n"
  }

} else  {
  if (languageEl == "ES"){
    ytext <- "Plantas sobrevivientes (%)\n"
  } else {
    ytext <- "Surviving plants (%)\n "
  }
}

if (languageEl == "ES"){
  xtext <- "\nAnimales eliminados (%) segun "
} else {
  xtext <- "\nRemoved animals (%) by "
}

dfjuanma <- read.csv("extinctions/extinctions_dunne_juanma_juanmamethod_area.csv")
dfdunne <- read.csv("extinctions/extinctions_dunne_juanma_dunnemethod_area.csv")
juanma_criterio <- read.table(paste0("python/results/",metodo,"/",red,"_Diam_extin_",crit,".txt"), quote="\"", comment.char="")
names(juanma_criterio) <- c("Primary","RemainingGC")
areadmr <- dfdunne[dfdunne$Network == paste0(red,".csv"),]$area_MR
p <- ggplot(data = juanma_criterio, aes(x = Primary*100, y = RemainingGC*100)) + geom_area(color = "violetred1",fill="violetred1",alpha=0.3) +
  theme_bw() + ylab(ytext)+xlab(paste0(xtext,crit))+ggtitle(red)+
  geom_text(data = juanma_criterio,aes(x = 65, y= 85,
                              label = paste0("Area = ",areadmr))
  , color= "black", hjust= 0, size = 4) +
  theme(axis.line.x = element_line(color="black", size = 0.5),
        axis.line.y = element_line(color="black", size = 0.5))+
  theme(panel.border = element_blank(),
        legend.key = element_blank(),
        panel.grid.minor.x = element_blank(),
        panel.grid.minor.y = element_blank(),
        panel.grid.major.y = element_line(linetype = 2, color="ivory3"),
        panel.grid.major.x = element_blank(), #,element_line(linetype = 2, color="slategray"),
        panel.border = element_blank(),
        legend.title = element_text(size=9, face="bold"),
        legend.text = element_text(size=9, face="bold"),
       #axis.line = element_line(colour = "black"),
        plot.title = element_text(lineheight=.6, face="bold"),
        axis.text = element_text(face="bold", size=10),
        axis.title.x = element_text(face="bold", size=10),
        axis.title.y  = element_text(face="bold", size=11) )

  crit <- "Kdegree"
  areadkd <- dfdunne[dfdunne$Network == paste0(red,".csv"),]$area_Kdegree
  juanma_criterio <- read.table(paste0("python/results/",metodo,"/",red,"_Diam_extin_",crit,".txt"), quote="\"", comment.char="")
  names(juanma_criterio) <- c("Primary","RemainingGC")
  q <- ggplot(data = juanma_criterio, aes(x = Primary*100, y = RemainingGC*100)) + geom_area(color = "lightblue",fill="lightblue",alpha=0.3) +
    theme_bw() + ylab(ytext)+xlab(paste0(xtext,crit))+ggtitle(red)+
    geom_text(data = juanma_criterio,aes(x = 65, y= 85,
                                         label = paste0("Area = ",areadkd))
    , color= "black", hjust= 0, size = 4) +
    theme(axis.line.x = element_line(color="black", size = 0.5),
          axis.line.y = element_line(color="black", size = 0.5))+
    theme(panel.border = element_blank(),
          legend.key = element_blank(),
          panel.grid.minor.x = element_blank(),
          panel.grid.minor.y = element_blank(),
          panel.grid.major.y = element_line(linetype = 2, color="ivory3"),
          panel.grid.major.x = element_blank(), #,element_line(linetype = 2, color="slategray"),
          panel.border = element_blank(),
          legend.title = element_text(size=9, face="bold"),
          legend.text = element_text(size=9, face="bold"),
          #axis.line = element_line(colour = "black"),
          plot.title = element_text(lineheight=.6, face="bold"),
          axis.text = element_text(face="bold", size=10),
          axis.title.x = element_text(face="bold", size=10),
          axis.title.y  = element_text(face="bold", size=11) )

  crit <- "MusRank"
  metodo <- "juanmamethod"

  if (metodo == "juanmamethod") {
    if (languageEl == "EN"){
      ytext <- "Remaining Giant Component (%)\n"
    } else {
      ytext <- "Componente gigante que queda (%)\n"
    }

  } else  {
    if (languageEl == "ES"){
    ytext <- "Plantas sobrevivientes (%)\n"
    } else {
    ytext <- "Surviving plants (%)\n "
    }
  }

  juanma_criterio <- read.table(paste0("python/results/",metodo,"/",red,"_Diam_extin_",crit,".txt"), quote="\"", comment.char="")
  names(juanma_criterio) <- c("Primary","RemainingGC")
  areajmr <- dfjuanma[dfjuanma$Network == paste0(red,".csv"),]$area_MR

  r <- ggplot(data = juanma_criterio, aes(x = Primary*100, y = RemainingGC*100)) + geom_area(color = "violetred1",fill="violetred1",alpha=0.3) +
    theme_bw() + ylab(ytext)+xlab(paste0(xtext,crit))+ggtitle(red)+
    geom_text(data = juanma_criterio,aes(x = 65, y= 85,
                                         label = paste0("Area = ",areajmr))
              , color= "black", hjust= 0, size = 4) +
    theme(axis.line.x = element_line(color="black", size = 0.5),
          axis.line.y = element_line(color="black", size = 0.5))+
    theme(panel.border = element_blank(),
          legend.key = element_blank(),
          panel.grid.minor.x = element_blank(),
          panel.grid.minor.y = element_blank(),
          panel.grid.major.y = element_line(linetype = 2, color="ivory3"),
          panel.grid.major.x = element_blank(), #,element_line(linetype = 2, color="slategray"),
          panel.border = element_blank(),
          legend.title = element_text(size=9, face="bold"),
          legend.text = element_text(size=9, face="bold"),
          #axis.line = element_line(colour = "black"),
          plot.title = element_text(lineheight=.6, face="bold"),
          axis.text = element_text(face="bold", size=10),
          axis.title.x = element_text(face="bold", size=10),
          axis.title.y  = element_text(face="bold", size=11) )

  crit <- "Kdegree"
  areajkd <- dfjuanma[dfjuanma$Network == paste0(red,".csv"),]$area_Kdegree
  juanma_criterio <- read.table(paste0("python/results/",metodo,"/",red,"_Diam_extin_",crit,".txt"), quote="\"", comment.char="")
  names(juanma_criterio) <- c("Primary","RemainingGC")
  s <- ggplot(data = juanma_criterio, aes(x = Primary*100, y = RemainingGC*100)) + geom_area(color = "lightblue",fill="lightblue",alpha=0.3) +
    theme_bw() + ylab(ytext)+xlab(paste0(xtext,crit))+ggtitle(red)+
    geom_text(data = juanma_criterio,aes(x = 65, y= 85,
                                         label = paste0("Area = ",areajkd))
              , color= "black", hjust= 0, size = 4) +
    theme(axis.line.x = element_line(color="black", size = 0.5),
          axis.line.y = element_line(color="black", size = 0.5))+
    theme(panel.border = element_blank(),
          legend.key = element_blank(),
          panel.grid.minor.x = element_blank(),
          panel.grid.minor.y = element_blank(),
          panel.grid.major.y = element_line(linetype = 2, color="ivory3"),
          panel.grid.major.x = element_blank(), #,element_line(linetype = 2, color="slategray"),
          panel.border = element_blank(),
          legend.title = element_text(size=9, face="bold"),
          legend.text = element_text(size=9, face="bold"),
          #axis.line = element_line(colour = "black"),
          plot.title = element_text(lineheight=.6, face="bold"),
          axis.text = element_text(face="bold", size=10),
          axis.title.x = element_text(face="bold", size=10),
          axis.title.y  = element_text(face="bold", size=11) )


  ppi <- 300
  png(paste0("graphs/",red,"_",metodo,"_extinction_plot.png"), width=(8*ppi), height=8*ppi, res=ppi)
  grid.arrange(p,q,r,s,nrow=2,ncol=2)
  dev.off()

  ppi <- 300
  png(paste0("graphs/",red,"_MRdunne_extinction_plot.png"), width=(4*ppi), height=4*ppi, res=ppi)
  print(p)
  dev.off()
