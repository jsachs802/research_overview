### PACKAGES 
library(tidyverse)
library(stats)
library(corpcor)
library(doMC)
library(purrr)

arg = commandArgs(trailingOnly = TRUE)
arg = as.integer(arg)


### LOAD DATA INPUTS 
source("~/Github/Fair-Diff-Conflicts/R-Code/HPC_SCRIPTS/CALIBRATION/MAIN_DATA_PAGE.R", local = TRUE) 
### Required data frames and created inputs  

### LOAD FUNCTIONS 
# 1. SIMULATOR FUNCTION 
source("~/Github/Fair-Diff-Conflicts/R-Code/HPC_SCRIPTS/CALIBRATION/SIMULATOR_FN_FINAL.R", local = TRUE)

## VARIABLES FOR TESTING
sims = 10
prob_grid = tibble(A_p = c(0.5), NA_p = c(0.5))

### INPUTS TO SET 
vill <- villages[arg]

# SET SEED
set_seed <- sample(0000000:9999999, 1) ## set seed function
# write.table(set_seed, "~/Github/Fair-Diff-Conflicts/R-Code/HPC_SCRIPTS/CALIBRATION/set_seed.txt", row.names = FALSE, col.names = TRUE) ## save as .txt

### SIMULATIONS 
set.seed(set_seed)
sim_dfs <- foreach(A_p = prob_grid$A_p, NA_p = prob_grid$NA_p) %do%{# iterate over parameter combinations
  
  foreach(icount(sims)) %do%{ # number of simulations for each parameter combination 
    
    try(simulator_fn(vill = vill, t = t, vill_logit = vill_logit, nodes_df = nodes_df, edgelist = edgelist, A_p = A_p, NA_p = NA_p))
  }
  
}



save(sim_dfs, file = "~/Github/Fair-Diff-Conflicts/R-Code/HPC_SCRIPTS/CALIBRATION/sim_dfs.Rda")

