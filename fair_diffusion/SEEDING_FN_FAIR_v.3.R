### SEEDING STRATEGIES ### 


seeds_fn <- function(seeds_n, vill_df, out_obj, male, female){
  
  female_nodes = vill_df$i[vill_df$female == 1] # female nodes
  male_nodes = vill_df$i[vill_df$female == 0] # male nodes
  
  male_out = out_obj[vill_df$female == 0] # male outcome
  names(male_out) = male_nodes
  male_out = sort(male_out, decreasing = TRUE)
  
  female_out = out_obj[vill_df$female == 1] # female outcome
  names(female_out) = female_nodes
  female_out = sort(female_out, decreasing = TRUE)
  
  seeds = lapply(1:(seeds_n-1), function(x){
    male_seeds = names(male_out[1:male[x]])
    female_seeds = names(female_out[1:female[x]])
    seeds = c(male_seeds, female_seeds)
    return(seeds)
    
  })
  
  return(seeds)
  
}





fair_seeds_fn <- function(seeds_n, male, female, vill_df, type){
  if(type %in% c("deg_all_avg", "deg_seed_avg", "deg_all_total", "deg_seed_total")){
    seeds <- seeds_fn(seeds_n, vill_df, out_obj = vill_df$degree, male, female)
    return(seeds)
  
  }else if(type %in% c("eig_all_avg", "eig_seed_avg", "eig_all_total", "eig_seed_total")){
    seeds <- seeds_fn(seeds_n, vill_df, out_obj = vill_df$eig, male, female)
    return(seeds)

  }else if(type %in% c("complex_2_all_avg", "complex_2_seed_avg", "complex_2_all_total", "complex_2_seed_total")){
    seeds <- seeds_fn(seeds_n, vill_df, out_obj = vill_df$complex_2, male, female)
    return(seeds)
    
  }else if(type %in% c("complex_4_all_avg", "complex_4_seed_avg", "complex_4_all_total", "complex_4_seed_total")){
    seeds <- seeds_fn(seeds_n, vill_df, out_obj = vill_df$complex_4, male, female)
    return(seeds)
    
  }else if(type %in% c("complex_6_all_avg", "complex_6_seed_avg", "complex_6_all_total", "complex_6_seed_total")){
    seeds <- seeds_fn(seeds_n, vill_df, out_obj = vill_df$complex_6, male, female)
    return(seeds)
    
  }else if(type %in% c("perco_all_avg", "perco_seed_avg", "perco_all_total", "perco_seed_total")){
    seeds <- seeds_fn(seeds_n, vill_df, out_obj = vill_df$perco, male, female)
    return(seeds)
    
  }else if(type %in% c("coreness_all_avg", "coreness_seed_avg", "coreness_all_total", "coreness_seed_total")){
    seeds <- seeds_fn(seeds_n, vill_df, out_obj = vill_df$coreness, male, female)
    return(seeds)
    
  }else if(type %in% c("closeness_all_avg", "closeness_seed_avg", "closeness_all_total", "closeness_seed_total")){
    seeds <- seeds_fn(seeds_n, vill_df, out_obj = vill_df$closeness, male, female)
    return(seeds)

  }else if(type %in% c("between_all_avg", "between_seed_avg", "between_all_total", "between_seed_total")){
    seeds <- seeds_fn(seeds_n, vill_df, out_obj = vill_df$between, male, female)
    return(seeds)
    
  }else if(type %in% c("inf_max01_all_avg", "inf_max01_seed_avg", "inf_max01_all_total", "inf_max01_seed_total")){
    seeds <- seeds_fn(seeds_n, vill_df, out_obj = vill_df$inf_max01, male, female)
    return(seeds)
    
  }else if(type %in% c("inf_max10_all_avg", "inf_max10_seed_avg", "inf_max10_all_total", "inf_max10_seed_total")){
    seeds <- seeds_fn(seeds_n, vill_df, out_obj = vill_df$inf_max10, male, female)
    return(seeds)
    
  }else if(type %in% c("inf_max25_all_avg", "inf_max25_seed_avg", "inf_max25_all_total", "inf_max25_seed_total")){
    seeds <- seeds_fn(seeds_n, vill_df, out_obj = vill_df$inf_max25, male, female)
    return(seeds)
    
  }else if(type %in% c("inf_max50_all_avg", "inf_max50_seed_avg", "inf_max50_all_total", "inf_max50_seed_total")){
    seeds <- seeds_fn(seeds_n, vill_df, out_obj = vill_df$inf_max50, male, female)
    return(seeds)

  }else if(type %in% c("wt_deg_all_avg", "wt_deg_seed_avg", "wt_deg_all_total", "wt_deg_seed_total")){ 
    seeds <- seeds_fn(seeds_n, vill_df, out_obj = vill_df$wt_deg, male, female)
    return(seeds)

  }else if(type %in% c("wt_eig_all_avg", "wt_eig_seed_avg", "wt_eig_all_total", "wt_eig_seed_total")){
    seeds <- seeds_fn(seeds_n, vill_df, out_obj = vill_df$wt_eig, male, female)
    return(seeds)

  }else if(type %in% c("wt_complex_2_all_avg", "wt_complex_2_seed_avg", "wt_complex_2_all_total", "wt_complex_2_seed_total")){
    seeds <- seeds_fn(seeds_n, vill_df, out_obj = vill_df$wt_complex_2, male, female)
    return(seeds)
    
  }else if(type %in% c("wt_complex_4_all_avg", "wt_complex_4_seed_avg", "wt_complex_4_all_total", "wt_complex_4_seed_total")){
    seeds <- seeds_fn(seeds_n, vill_df, out_obj = vill_df$wt_complex_4, male, female)
    return(seeds)
    
  }else if(type %in% c("wt_complex_6_all_avg", "wt_complex_6_seed_avg", "wt_complex_6_all_total", "wt_complex_6_seed_total")){
    seeds <- seeds_fn(seeds_n, vill_df, out_obj = vill_df$wt_complex_6, male, female)
    return(seeds)

  }else if(type %in% c("wt_perco_all_avg", "wt_perco_seed_avg", "wt_perco_all_total", "wt_perco_seed_total")){
    seeds <- seeds_fn(seeds_n, vill_df, out_obj = vill_df$wt_perco, male, female)
    return(seeds)

  }else if(type %in% c("wt_coreness_all_avg", "wt_coreness_seed_avg", "wt_coreness_all_total", "wt_coreness_seed_total")){
    seeds <- seeds_fn(seeds_n, vill_df, out_obj = vill_df$wt_coreness, male, female)
    return(seeds)

  }else if(type %in% c("wt_closeness_all_avg", "wt_closeness_seed_avg", "wt_closeness_all_total", "wt_closeness_seed_total")){
    seeds <- seeds_fn(seeds_n, vill_df, out_obj = vill_df$wt_closeness, male, female)
    return(seeds)
    
  }else if(type %in% c("wt_between_all_avg", "wt_between_seed_avg", "wt_between_all_total", "wt_between_seed_total")){
    seeds <- seeds_fn(seeds_n, vill_df, out_obj = vill_df$wt_between, male, female)
    return(seeds)

  }else if(type %in% c("wt_inf_max01_all_avg", "wt_inf_max01_seed_avg", "wt_inf_max01_all_total", "wt_inf_max01_seed_total")){
    seeds <- seeds_fn(seeds_n, vill_df, out_obj = vill_df$wt_inf_max01, male, female)
    return(seeds)
    
  }else if(type %in% c("wt_inf_max10_all_avg", "wt_inf_max10_seed_avg", "wt_inf_max10_all_total", "wt_inf_max10_seed_total")){
    seeds <- seeds_fn(seeds_n, vill_df, out_obj = vill_df$wt_inf_max10, male, female)
    return(seeds)

  }else if(type %in% c("wt_inf_max25_all_avg", "wt_inf_max25_seed_avg", "wt_inf_max25_all_total", "wt_inf_max25_seed_total")){
    seeds <- seeds_fn(seeds_n, vill_df, out_obj = vill_df$wt_inf_max25, male, female)
    return(seeds)
    
  }else if(type %in% c("wt_inf_max50_all_avg", "wt_inf_max50_seed_avg", "wt_inf_max50_all_total", "wt_inf_max50_seed_total")){
    seeds <- seeds_fn(seeds_n, vill_df, out_obj = vill_df$wt_inf_max50, male, female)
    return(seeds)

  }else if(type %in% c("like_all_avg", "like_seed_avg", "like_all_total", "like_seed_total")){
    seeds <- seeds_fn(seeds_n, vill_df, out_obj = vill_df$ex_info, male, female)
    return(seeds)
    
  }
  
}


