# This script generates the k-shell density matrixes 
# the null model of one network
#
# Plots are stored at graphs/matrix 
#
# Requires:
#
# Results of destruction experiments at python/dunnemethod

library(ggplot2)
library(scales)
library(grid)
library(gridExtra)

alldir <- TRUE

paint_matrix <- function(pathk,filek)
{
  print(filek)
  if (grepl("PL",filek)){
    yt <- "Plants"
    xt <- "Pollinators"
  } else {
    yt <- "Plants"
    xt <- "Dispersers"
  }
  tdf <- NULL
  datak <- read.table(paste0(pathk,filek))
  pdatak <- datak/sum(datak)
  filas <- nrow(pdatak)
  columnas <- ncol(pdatak)
  for(m in 1:filas)
  {
    for (l in 1:columnas)
    {
      adf <- data.frame(kf = m, kc = l, val = pdatak[filas-m+1,l])
      tdf <- rbind(adf,tdf)
    }
  }
  mf <- ggplot(tdf, aes(kf,kc, fill = val)) + geom_tile() + theme_bw() +
    scale_fill_gradient(limits = c(0, max(0.7,max(tdf$val)) ),low="white", high="red", name="Fraction of\nlinks\n")+ 
    scale_x_continuous(name =paste("\n",xt,"k-shell"),breaks=seq(1,columnas),labels=seq(columnas,1))+
    scale_y_continuous(name =paste(yt,"k-shell\n"),breaks=seq(1,filas),labels=seq(1,filas))+
    ggtitle(gsub("_KM.txt","",filek))+
    theme( panel.border = element_blank(),
           panel.grid.minor.x = element_blank(),
           panel.grid.minor.y = element_blank(),
           panel.grid.major.x = element_blank(),
           panel.grid.major.y = element_blank(),
           axis.title.x = element_text(color="grey30", size=14),
           axis.title.y = element_text(color="grey30", size=14),
           axis.text.x = element_text(face="bold", color="grey30", size=12),
           axis.text.y = element_text(face="bold", color="grey30", size=12))
  #print(mf)
  ppi <- 300
  png(paste0("graphs/matrix/",gsub("_KM.txt","",filek),"_KMAT.png"), width=(6*ppi), height=6*ppi, res=ppi)
  print(mf)
  dev.off()
  #return(mf)
}

pathstr <- "python/results/dunnemethod/"

if (alldir) {
  p<- Sys.glob(paste0(pathstr,"M*KM.txt"))
  listfiles <- gsub(pathstr,"",p)  
} else
  listfiles <- c("M_PL_059_KM.txt")

for (i in listfiles)
{
  o <- paint_matrix(pathstr,i)
}