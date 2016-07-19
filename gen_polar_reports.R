# Auxiliar script to generate all the polar plots at plot_results/polar

library(kcorebip)

ficheros <- Sys.glob("data/M*.csv")

gentodos <- TRUE

if (gentodos) {
  for (j in ficheros)
  {
    red <- strsplit(j,"/")[[1]][2]
    red_name <- strsplit(red,".csv")[[1]][1]
    sguild_a = "pl"
    sguild_b = "pol"
    slabels <- c("Plant", "Pollinator")
    if (grepl("_SD_",red)){
      sguild_b = "disp"
      slabels <- c("Plant", "Disperser")
    }
    print(red)
    polar_graph(red,"data/",print_to_file=TRUE, lsize_title = 18, lsize_axis = 16, lsize_legend = 16, lsize_axis_title = 16,
                lsize_legend_title = 16, printable_labels = 0, print_title = FALSE)
  }
}
