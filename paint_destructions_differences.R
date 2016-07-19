library(ggplot2)

# This scripts reads the destrutcions results and generates different plots and comparisons between destructions algorithnms

destructions <- read.csv("results/destructions.csv", sep=";")
destructions$MoreDestructive <- "Same performance"
destructions$Diff <- 0.0025
for (i in 1:nrow(destructions)) {
  if (destructions$MusRank[i] - destructions$KshellKradiusKdegree[i] > 0){
    destructions$MoreDestructive[i] <- "K-shell superior "
    destructions$Diff[i] <- destructions$MusRank[i] - destructions$KshellKradiusKdegree[i]
  }
  if (destructions$MusRank[i] - destructions$KshellKradiusKdegree[i] < 0){
    destructions$MoreDestructive[i] <- "MusRank superior "
    destructions$Diff[i] <- destructions$MusRank[i] - destructions$KshellKradiusKdegree[i]
  }
  if (destructions$MusRank[i] - destructions$KshellKradiusKdegree[i] == 0)
    destructions$MoreDestructive[i] <- "Mismo rendimiento "
}
destructions$type <-  ifelse(grepl("PL_",destructions$Network), "Pollinators", "Dispersers")
p <- ggplot(data=destructions, aes(x=Network,y= Diff, fill=MoreDestructive)) +
     geom_bar(stat = "identity") +
     scale_fill_manual(values = c("K-shell superior " = "darkolivegreen3", "MusRank superior " = "coral", "Mismo rendimiento " = "cornsilk4")) +
     #facet_wrap(~ type ) +
     theme_bw() +
     ylab("Diferencia de ?reas") +
     xlab("") +
     ggtitle("Destrucci?n basada en K-shell vs. MusRank\n") +
     theme(
           panel.grid.major.y = element_line(size = 0.3, linetype = 3, color="grey60"),
           panel.grid.major.x = element_line(size = 0.3, linetype = 3, color="grey60"),
           panel.grid.minor = element_blank(),
           legend.title = element_blank(),
           legend.text = element_text(size=10),
           legend.position = "bottom",
           legend.position=c(1,1),legend.justification=c(1,1),
           legend.background =  element_rect(fill='white', color='white'),
           legend.key = element_rect(colour = 'white', fill="white" , size =3),
           axis.title.x = element_text(color="grey30", size=2),
           axis.title.y = element_text(color="grey30", size=11),
           axis.text.x = element_text(angle = 90,vjust = 0, size=7),
           axis.text.y = element_text(color="grey30", size=10))

ppi <- 300
png("ESTATICA_destructions_comparison.png", width=(12*ppi), height=5*ppi, res=ppi)

print(p)
dev.off()
