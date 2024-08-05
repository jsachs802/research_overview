### PACKAGES 
library(tidyverse)
library(stats)
library(corpcor)
library(doMC)
library(purrr)


### LOAD DATA INPUTS 
source("~/Github/Fair-Diff-Conflicts/R-Code/HPC_SCRIPTS/CALIBRATION/MAIN_DATA_PAGE.R", local = TRUE) 
### Required data frames and created inputs  

#2. MOMENT FUNCTIONS
source("~/Github/Fair-Diff-Conflicts/R-Code/HPC_SCRIPTS/CALIBRATION/MOMENT_FUNCTIONS_E.R", local = TRUE)

#3. MOMENT EVALUATION FUNCTIONS 
source("~/Github/Fair-Diff-Conflicts/R-Code/HPC_SCRIPTS/CALIBRATION/MOMENT_EVAL_FUNCTIONS_E.R", local = TRUE)

#4. SIM_DFS
# load("~/Desktop/sim_dfs1.Rda")

### VARIABLES FOR TESTING
# sims = 100
# prob_grid = tibble(A_p = c(0.001), NA_p = c(0.001))


### INPUTS TO SET 
vill <- villages[1]
# could do village specific data

mo_eval_list <- master_moment_fn(vill = vill, 
                                 villages = villages, 
                                 empirical_moments = empirical_moments, 
                                 sim_dfs = sim_dfs, 
                                 nodes_df = nodes_df, 
                                 edgelist = edgelist, 
                                 sim_funcs = sim_funcs, 
                                 grid = prob_grid, 
                                 n_moments = n_moments)

save(mo_eval_list, file = "~/Github/Fair-Diff-Conflicts/R-Code/HPC_SCRIPTS/CALIBRATION/mo_eval_list.Rda")

