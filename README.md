# k-decomposition and analysis of mutualistic networks

Authors: Javier Garcia-Algarra/ Juan Manuel Pastor (UPM, Spain)


## Description

This repository contains code for the kcore decomposition, analysis and visualization of mutualistic networks.

### Prerequisites

R 3.2 or newer
Python 3.0 or newer
git bash installed

Intall kcorebip package with `devtools` package:


`install_github("jgalgarra/kcorebip")`

### Reproducibility

- Clone the repository with `git clone https://github.com/jgalgarra/k-analysis.git`
- Move to `k-analysis` directory and set it as R working directory (RStudio use is recommended)
- The `data` directory contains the 89 network interaction matrices. Original `. zip` files are stored in `weboflifedata` directory
- Run `testing-all.R`. The output file `results/datos_analisis.RData` stores the k-magnitudes in `.csv` format
- Rub `kdegree_calc_store_results.R` to get the `results/datos_analisis_condegs.RData` (results + network degrees and correlation degree kdegree)
- Run `network_k_parameters.R` to create individual k-magnitude files in `analysis_indiv_extended` directory
- Run `paint_core_distribution.R` and `paint_degree_distribution.R`to create k-manitudes histograms in `graphs`
- Run `paint_kmatrix_connections.R`. Plots are stored at graphs/matrix
- Run `gen_polar_reports` to create all polar plots in `plot_results/polar`
- Run `gen_ziggurat_report.R` to create all ziggurat plots in `plot_results/rotzig/`. WARNING: by default all calls are commented, uncomment those of the networks you want to plot.
- `fitting_plot_ModVSKdegree.R`and `fitting_plot_NODF_Kradius.R` create the correlation figs of k-magnitudes vs. classical magnitudes in graphs`
- `bipartite_graph`creates the simple biaprtite graph of the chosen network.
- Run `testing-and-processing-random.R` to perform the rewiring experiment. Output data at `results_rnd`. WARNING, this may consume several computing hours.
- Run `null_model_test.R` to perform the null model analysis. WARNING: The execution of this script for all networks may take several days !!!! Output data at `resultsnulls`. The script `paint_histo_nulls` generates the distribution plots of zKradius and zNODF of 
the null model of one network.
- `paint_rewiring_evolution.R` This script plots the evolution of zkradius vs zNODF for three chosen networks
in `results_rnd/figs/zscores_networks_evolution.png`
- `plot_histo_corr_RND.R` Paint plots of rewiring experiment. Output data at `results_rnd/figs`
- `plot_histo_corr_RND.R` generates the histogram plots of rewired networks, the assymetry plot and adds the correlation log(kradius) ~ NODF to the general table of results at `results_rnd/corrdf_data.csv`
- `calc_zscores_ALL.R` Computes the zscores of kradius and NODF for all the networks. Output data at `results_rnd/figs/`
- `create_z_scores_table.R`creates the zscores tables.  Output data at `resultsnulls`
- `destruction_first_algorithm.R`. Algorithm to find the number of primary extinctions of any guild to destroy half the giant component according to different indexes
- `paint_extinctions_results.R` compares results of the half giant component destruction and creates plots

Move to `python` directory. This code performs the network destruction removing only animal species

- Execute `extictions_compare.py`
- Edit the script. Replace `dunnemethod = False` with `dunnemethod = True`. Save it and rerun

Go bak to RStudio

- `paint_destructions_differences.R` reads the destructions results and generates different plots and comparisons among destruction indexes.
- `paint_juanmadunne_plots.R` Normalized area extinction plots for the second destruction algorithm. Output data at `graphs`
- `calc_best_dunne_algorithm.R` compares the outcome of the second extinction experiment. Results are stored at `extinctions`


