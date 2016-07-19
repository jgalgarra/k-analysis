# Creates the correlation plot of log(Kdegree) vs Modularity
# Output data at "graphs/"
#
# Requires:
# general analysis results "results/datos_analisis.RData"

library(grid)
library(gridExtra)
library(lmtest)
library(stargazer)

library(kcorebip)


  load("results/datos_analisis.RData")
  resultdf <- resultdf[!is.na(resultdf$MeanKdegree),]
  
  
  model <- lm(log(MeanKdegree) ~ Modularity, data = resultdf)
  fitted_model <- data.frame(
    MeanKdegree = log(resultdf$MeanKdegree),Modularity = resultdf$Modularity, 
    predict(model, interval = "confidence")
  )
  
 
  layer_line <- geom_line(
    mapping = aes(x = Modularity, y = exp(fit)),
    data = fitted_model,
    color = "darkorchid2"
  )
  
  layer_ribbon <- geom_ribbon(
    mapping = aes( ymin = exp(lwr), ymax = exp(upr)),
    data = fitted_model,
    alpha = 0.1
  )
  
  p <- ggplot(resultdf, aes(y=MeanKdegree,x=Modularity),legendTextFont=c(15, "bold.italic", "red")) +
        geom_text(aes(size=400,angle=0,colour = factor(Type), label = Number), 
                  fontface="bold", alpha = 0.6)+
        ylab("Average k-degree\n") + xlab("\nModularity")+
  scale_colour_manual(values=c("chocolate3", "cyan4")) +
  guides(col = guide_legend(override.aes = list(shape = 1, size = 0)),
         size = FALSE)+
   coord_trans(y="log") + ylim(c(0.7,9))+
  theme_bw() + 
  theme(panel.grid.major.y = element_line(size = 0.3, linetype = 3, color="grey80"),
        panel.grid.major.x = element_line(size = 0.3, linetype = 3, color="grey80"),
        panel.grid.minor = element_blank(),
        legend.title = element_blank(),
        legend.text = element_blank(),
        legend.key = element_blank(),
        legend.position = 'none',
        axis.title.x = element_text(color="grey30", size=14),
        axis.title.y = element_text(color="grey30", size=14),
        axis.text.x = element_text(face="bold", color="grey30", size=12),
        axis.text.y = element_text(face="bold", color="grey30", size=12))

  r <- ggplot(resultdf, aes(y=MeanKdegree,x=Modularity),legendTextFont=c(15, "bold.italic", "red"),
              addRegLine=TRUE, regLineColor="blue") +
    geom_point(aes(size=log(Species), colour = factor(Type)), alpha = 0.4) + 
    scale_fill_manual(values=c("chocolate3", "cyan4"),name="Type") +
    scale_colour_manual(values=c("chocolate3", "cyan4")) +
    scale_shape_identity()+
    xlab("\nModularity") + ylab("Average k-degree\n") +
#     guides(colour = guide_legend(override.aes = list(shape = 20, size = 8)),
#            size = FALSE)+
    #scale_colour_manual(values=c("chocolate3", "cyan4")) +
    coord_trans(y="log") + ylim(c(0.7,9))+
    #geom_smooth(method = "glm")+
    theme_bw() +  
    theme(panel.grid.major.y = element_line(size = 0.3, linetype = 3, color="grey60"),
          panel.grid.major.x = element_line(size = 0.3, linetype = 3, color="grey60"),
          panel.grid.minor = element_blank(),
          legend.title = element_blank(),
          legend.text = element_text(size=8),
          legend.key = element_blank(),
          legend.position = "none",
          legend.position=c(1,1),legend.justification=c(1,1),
          legend.background =  element_rect(fill='white', color='grey90'),
          axis.title.x = element_text(color="grey30", size=14),
          axis.title.y = element_text(color="grey30", size=14),
          axis.text.x = element_text(face="bold", color="grey30", size=12),
          axis.text.y = element_text(face="bold", color="grey30", size=12)
    )

ppi <- 300
png("graphs/corr_figs_Modularity_kdegree.png", width=(6*ppi), height=4*ppi, res=ppi)
grid.arrange(p,r+layer_line+layer_ribbon,ncol=2, nrow=1, widths=c(0.45,0.55))
print(r+layer_line+layer_ribbon)
dev.off()


# print("Shapiro test")
# print(shapiro.test(resid(model)))
# print("Durban Watson")
# print(dwtest(model, alternative="two.sided"))
#stargazer(model,style="qje")