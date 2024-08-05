library(tidyverse)
library(stats)
library(corpcor)
library(doMC)
library(igraph)
library(data.table)

### LOAD DATA 
source("~/Github/Fair-Diff-Conflicts/R-Code/HPC_SCRIPTS/STRATEGIES/MAIN_FUNCTIONS/MAIN_DATA_PAGE.R", local = TRUE)  ## CHANGE DIRECTORY

## VILLAGE SPECIFIC ITEMS TO LOAD 
vill = villages[9]
seed_num <- sum(nodes_df$attend[nodes_df$village == vill], na.rm = TRUE) ## of seeds 
vill_file = which(villages == vill) # village number in files
load("~/Desktop/Cluster Moment Evals/mo_eval_list_e_10.Rda") ## mo_eval_list
A_p <- mo_eval_list$A_p ## critical values A_p value
NA_p <- mo_eval_list$NA_p ## critical values NA_p value

## VILL DF
vill_df <- nodes_df[nodes_df$village == vill, ]

### STRATEGY TYPES 
max_seeding_type_list <- c("actual",
                           "max_deg",
                           "max_like",
                           "max_wt_deg",
                           "max_eig",
                           "max_wt_eig",
                           "max_complex_2",
                           "max_wt_complex_2",
                           "max_complex_4",
                           "max_wt_complex_4",
                           "max_complex_6",
                           "max_wt_complex_6",
                           "max_perco",
                           "max_wt_perco",
                           "max_coreness",
                           "max_wt_coreness",
                           "max_closeness",
                           "max_wt_closeness",
                           "max_between",
                           "max_wt_between", 
                           "max_inf_max01", 
                           "max_wt_inf_max01", 
                           "max_inf_max10", 
                           "max_wt_inf_max10", 
                           "max_inf_max25", 
                           "max_wt_inf_max25", 
                           "max_inf_max50", 
                           "max_wt_inf_max50")



### FAIRNESS TYPES 
fairness_types <- c("nn", "out_pop_avg", "out_seed_avg", "out_pop_total", "out_seed_total")

### ALLOCATION TABLE (list names are strategy types)
max_allo_table <- vector(mode = "list", length = length(max_seeding_type_list))
names(max_allo_table) <- max_seeding_type_list

### SEED LIST 
max_seed_list <- vector(mode = "list", length = length(max_seeding_type_list))


#### LOAD OUTSIDE FUNCTIONS 

### LOAD SEEDING FUNCTIONS 
source("~/Github/Fair-Diff-Conflicts/R-Code/HPC_SCRIPTS/STRATEGIES/MAIN_FUNCTIONS/SEEDING_FN_MAX_ext.R", local = TRUE) 

### LOAD SIMULATOR FUNCTIONS
source("~/Github/Fair-Diff-Conflicts/R-Code/HPC_SCRIPTS/STRATEGIES/MAIN_FUNCTIONS/STRAT_SIMULATOR.R", local = TRUE) 

### LOAD FAIRNESS EVALUATION FUNCTIONS
source("~/Github/Fair-Diff-Conflicts/R-Code/HPC_SCRIPTS/STRATEGIES/MAIN_FUNCTIONS/MAX_OUTCOMES_ext.R", local = TRUE) 


## BUILD ALLO TABLE ###
## ALLO TABLE FOR MAX SEEDINGS 
### POINT WOULD BE TO SHOW EACH UNDER A NUMBER OF DIFFERENT DEFINITIONS
# 

## For counting number of seeds 
female_nodes = vill_df$i[vill_df$female == 1] # female nodes
male_nodes = vill_df$i[vill_df$female == 0] # male nodes

for(i in 1:max_len){
  

  max_allo_table[[i]] <- tibble(strategy = rep(max_seeding_type_list[i], length(fairness_types)))
  
  ## SEEDING_FUNCTION 
  max_seed_list[[i]] <- max_seeds_fn(seeds_n = seed_num, vill_df = vill_df, type = max_seeding_type_list[i])
  # save(seed_list, file = paste0("seed_list_", seeding_type_list[i], ".Rda"))
  
  # SEED FAIRNESS EVALUATION - object: allo_table
  # OUTCOMES
  max_allo_table[[i]]$male_seeds <- NA
  max_allo_table[[i]]$male_seeds <- sum(male_nodes %in% max_seed_list[[i]])
  max_allo_table[[i]]$female_seeds <- NA
  max_allo_table[[i]]$female_seeds <- sum(female_nodes %in% max_seed_list[[i]])
  max_allo_table[[i]]$fairness <- NA
  max_allo_table[[i]]$fairness <- fairness_types
  max_allo_table[[i]]$m_seed_out <- NA
  max_allo_table[[i]]$f_seed_out <- NA
  max_allo_table[[i]]$m_seed_out <- max_outcome_fn(seeds_n = seed_num, vill_df = vill_df, max_seed_list = max_seed_list[[i]])[[1]]
  max_allo_table[[i]]$f_seed_out <- max_outcome_fn(seeds_n = seed_num, vill_df = vill_df, max_seed_list = max_seed_list[[i]])[[2]]
  
  # STAT RATE
  max_allo_table[[i]] <- stat_rate_fn(max_allo_table[[i]], type = "seed")

  
}

max_seed_list[[22]]


### SET SEED
set_seed <- sample(0000000:9999999, 1) ## set seed function
write.table(set_seed, file = "set_seed.txt", row.names = FALSE, col.names = TRUE) ## save as .txt
set.seed(set_seed)

### MAX SIMULATIONS
max_sim_dfs = foreach(i = 1:length(max_seed_list)) %do% {
  foreach(icount(sims)) %do%{ # number of simulations for each parameter combination
    try(simulator_fn(seed_list = max_seed_list[[i]], vill = vill, t = t, vill_logit = vill_logit, nodes_df = nodes_df, edgelist = edgelist, A_p = A_p, NA_p = NA_p))
  }
}


## RETURNS: return(list(sim_df = simulation_df_fn(a = adopted, ear = heard, nodes = nodes_df), cum_rates = cum_rates_fn(a = adopted, ear = heard, vill_df = vill_df, t = t)))

#### MIGHT NEED A FUNCTION THAT REMOVES FAILED SIMS HERE 
### FUNCTION FOR HANDLING FAILED SIMULATIONS
# remove_error_fn <- function(sim_dfs){
#   for(i in 1:length(sim_dfs)){
#     for(y in 1:length(sim_dfs[[i]])){
#       if(class(sim_dfs[[i]][[y]][[1]]) == "try-error" ){
#         sim_dfs[[i]][[y]] <- NA
#       }
#     }
#     sim_dfs[[i]] <- sim_dfs[[i]][!is.na(sim_dfs[[i]])]
#   }
#   return(sim_dfs)
# }
# 
# max_sim_dfs <- remove_error_fn(sim_dfs = max_sim_dfs)


### SEPARATING DATAFRAME 
max_dfs = foreach(i = 1:max_len) %do%{
  foreach(k = 1:length(max_sim_dfs[[i]])) %do% {
    max_sim_dfs[[i]][[k]][[1]]
  }
}


### OUTCOMES 
max_allo_table = foreach(i = 1:max_len) %do% {
  max_reach_fn(all_dfs = max_dfs[[i]], allo_table = max_allo_table[[i]], sims = sims)
}
names(max_allo_table) = max_seeding_type_list


### STAT RATE
max_allo_table = foreach(i = 1:max_len) %do% {
  stat_rate_fn(allo_table = max_allo_table[[i]], type = "reach")
}

save(max_allo_table, file = "max_allo_table.Rda")


### SEPARATING CUM RATES OBJECT
max_cum_rates = foreach(i = 1:max_len) %do%{
  foreach(k = 1:sims) %do% {
    max_sim_dfs[[i]][[k]][[2]]
  }
}


### AVG CUM HEARD 
avg_cum_heard_max = max_avg_cr_fn(max_cum_rates = max_cum_rates, max_seeding_type_list = max_seeding_type_list)
names(avg_cum_heard_max) = max_seeding_type_list


save(avg_cum_heard_max, file = "avg_cum_heard_max.Rda")
