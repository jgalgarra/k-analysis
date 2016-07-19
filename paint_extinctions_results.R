# This script compares results of the half giant component destruction and creates plots

library(ggplot2)
library(gridExtra)


languageEl <- "ES"

if (languageEl == "EN")
{
  ytxt <- "Primary extinctions to destroy half giant component"
  xtxt <- "Network"
  xtx2 <- "Species in giant component"
} else {
  ytxt <- "Extinciones para destruir mediap componente gigante"
  xtxt <- "Red"
  xtxt2 <- "Especies en la componente gigante"
}
comparativa <- function(results_by_r,basemethod = "krisk")
{
p <- ggplot(data = results_by_r) +
  geom_line(data = results_by_r, aes(x = index, y = comp_perf, fill = method, color = method))+
  geom_point(data = results_by_r,
             aes(x = index, y = comp_perf, fill = method, color = method), size = 3, alpha= 0.35)+
  scale_color_manual(values  = cols) +
  scale_x_discrete(name = xtxt,breaks=results_by_r[results_by_r$method == basemethod,]$index,
                   labels=unlist(strsplit(as.character(results_by_r[results_by_r$method == basemethod,]$Network),".csv")))+
  scale_y_continuous(name =ytxt,breaks=c(0,25,50),labels=c("50%","25%","0%"), limits=c(0,60))+
  theme_bw() + theme(axis.text.x  = element_text(angle=90, vjust=0, size=9),
                     axis.title.x = element_text(color="grey30", size=14),
                     axis.title.y = element_text(color="grey30", size=14),
                     axis.text.y = element_text(face="bold", color="grey30", size=12)
                     )
return(p)
}
results_ext <- read.csv("extinctions/ALL_EXTINCTIONS_halfGC.csv")
for (i in 1:nrow(results_ext))
  results_ext$best[i] <- min(results_ext$krisk[i],results_ext$degree[i],results_ext$kdegree[i],results_ext$eigen[i])

results_ext <- results_ext[order(-results_ext$krisk),]
results_by_row <- data.frame( Network = c(), method = c(), performance = c())
for (i in 1:nrow(results_ext))
{
  results_by_row <- rbind(results_by_row, data.frame( Network = results_ext$Network[i], method = "krisk", performance = 100*results_ext$krisk[i]/results_ext$giant_component[i]))
  results_by_row <- rbind(results_by_row, data.frame( Network = results_ext$Network[i], method = "degree", performance = 100*results_ext$degree[i]/results_ext$giant_component[i]))
  results_by_row <- rbind(results_by_row, data.frame( Network = results_ext$Network[i], method = "kdegree", performance = 100*results_ext$kdegree[i]/results_ext$giant_component[i]))
  results_by_row <- rbind(results_by_row, data.frame( Network = results_ext$Network[i], method = "eigen", performance = 100*results_ext$eigen[i]/results_ext$giant_component[i]))
  results_by_row <- rbind(results_by_row, data.frame( Network = results_ext$Network[i], method = "best", performance = 100*results_ext$best[i]/results_ext$giant_component[i]))
}

alpha_level = 0.5
p <- ggplot(data = results_ext) + geom_point(data = results_ext, aes(x = giant_component,y = krisk/giant_component), color = "red", alpha = alpha_level) +
     geom_point(data = results_ext, aes(x = giant_component,y = kdegree/giant_component), color = "blue", alpha = alpha_level) +
     scale_y_log10()

aux_ord_df <- data.frame(Network = results_ext$Network,
                         #value = (results_ext$krisk+results_ext$kdegree+results_ext$degree+results_ext$eigen)/results_ext$giant_component)
                         value = (results_ext$krisk)/results_ext$giant_component)

aux_ord_df <- aux_ord_df[order(aux_ord_df$value),]
aux_ord_df$index <- seq(1,nrow(aux_ord_df))

results_by_row$index <- 0
maxperf <- max(results_by_row$performance)
results_by_row$comp_perf <- maxperf - results_by_row$performance
for (i in 1:nrow(aux_ord_df))
  results_by_row[results_by_row$Network == aux_ord_df$Network[i],]$index <- aux_ord_df$index[i]

results_by_row <- results_by_row[order(results_by_row$index),]
cols <- c("kdegree" = "darkgreen", "eigen" = "darkgrey","degree" = "blue", "krisk" = "red", "best" = "forestgreen")

results_by_r <- results_by_row[is.element(results_by_row$method, c("krisk","kdegree")),]
r <- comparativa(results_by_r)

results_by_r <- results_by_row[is.element(results_by_row$method, c("krisk","degree")),]
s <- comparativa(results_by_r)

results_by_r <- results_by_row[is.element(results_by_row$method, c("krisk","eigen")),]
t <- comparativa(results_by_r)

results_by_r <- results_by_row[is.element(results_by_row$method, c("degree","kdegree")),]
u <- comparativa(results_by_r, basemethod = "degree")

results_by_r <- results_by_row[is.element(results_by_row$method, c("krisk","best")),]
v <- comparativa(results_by_r)

results_by_q <- results_by_row[is.element(results_by_row$method, c("krisk")),]
results_by_q$giant_component <- 0
for (i in 1:nrow(results_by_q))
  results_by_q$giant_component[i] <- results_ext[results_ext$Network == results_by_q$Network[i],]$giant_component

q <- ggplot(results_by_q, aes(x=giant_component, y = comp_perf, color = method)) + geom_point(alpha = 0.75, size=3) + scale_x_log10() + xlab(xtxt2)+
  scale_color_manual(values  = cols) +
    theme_bw()  +
   scale_y_continuous(name =ytxt,breaks=c(0,25,50),labels=c("50%","25%","0%"), limits=c(0,50))+
  theme(          axis.title.x = element_text(color="grey30", size=14),
                  axis.title.y = element_text(color="grey30", size=14),
                  axis.text.x = element_text(face="bold", color="grey30", size=14),
                  axis.text.y = element_text(face="bold", color="grey30", size=14))

mo <- lm(formula = results_by_q$performance ~ log(results_by_q$giant_component))
summary(mo)

ppi <- 300
png(paste0("graphs/krisk_kdegree_comparison_",languageEl,".png"), width=(12*ppi), height=12*ppi, res=ppi)
grid.arrange(s,q,nrow=2,ncol=1)
dev.off()


num_redes <- nrow(results_ext)

bkrisk <- sum(results_ext$krisk == results_ext$best)
print(sprintf("krisk is the best for %d networks (%.2f%%)",bkrisk,100*bkrisk/num_redes))

bkdegree <- sum(results_ext$kdegree == results_ext$best)
print(sprintf("kdegree is the best for %d networks (%.2f%%)",bkdegree,100*bkdegree/num_redes))

bdegree <- sum(results_ext$degree == results_ext$best)
print(sprintf("degree is the best for %d networks (%.2f%%)",bdegree,100*bdegree/num_redes))

beigen <- sum(results_ext$eigen == results_ext$best)
print(sprintf("eigen is the best for %d networks (%.2f%%)",beigen,100*beigen/num_redes))
