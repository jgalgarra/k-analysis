# Creates the correlation plot of log(Kradius) vs NODF
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
  resultdf <- resultdf[!is.na(resultdf$MeanKradius),]
  
  
  model <- lm(log(MeanKradius) ~ NODF, data = resultdf)
  fitted_model <- data.frame(
    NODF = resultdf$NODF, MeanKradius = log(resultdf$MeanKradius),
    predict(model, interval = "confidence")
  )
  
 
  layer_line <- geom_line(
    mapping = aes(x = NODF, y = exp(fit)),
    data = fitted_model,
    color = "darkorchid2"
  )
  
  layer_ribbon <- geom_ribbon(
    mapping = aes( ymin = exp(lwr), ymax = exp(upr)),
    data = fitted_model,
    alpha = 0.1
  )
  
  p <- ggplot(resultdf, aes(y=MeanKradius,x=NODF),legendTextFont=c(15, "bold.italic", "red")) +
        geom_text(aes(colour = factor(Type), label = Number), 
                  fontface="bold", alpha = 0.6, size = 3)+
    ylab(expression(paste(bar(k)[radius],"\n"))) + xlab("\nNODF")+
    coord_trans(y="log") +
  scale_colour_manual(values=c("chocolate3", "cyan4")) +
  guides(col = guide_legend(override.aes = list(shape = 1, size = 0)),
         size = FALSE)+
  theme_bw() + 
  theme(panel.grid.major.y = element_line(size = 0.3, linetype = 3, color="grey80"),
        panel.grid.major.x = element_line(size = 0.3, linetype = 3, color="grey80"),
        panel.grid.minor = element_blank(),
        legend.title = element_blank(),
        legend.text = element_text(size=10),
        legend.key = element_rect(aes(fill=resultdf$Type)),
        legend.position=c(1,1),legend.justification=c(1,1),
        legend.background =  element_rect(fill='white', color='grey90'),
        axis.title.x = element_text(color="grey30", size=14),
        axis.title.y = element_text(color="grey30", size=14),
        axis.text.x = element_text(face="bold", color="grey30", size=12),
        axis.text.y = element_text(face="bold", color="grey30", size=12))
 
  disp_texto <- c("M_PL_002.csv","M_PL_003.csv","M_PL_006.csv","M_PL_012.csv",
                  "M_PL_018.csv","M_PL_020.csv","M_PL_022.csv",
                  "M_PL_024.csv","M_PL_030.csv","M_PL_032.csv","M_PL_042.csv",
                  "M_PL_044.csv","M_PL_046.csv","M_PL_053.csv","M_PL_059.csv",
                  "M_SD_003.csv","M_SD_007.csv","M_SD_008.csv","M_SD_010.csv",
                  "M_SD_011.csv","M_SD_014.csv","M_SD_017.csv","M_SD_019.csv",
                  "M_SD_020.csv","M_SD_021.csv","M_SD_025.csv","M_SD_023.csv",
                  "M_SD_026.csv","M_SD_028.csv","M_SD_029.csv","M_SD_030.csv") 
  resultdf$coltext = "transparent"
  resultdf[resultdf$Type == "Pollinator",]$coltext  = "cyan4"
  resultdf[resultdf$Type == "Disperser",]$coltext  = "chocolate3"
  resultdf[!is.element(resultdf$Network,disp_texto),]$coltext = "transparent"
    
  

  r <- ggplot(resultdf, aes(y=MeanKradius,x=NODF),legendTextFont=c(15, "bold.italic", "red"),
              addRegLine=TRUE, regLineColor="blue") +
    geom_text(aes(label = Number), colour = resultdf$coltext, 
              fontface="bold", size = 3, vjust = -1)+
    geom_point(aes(size=log(Species), colour = factor(Type)), alpha = 0.4) + 
    scale_fill_manual(values=c("chocolate3", "cyan4"),name="Type") +
    scale_colour_manual(values=c("chocolate3", "cyan4")) +
    scale_shape_identity()+
    xlab("\nNODF") + ylab(expression(paste(bar(k)[radius],"\n"))) +
    guides(colour = guide_legend(override.aes = list(shape = 20, size = 8)),
           size = FALSE)+
    #scale_colour_manual(values=c("chocolate3", "cyan4")) +
    coord_trans(y="log") + ylim(c(1,4)) + xlim(0,100) +
    #geom_smooth(method = "glm")+
    theme_bw() +  
    theme(panel.grid.major.y = element_line(size = 0.3, linetype = 3, color="grey60"),
          panel.grid.major.x = element_line(size = 0.3, linetype = 3, color="grey60"),
          panel.grid.minor = element_blank(),
          legend.title = element_blank(),
          legend.text = element_text(size=8),
          legend.key = element_blank(),
          #legend.position = "right",
          legend.position=c(1,1),legend.justification=c(1,1),
          legend.background =  element_rect(fill='white', color='grey90'),
          axis.title.x = element_text(color="grey30", size=14),
          axis.title.y = element_text(color="grey30", size=14),
          axis.text.x = element_text(face="bold", color="grey30", size=12),
          axis.text.y = element_text(face="bold", color="grey30", size=12)
    )
  
  models <- lm(log(MeanKradius) ~ SpecRadius, data = resultdf)
  fitted_models <- data.frame(
    SpecRadius = resultdf$SpecRadius, MeanKradius = log(resultdf$MeanKradius),
    predict(models, interval = "confidence")
  )
  
  
  layer_lines <- geom_line(
    mapping = aes(x = SpecRadius, y = exp(fit)),
    data = fitted_models,
    color = "darkorchid2"
  )
  
  layer_ribbons <- geom_ribbon(
    mapping = aes( ymin = exp(lwr), ymax = exp(upr)),
    data = fitted_models,
    alpha = 0.1
  )

  resultdf[resultdf$Type == "Pollinator",]$coltext  = "cyan4"
  resultdf[resultdf$Type == "Disperser",]$coltext  = "chocolate3"
  s <- ggplot(resultdf, aes(y=MeanKradius,x=SpecRadius),legendTextFont=c(15, "bold.italic", "red"),
              addRegLine=TRUE, regLineColor="blue") +
    geom_point(aes(size=log(Species), color=factor(resultdf$Type)), alpha = 0.4) + 
    geom_text(aes(label = Number), color=resultdf$coltext, fontface="bold", size = 2.5)+
    scale_fill_manual(values=c("chocolate3", "cyan4"),name="Type") +
    scale_colour_manual(values=c("chocolate3", "cyan4")) +
    scale_shape_identity()+
    xlab("\nSpecRadius") + ylab(expression(paste(bar(k)[radius],"\n"))) +
    guides(colour = guide_legend(override.aes = list(shape = 20, size = 8)),
           size = FALSE)+
    coord_trans(y="log") + #ylim(c(1,4)) + xlim(0,100) +
    #geom_smooth(method = "glm")+
    ylim(c(1.1*min(resultdf$MeanKradius),1.1*max(resultdf$MeanKradius))) +
    theme_bw() +  
    theme(panel.grid.major.y = element_line(size = 0.3, linetype = 3, color="grey60"),
          panel.grid.major.x = element_line(size = 0.3, linetype = 3, color="grey60"),
          panel.grid.minor = element_blank(),
          legend.title = element_blank(),
          legend.text = element_text(size=8),
          legend.key = element_blank(),
          #legend.position = "right",
          legend.position=c(1,1),legend.justification=c(1,1),
          legend.background =  element_rect(fill='white', color='grey90'),
          axis.title.x = element_text(color="grey30", size=14),
          axis.title.y = element_text(color="grey30", size=14),
          axis.text.x = element_text(face="bold", color="grey30", size=12),
          axis.text.y = element_text(face="bold", color="grey30", size=12)
    )

ppi <- 300
png("graphs/corr_figs_NODF.png", width=(6*ppi), height=4*ppi, res=ppi)
print(r+layer_line+layer_ribbon)
dev.off()

ppi <- 300
png("graphs/corr_figs_NODF_numbers.png", width=(10*ppi), height=6*ppi, res=ppi)
print(p)
dev.off()

ppi <- 300
png("graphs/corr_figs_SpecRadius.png", width=(6*ppi), height=4*ppi, res=ppi)
print(s)
dev.off()

print("Shapiro test")
print(shapiro.test(resid(model)))
print("Durban Watson")
print(dwtest(model, alternative="two.sided"))
#stargazer(model,style="qje")