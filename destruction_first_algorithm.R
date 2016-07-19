# Algorithm to find the number of primary extinctions of any guild to destroy half the giant component according to different indexes

rm(list=ls())

library(kcorebip)

directorystr <- "data/"

analyze_network_fast <- function(namenetwork, directory="", guild_a = "pl", guild_b = "pol")
{
  nread <- read_network(namenetwork, directory = directory, guild_astr = guild_a, guild_bstr = guild_b)
  g <- as.undirected(nread$g)
  g_cores <- graph.coreness(g)
  m <- nread$matrix
  lcores <- unique(g_cores)
  max_core <- max(lcores)

  calc_values <- list("graph" = g, "matrix" = as.matrix(m), "max_core" = max_core)
  return(calc_values)
}


giant.component <- function(graph) {
  cl <- clusters(graph)
  induced.subgraph(graph, which(cl$membership == which.max(cl$csize)))}

guild_and_number <- function(slabel)
{
  if (length(grep("pl",slabel)) == 1)
    etq <- "pl"
  else if (length(grep("pol",slabel)) == 1)
    etq <- "pol"
  else
    etq <- "disp"
  num <- strsplit(slabel,etq)[[1]][2]
  calc_vals <- list("guild" = etq, "num" = num)
  return(calc_vals)
  return(etq,num)
}

reorder_df <- function(df_network, bykey = "kdegree")
{
  if (bykey == "kdegree")
    df_network <- df_network[order(-df_network$kdegree),]
  if (bykey == "krisk")
    df_network <- df_network[order(-df_network$krisk,-df_network$kcorenum,-df_network$kdegree),]
  if (bykey == "degree")
    df_network <- df_network[order(-df_network$degree),]
  if (bykey == "kshellkdegree")
    df_network <- df_network[order(-df_network$kcorenum,-df_network$degree),]
  if (bykey == "kshellkradiuskdegree")
    df_network <- df_network[order(-df_network$kcorenum,df_network$kradius,-df_network$degree),]
  if (bykey == "kshell")
    df_network <- df_network[order(-df_network$kcorenum),]
  if (bykey == "eigenc")
    df_network <- df_network[order(-df_network$eigenc),]
  if (bykey == "kradius"){
    if (sum(df_network$kradius == Inf) > 0)
      df_network[df_network$kradius == Inf,]$kradius <- 1000000
    df_network <- df_network[order(df_network$kradius),]
  }
  return(df_network)

}

print_params <- function(g, gcsizse, verbose = TRUE)
{
  num_species_a <- sum(rowSums(result_analysis$matrix) > 0)
  num_species_b <- sum(colSums(result_analysis$matrix) > 0)

  if (verbose){
    print(paste("Species in giant component network-analysis:",gcsizse))
  }
}

halfgc_extinctions <- function(def, extkey = "degree", verbose = TRUE)
{
  gc<- giant.component(result_analysis$graph)
  size_giant_c <- length(V(gc))
  gcnames <- as.character(V(gc)$name)
  unlink("datatemp/*wipe*")
  if (sum(!is.element(def$species,gcnames)) > 0)
    def[!is.element(def$species,gcnames),]$giant_component <- FALSE
  def <- reorder_df(def, bykey = extkey)
  for ( i in 1:nrow(def))
  {
    if (def$giant_component[i]){
    idspecies <- guild_and_number(as.character(def$species[i]))
    if (verbose)
      print(paste(idspecies[["guild"]],idspecies[["num"]],"removed"))
    if (idspecies[["guild"]] == "pl")
      result_analysis$matrix[,as.integer(idspecies[["num"]])] = 0
    else # (idspecies[["guild"]] == "pol")
      result_analysis$matrix[as.integer(idspecies[["num"]]),] = 0
    } else {
      if (i == nrow(def)){
        print(sprintf("Network destroyed, key: %s. %d primary extinctions %.02f%% of initial network size",extkey,primary_extinctions,100*primary_extinctions/ini_size_giant_c))
        return(primary_extinctions)
      break()
      } else {
        i <- i+1
        print(paste("voy por la fila ",i))
        next
      }
    }

    primary_extinctions <- primary_extinctions + 1
    write.csv(result_analysis$matrix,paste0("datatemp/",red_name,"wipetemp_minus_",i,".csv"))
    if (kcoremax > 0) {
      if (paint_zigs)
        result_analysis <- analyze_network(paste0(red_name,"wipetemp_minus_",i,".csv"), directory = "datatemp/", guild_a = sguild_a, guild_b = sguild_b, plot_graphs = FALSE)
      else
        result_analysis <- analyze_network(paste0(red_name,"wipetemp_minus_",i,".csv"), directory = "datatemp/", guild_a = sguild_a, guild_b = sguild_b, plot_graphs = FALSE, only_NODF = TRUE)
      kcoremax <- result_analysis$max_core
      if (verbose)
        print(paste("Kcoremax",kcoremax))
      gc<- giant.component(result_analysis$graph)
      size_giant_c <- length(V(gc))
      gcnames <- as.character(V(gc)$name)
      if (sum(!is.element(def$species,gcnames)) > 0)
        def[!is.element(def$species,gcnames),]$giant_component <- FALSE
      print_params(result_analysis$graph, size_giant_c, verbose = verbose)
      if (size_giant_c <= 0.5*ini_size_giant_c){
        print(sprintf("Half Giant component destroyed, key: %s. %d primary extinctions %.02f%% of initial network size",extkey,primary_extinctions,100*primary_extinctions/ini_size_giant_c))
        if (paint_zigs){
          ziggurat_graph("datatemp/",paste0(red_name,"wipetemp_minus_",i,".csv"),color_link = "slategray3", alpha_link = 0.7,
                         lsize_kcoremax = 6,lsize_zig = 5,lsize_kcore1 = 5,kcore1tail_disttocore = c(1.3,1),
                         lsize_legend = 7, lsize_core_box = 6,corebox_border_size=1, displace_legend = c(-0.1,0),
                         plotsdir="peli/",print_to_file = paint_to_file, paint_outsiders = poutsiders)
          Sys.sleep(1)
        }
        return(primary_extinctions)
        break()
      }
      if (paint_zigs){
        ziggurat_graph("datatemp/",paste0(red_name,"wipetemp_minus_",i,".csv"),color_link = "slategray3", alpha_link = 0.7,
                       lsize_kcoremax = 6,lsize_zig = 5,lsize_kcore1 = 5,kcore1tail_disttocore = c(1.3,1),
                       lsize_legend = 7, lsize_core_box = 6,corebox_border_size=1, displace_legend = c(-0.1,0),
                       plotsdir="peli/",print_to_file = paint_to_file, paint_outsiders = poutsiders)
        Sys.sleep(1)
      }
    }
  }
}

alldir <- TRUE
#alldir <- FALSE
poutsiders <- FALSE

if (alldir){
  ficheros <- Sys.glob("data/M*.csv")
} else
  ficheros <- c("data/M_SD_001.csv")
dir.create("extinctions", showWarnings = FALSE)
for (fred in ficheros)
{
  paint_zigs <- FALSE
  paint_to_file <- FALSE
#   paint_zigs <- TRUE
#   paint_to_file <- TRUE
  verb <- TRUE
  primary_extinctions <- 0
  red <- strsplit(fred,"data/")[[1]][2]
  red_name <- strsplit(red,".csv")[[1]][1]
  sguild_a = "pl"
  sguild_b = "pol"
  slabels <- c("Plant", "Pollinator")
  if (grepl("_SD_",red)){
    sguild_b = "disp"
    slabels <- c("Plant", "Disperser")
  }
  print(red)
  result_analysis <- analyze_network(red, directory = "data/", guild_a = sguild_a,
                                     guild_b = sguild_b, plot_graphs = FALSE, only_NODF = TRUE)
  numlinks <- result_analysis$links
  kcorenums_orig <- result_analysis$g_cores
  kcoredegree_orig <- V(result_analysis$graph)$kdegree
  kcorerisk_orig <- V(result_analysis$graph)$krisk
  red_degree <- igraph::degree(result_analysis$graph)
  eigc <- igraph::evcent(result_analysis$graph, scale = FALSE)$vector
  df_index_extinction <- data.frame(species = c(), giant_component = c(), kcorenum = c(), kdegree = c(), degree = c(),
                                    kradius = c(), krisk = c(), eigenc =c())
  for (j in 1:length(kcorenums_orig))
  {
    df_index_extinction <- rbind(df_index_extinction, data.frame(species = V(result_analysis$graph)$name[j], giant_component = TRUE,
                                                                 kcorenum = unlist(kcorenums_orig[j])[[1]], kdegree = kcoredegree_orig[j],
                                                                 degree = red_degree[j], kradius = V(result_analysis$graph)$kradius[j],
                                                                 krisk = kcorerisk_orig[j], eigenc = eigc[j]))
  }
  kcoremax <- max(result_analysis$g_cores)
  #print(paste("Kcoremax",kcoremax))
  gc <- giant.component(result_analysis$graph)
  size_giant_c <- length(V(gc))
  ini_size_giant_c <- size_giant_c
  print_params(result_analysis$graph,size_giant_c,verbose = verb)

  if (paint_zigs){
    ziggurat_graph("data/",red,plotsdir="peli/",color_link = "slategray3", alpha_link = 0.7,
                   lsize_kcoremax = 6,lsize_zig = 5,lsize_kcore1 = 5,kcore1tail_disttocore = c(1.3,1),
                   lsize_legend = 7, lsize_core_box = 6,corebox_border_size=1,displace_legend = c(-0.1,0),
                   print_to_file = paint_to_file, paint_outsiders = poutsiders)
    Sys.sleep(3)
  }

#halfgc_extinctions(df_index_extinction, extkey = "kshellkradiuskdegree", verbose = FALSE)
#halfgc_extinctions(df_index_extinction, extkey = "kshellkdegree", verbose = FALSE)
#halfgc_extinctions(df_index_extinction, extkey = "kradius", verbose = FALSE)

pr_krisk <- halfgc_extinctions(df_index_extinction, extkey = "krisk", verbose = verb)
pr_degree <- halfgc_extinctions(df_index_extinction, extkey = "degree", verbose = verb)
pr_eigen <- halfgc_extinctions(df_index_extinction, extkey = "eigenc", verbose = verb)
pr_kdegree <- halfgc_extinctions(df_index_extinction, extkey = "kdegree", verbose = verb)
pr_best = min(pr_krisk,pr_degree,pr_eigen,pr_kdegree)

results_uno = data.frame(Network = red, giant_component = size_giant_c, krisk = pr_krisk,
                       degree = pr_degree, kdegree = pr_kdegree, eigenc = pr_eigen, best = pr_best)
if (!exists("results_ext"))
  results_ext <- results_uno
else
  results_ext <- rbind(results_ext, results_uno)

# results_ext <- read.csv(paste0("extinctions/",red_name,".csv"))
# results_ext$krisk <- pr_krisk


if (alldir)
  write.csv(results_ext,file=paste0("extinctions/ALL_EXTINCTIONS_halfGC.csv"),row.names=FALSE)
}
