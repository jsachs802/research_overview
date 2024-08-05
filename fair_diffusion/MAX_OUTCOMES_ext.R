## SHOULD PROBABLY MOVE NN over to Fairness outcomes
## Each max seeding strategy should be given a criteria 


max_out_fn <- function(seeds_n, vill_df, out_obj, max_seed_list, agg, pop){
  if(agg == "avg"){
    if(pop == "all"){
      
      female_nodes = vill_df$i[vill_df$female == 1] # female nodes
      male_nodes = vill_df$i[vill_df$female == 0] # male nodes
    
      avg_out_male = mean(out_obj[vill_df$i %in% male_nodes], na.rm = TRUE) ## avg degree of males in village
      avg_out_female = mean(out_obj[vill_df$i %in% female_nodes], na.rm = TRUE) 
      
      male = sum(male_nodes %in% max_seed_list)
      female = sum(female_nodes %in% max_seed_list)
      
      male_out = male*avg_out_male
      female_out = female*avg_out_female
      
      return(list(male_out, female_out))
      
      
    }else if(pop == "seed"){
      
      female_nodes = vill_df$i[vill_df$female == 1] # female nodes
      male_nodes = vill_df$i[vill_df$female == 0] # male nodes
      
      male_seeds = male_nodes[which(male_nodes %in% max_seed_list)]
      female_seeds = female_nodes[which(female_nodes %in% max_seed_list)]
      
      avg_out_male = mean(out_obj[vill_df$i %in% male_seeds], na.rm = TRUE) ## avg degree of males in village
      avg_out_female = mean(out_obj[vill_df$i %in% female_seeds], na.rm = TRUE) 
      
      male = sum(male_nodes %in% max_seed_list)
      female = sum(female_nodes %in% max_seed_list)
      
      male_out = male*avg_out_male
      female_out = female*avg_out_female
      
      return(list(male_out, female_out))
      
    }
      
    }else if(agg == "total"){
      if(pop == "all"){
        
        female_nodes = vill_df$i[vill_df$female == 1] # female nodes
        male_nodes = vill_df$i[vill_df$female == 0] # male nodes
        
        male_pop = length(male_nodes)/length(vill_df$i)
        female_pop = length(female_nodes)/length(vill_df$i)
        
        female = sum(out_obj[female_nodes %in% max_seed_list])
        male = sum(out_obj[male_nodes %in% max_seed_list])
        
        male_out = male*male_pop
        female_out = female*female_pop
        
        return(list(male_out, female_out))
      }else if(pop == "seed"){
        
        
        female_nodes = vill_df$i[vill_df$female == 1] # female nodes
        male_nodes = vill_df$i[vill_df$female == 0] # male nodes
        
        female_out = sum(out_obj[female_nodes %in% max_seed_list])
        male_out = sum(out_obj[male_nodes %in% max_seed_list])
        
        return(list(male_out, female_out))
    
      }
  }
}




nn_fn <- function(seeds_n, vill_df, max_seed_list){
      female_nodes = vill_df$i[vill_df$female == 1] # female nodes
      male_nodes = vill_df$i[vill_df$female == 0] # male nodes
      
      male_pop = length(male_nodes)/length(vill_df$i)
      female_pop = length(female_nodes)/length(vill_df$i)
      
      male = sum(male_nodes %in% max_seed_list)
      female = sum(female_nodes %in% max_seed_list)
      
      male_out = male*male_pop
      female_out = female*female_pop
      
      return(list(male_out, female_out))
}


 
max_outcome_fn <- function(seeds_n, vill_df, max_seed_list){
  
  return(list(male_out = c(nn_fn(seeds_n, vill_df, max_seed_list)[[1]], 
                           max_out_fn(seeds_n, vill_df, out_obj = vill_df$degree, max_seed_list, agg = "avg", pop = "all")[[1]], 
                           max_out_fn(seeds_n, vill_df, out_obj = vill_df$degree, max_seed_list, agg = "avg", pop = "seed")[[1]],
                           max_out_fn(seeds_n, vill_df, out_obj = vill_df$degree, max_seed_list, agg = "total", pop = "all")[[1]],
                           max_out_fn(seeds_n, vill_df, out_obj = vill_df$degree, max_seed_list, agg = "total", pop = "seed")[[1]]),
           female_out = c(nn_fn(seeds_n, vill_df, max_seed_list)[[2]], 
                         max_out_fn(seeds_n, vill_df, out_obj = vill_df$degree, max_seed_list, agg = "avg", pop = "all")[[2]], 
                         max_out_fn(seeds_n, vill_df, out_obj = vill_df$degree, max_seed_list, agg = "avg", pop = "seed")[[2]],
                         max_out_fn(seeds_n, vill_df, out_obj = vill_df$degree, max_seed_list, agg = "total", pop = "all")[[2]],
                         max_out_fn(seeds_n, vill_df, out_obj = vill_df$degree, max_seed_list, agg = "total", pop = "seed")[[2]])))
  
}


## REACH FUNCTION 
# max_reach_fn <- function(all_dfs, allo_table, sims){
#   
#   allo_table$heard <- NA
#   allo_table$heard_p <- NA
#   allo_table$male_heard <- NA
#   allo_table$male_p <- NA
#   allo_table$female_heard <- NA
#   allo_table$female_p <- NA
#   all_dfs = data.table::rbindlist(all_dfs)
#   allo_table$heard <- sum(all_dfs$heard, na.rm = TRUE)/sims
#   allo_table$male_heard  <- sum(all_dfs$heard[all_dfs$female == 0], na.rm = TRUE)/sims
#   allo_table$female_heard <- sum(all_dfs$heard[all_dfs$female == 1], na.rm = TRUE)/sims
#   allo_table$heard_p <- allo_table$heard/(length(all_dfs$i)/sims)
#   allo_table$male_p <- allo_table$male_heard/(length(all_dfs$i[all_dfs$female == 0])/sims)
#   allo_table$female_p <- allo_table$female_heard/(length(all_dfs$i[all_dfs$female == 1])/sims)
#   
#   return(allo_table)
#   
# }


reach_sd_fn <- function(all_dfs, type){
  if(type == "both"){
    DT = all_dfs
    DT = DT[, sum(heard), by=sim]
    sd = DT[ , sd(V1)]
    return(sd)
  }else if(type == "male"){
    DT = all_dfs
    DT = DT[female == 0, sum(heard), by=sim]
    sd = DT[ , sd(V1)]
    return(sd)
    
  }else if(type == "female"){
    DT = all_dfs
    DT = DT[female == 1, sum(heard), by=sim]
    sd = DT[ , sd(V1)]
    return(sd)
    
  }
  
}


max_reach_fn <- function(all_dfs, allo_table, sims){

  allo_table$heard <- NA
  allo_table$heard_p <- NA
  allo_table$male_heard <- NA
  allo_table$male_p <- NA
  allo_table$female_heard <- NA
  allo_table$female_p <- NA
  allo_table$heard_sd <- NA
  allo_table$h_male_sd <- NA
  allo_table$h_female_sd <- NA
  all_dfs = rbindlist(all_dfs)
  all_dfs$sim <- NA
  all_dfs$sim <- sort(rep(1:sims, length(unique(all_dfs$i))))
  allo_table$heard <- sum(all_dfs$heard, na.rm = TRUE)/sims
  allo_table$male_heard  <- sum(all_dfs$heard[all_dfs$female == 0], na.rm = TRUE)/sims
  allo_table$female_heard <- sum(all_dfs$heard[all_dfs$female == 1], na.rm = TRUE)/sims
  allo_table$heard_p <- allo_table$heard/(length(all_dfs$i)/sims)
  allo_table$male_p <- allo_table$male_heard/(length(all_dfs$i[all_dfs$female == 0])/sims)
  allo_table$female_p <- allo_table$female_heard/(length(all_dfs$i[all_dfs$female == 1])/sims)
  allo_table$heard_sd <- reach_sd_fn(all_dfs = all_dfs, type = "both")
  allo_table$h_male_sd <- reach_sd_fn(all_dfs = all_dfs, type = "male")
  allo_table$h_female_sd <- reach_sd_fn(all_dfs = all_dfs, type = "female")

  return(allo_table)

}



# STATISTICAL RATE FUNCTION
stat_rate_fn <- function(allo_table, type){
  if(type == "seed"){
    rw <- allo_table %>% rowwise() %>% mutate(seed_stat_rate = min(c(m_seed_out, f_seed_out))/max(c(m_seed_out, f_seed_out)))
    allo_table2 <- ungroup(rw)
    return(allo_table2)
  }else if(type == "reach"){
    rw <- allo_table %>% rowwise() %>% mutate(reach_stat_rate = min(c(male_p, female_p))/max(c(male_p, female_p)))
    allo_table2 <- ungroup(rw)
    return(allo_table2)
  }
  
}


### AVG CUM RATE FUNCTION 
### AVG CUMULATIVE RATE FUNCTIONS 
max_out <- vector(mode = "list", length = length(max_seeding_type_list))
avg_out <- vector(mode = "list", length = length(max_seeding_type_list))
max_avg_cr_fn <- function(max_cum_rates, max_seeding_type_list){
  for(i in 1:length(max_seeding_type_list)){
    max_out[[i]] <- data.table::rbindlist(max_cum_rates[[i]])
    avg_out[[i]] <- max_out[[i]] %>% group_by(period) %>% summarize(avg_cum_heard = mean(cum_heard), cum_sd = sd(cum_heard), avg_male = mean(male), male_sd = sd(male), avg_female = mean(female), female_sd = sd(female))
  }
  return(avg_out)
} 
