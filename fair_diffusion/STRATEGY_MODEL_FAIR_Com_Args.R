library(tidyverse)
library(stats)
library(corpcor)
library(doMC)
library(igraph)
library(data.table)

# args = commandArgs(trailingOnly = TRUE)
# args = as.integer(arg)

### LOAD DATA 
source("~/Github/Fair-Diff-Conflicts/R-Code/HPC_SCRIPTS/STRATEGIES/MAIN_FUNCTIONS/MAIN_DATA_PAGE.R", local = TRUE)  ## CHANGE DIRECTORY

## FOR TESTING 
args <- c(11, "actual")

## VILLAGE SPECIFIC ITEMS TO LOAD 
vill = villages[as.integer(args[1])]



if(args[2] == "actual"){
  
  seed_num <- sum(nodes_df$attend[nodes_df$village == vill], na.rm = TRUE) ## actual num of seeds 
  
}else if(args[2] == "five"){
  
  seed_num <- round(length(nodes_df$i[nodes_df$village == villages[1]])*0.05) ## 5 % seed pop
  
}else if(args[2] == "ten"){
  
  seed_num <- round(length(nodes_df$i[nodes_df$village == villages[1]])*0.1) ## 10 % seed pop
  
}else if(args[2] == "fifteen"){
  
  seed_num <- round(length(nodes_df$i[nodes_df$village == villages[1]])*0.15) ## 15 % seed pop
  
}else if(args[2] == "twenty"){
  
  seed_num <- round(length(nodes_df$i[nodes_df$village == villages[1]])*0.2) ## 20 % seed pop
  
}else if(args[2] == "twentyfive"){
  
  seed_num <- round(length(nodes_df$i[nodes_df$village == villages[1]])*0.25) ## 25 % seed pop
  
}


vill_file = which(villages == vill) # village number in files
load(paste0("~/Desktop/Cluster Moment Evals/mo_eval_list_e_", args[1], ".Rda")) ## mo_eval_list
A_p <- mo_eval_list$A_p ## critical values A_p value
NA_p <- mo_eval_list$NA_p ## critical values NA_p value

## VILL DF
vill_df <- nodes_df[nodes_df$village == vill, ]


### STRATEGY TYPES 
fair_seeding_type_list <- c("deg_all_avg", 
                            "deg_seed_avg", 
                            "eig_all_avg", 
                            "eig_seed_avg", 
                            "complex_2_all_avg", 
                            "complex_2_seed_avg", 
                            "complex_4_all_avg", 
                            "complex_4_seed_avg", 
                            "complex_6_all_avg", 
                            "complex_6_seed_avg", 
                            "perco_all_avg", 
                            "perco_seed_avg",
                            "coreness_all_avg", 
                            "coreness_seed_avg",
                            "closeness_all_avg",
                            "closeness_seed_avg",
                            "between_all_avg",
                            "between_seed_avg",
                            "inf_max01_all_avg",
                            "inf_max01_seed_avg",
                            "inf_max10_all_avg",
                            "inf_max10_seed_avg",
                            "inf_max25_all_avg",
                            "inf_max25_seed_avg",
                            "inf_max50_all_avg",
                            "inf_max50_seed_avg",
                            "wt_deg_all_avg",
                            "wt_deg_seed_avg",
                            "wt_eig_all_avg",
                            "wt_eig_seed_avg",
                            "wt_complex_2_all_avg",
                            "wt_complex_2_seed_avg",
                            "wt_complex_4_all_avg",
                            "wt_complex_4_seed_avg",
                            "wt_complex_6_all_avg",
                            "wt_complex_6_seed_avg",
                            "wt_perco_all_avg",
                            "wt_perco_seed_avg",
                            "wt_coreness_all_avg",
                            "wt_coreness_seed_avg",
                            "wt_closeness_all_avg",
                            "wt_closeness_seed_avg",
                            "wt_between_all_avg",
                            "wt_between_seed_avg",
                            "wt_inf_max01_all_avg",
                            "wt_inf_max01_seed_avg",
                            "wt_inf_max10_all_avg",
                            "wt_inf_max10_seed_avg",
                            "wt_inf_max25_all_avg",
                            "wt_inf_max25_seed_avg",
                            "wt_inf_max50_all_avg",
                            "wt_inf_max50_seed_avg",
                            "like_all_avg",
                            "like_seed_avg",
                            "deg_all_total",
                            "deg_seed_total", 
                            "eig_all_total", 
                            "eig_seed_total", 
                            "complex_2_all_total",
                            "complex_2_seed_total", 
                            "complex_4_all_total",
                            "complex_4_seed_total", 
                            "complex_6_all_total", 
                            "complex_6_seed_total", 
                            "perco_all_total", 
                            "perco_seed_total", 
                            "coreness_all_total", 
                            "coreness_seed_total", 
                            "closeness_all_total", 
                            "closeness_seed_total", 
                            "between_all_total", 
                            "between_seed_total", 
                            "inf_max01_all_total", 
                            "inf_max01_seed_total", 
                            "inf_max10_all_total", 
                            "inf_max10_seed_total", 
                            "inf_max25_all_total", 
                            "inf_max25_seed_total",
                            "inf_max50_all_total", 
                            "inf_max50_seed_total",
                            "wt_deg_all_total", 
                            "wt_deg_seed_total",
                            "wt_eig_all_total", 
                            "wt_eig_seed_total", 
                            "wt_complex_2_all_total", 
                            "wt_complex_2_seed_total", 
                            "wt_complex_4_all_total", 
                            "wt_complex_4_seed_total", 
                            "wt_complex_6_all_total", 
                            "wt_complex_6_seed_total", 
                            "wt_perco_all_total", 
                            "wt_perco_seed_total", 
                            "wt_coreness_all_total", 
                            "wt_coreness_seed_total", 
                            "wt_closeness_all_total", 
                            "wt_closeness_seed_total", 
                            "wt_between_all_total", 
                            "wt_between_seed_total", 
                            "wt_inf_max01_all_total", 
                            "wt_inf_max01_seed_total", 
                            "wt_inf_max10_all_total", 
                            "wt_inf_max10_seed_total", 
                            "wt_inf_max25_all_total", 
                            "wt_inf_max25_seed_total", 
                            "wt_inf_max50_all_total", 
                            "wt_inf_max50_seed_total", 
                            "like_all_total", 
                            "like_seed_total")

fair_len <- length(fair_seeding_type_list)

### ALLOCATION TABLE (list names are strategy types)
allo_table <- vector(mode = "list", length = length(fair_seeding_type_list))

## SEED LIST 
fair_seed_list <- vector(mode = "list", length = length(fair_seeding_type_list))


#### LOAD OUTSIDE FUNCTIONS 

### LOAD SEEDING FUNCTIONS 
source("~/Github/Fair-Diff-Conflicts/R-Code/HPC_SCRIPTS/STRATEGIES/MAIN_FUNCTIONS/SEEDING_FN_FAIR_v.3.R", local = TRUE) 

### LOAD SIMULATOR FUNCTIONS
source("~/Github/Fair-Diff-Conflicts/R-Code/HPC_SCRIPTS/STRATEGIES/MAIN_FUNCTIONS/STRAT_SIMULATOR.R", local = TRUE) 

### LOAD FAIRNESS EVALUATION FUNCTIONS
source("~/Github/Fair-Diff-Conflicts/R-Code/HPC_SCRIPTS/STRATEGIES/MAIN_FUNCTIONS/FAIR_OUTCOMES_v.3.R", local = TRUE) 


### BUILD ALLO TABLE ###
## ALLO TABLE FOR FAIR SEEDINGS 
for(i in 1:fair_len){
  
  allo_table[[i]] <- tibble(strategy = rep(fair_seeding_type_list[i], (seed_num-1)), row = 1:(seed_num-1), male = 1:(seed_num-1), female = (seed_num - 1):1) ## allocation table
  
  ## SEEDING_FUNCTION 
  fair_seed_list[[i]] <- fair_seeds_fn(seeds_n = seed_num, male = allo_table[[i]]$male, female = allo_table[[i]]$female, vill_df = vill_df, type = fair_seeding_type_list[i])
  # save(seed_list, file = paste0("seed_list_", seeding_type_list[i], ".Rda"))
  
  # SEED FAIRNESS EVALUATION - object: allo_table
  # OUTCOMES
  allo_table[[i]]$m_seed_out <- NA
  allo_table[[i]]$f_seed_out <- NA
  allo_table[[i]]$m_seed_out <- fair_outcome_fn(seeds_n = seed_num, table = allo_table[[i]], vill_df = vill_df, fair_seed_list = fair_seed_list, type = fair_seeding_type_list[i])[[1]]
  allo_table[[i]]$f_seed_out <- fair_outcome_fn(seeds_n = seed_num, table = allo_table[[i]], vill_df = vill_df, fair_seed_list = fair_seed_list, type = fair_seeding_type_list[i])[[2]]
  
  # STAT RATE
  allo_table[[i]] <-  stat_rate_fn(allo_table[[i]], type = "seed")
  
}



## SET SEED
set_seed <- sample(0000000:9999999, 1) ## set seed function
write.table(set_seed, file = paste0("~/Github/Fair-Diff-Conflicts/R-Code/HPC_SCRIPTS/STRATEGIES/VILLAGE_", args[1], "/set_seed_", args[2], ".txt"), row.names = FALSE, col.names = TRUE) ## save as .txt
set.seed(set_seed)


### Start debugging here### 

## FAIR SIMULATIONS
fair_sim_dfs = foreach(i = 1:length(fair_seed_list)) %do% {
  foreach(j = 1:length(fair_seed_list[[i]])) %do% {
    foreach(icount(sims)) %do%{ # number of simulations for each parameter combination
      try(simulator_fn(seed_list = fair_seed_list[[i]][[j]], vill = vill, t = t, vill_logit = vill_logit, nodes_df = nodes_df, edgelist = edgelist, A_p = A_p, NA_p = NA_p))
    }
  }
}


#### MIGHT NEED A FUNCTION THAT REMOVES FAILED SIMS HERE 
### FUNCTION FOR HANDLING FAILED SIMULATIONS
# remove_error_fn <- function(sim_dfs){
#   for(i in 1:length(sim_dfs)){
#     for(y in 1:length(sim_dfs[[i]])){
#       for(k in 1:length(sim_dfs[[y]])){
#         if(class(sim_dfs[[i]][[y]][[k]][[1]]) == "try-error" ){
#           sim_dfs[[i]][[y]][[k]] <- NA
#         }
#         sim_dfs[[i]][[y]] <- sim_dfs[[i]][[y]][!is.na(sim_dfs[[i]][[y]])]
#       }
#     }
#   }
#   return(sim_dfs)
# }
# 
# fair_sim_dfs <- remove_error_fn(sim_dfs = fair_sim_dfs)



### SEPARATING DATAFRAME
fair_dfs = foreach(i = 1:fair_len) %do%{
  foreach(j = 1:(seed_num - 1)) %do% {
    foreach(k = 1:length(fair_sim_dfs[[i]][[j]])) %do% {
      fair_sim_dfs[[i]][[j]][[k]][[1]]
    }
  }
}


### OUTCOMES
allo_table = foreach(i = 1:fair_len) %do% {
  reach_fn(all_dfs = fair_dfs[[i]], allo_table = allo_table[[i]], sims = sims)
}

### STAT RATE 
allo_table = foreach(i = 1:fair_len) %do% {
  stat_rate_fn(allo_table = allo_table[[i]], type = "reach")
}

names(allo_table) = fair_seeding_type_list


### SAVE ALLO TABLE 
save(allo_table, file = paste0("~/Github/Fair-Diff-Conflicts/R-Code/HPC_SCRIPTS/STRATEGIES/VILLAGE_", args[1], "/fair_allo_table_", args[2], ".Rda")) ### SAVE TO CORRECT LOCATION


### SEPARATING CUM RATE OBJECT 
cum_rates = foreach(i = 1:fair_len) %do%{
  foreach(j = 1:(seed_num-1)) %do% {
    foreach(k = 1:sims) %do% {
      fair_sim_dfs[[i]][[j]][[k]][[2]]
    }
  }
}


### AVERAGE CUM HEARD 
avg_cum_heard = foreach(i = 1:fair_len) %do% { ## MUST LOAD FUNCTION 
  foreach(j = 1:(seed_num-1)) %do% {
    fair_avg_cr_fn(cum_rates = cum_rates[[i]][[j]])
  }
}
names(avg_cum_heard) = fair_seeding_type_list


save(avg_cum_heard, file = paste0("~/Github/Fair-Diff-Conflicts/R-Code/HPC_SCRIPTS/STRATEGIES/VILLAGE_", args[1], "/fair_allo_table_", args[2], ".Rda")) ### SAVE TO CORRECT LOCATION

