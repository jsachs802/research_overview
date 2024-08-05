### SEEDING STRATEGIES ### 
### RANDOM ### 
### MAX DEGREE ### 
### MAX LIKELIHOOD ### 
### MAX BOTH ###
### SIM ACTUAL ### 


seeds_out_fn <- function(seeds_n, vill_df, out_obj){

  out = out_obj # outcome of nodes in village
  names(out) = vill_df$i # indexing outcomes
  out_sort = sort(out, decreasing = TRUE)
  seeds = names(out_sort)[1:seeds_n]
  
  return(seeds)
  
}


max_seeds_fn <- function(seeds_n, vill_df, type){
  if(type == "actual"){
    seeds = vill_df$i[vill_df$attend == 1]
    return(seeds)
    
  }else if(type == "max_deg"){
    seeds = seeds_out_fn(seeds_n, vill_df, out_obj = vill_df$degree)
    return(seeds)
    
  }else if(type == "max_like"){
    seeds = seeds_out_fn(seeds_n, vill_df, out_obj = vill_df$ex_info)
    return(seeds)

  }else if(type == "max_wt_deg"){
    seeds = seeds_out_fn(seeds_n, vill_df, out_obj = vill_df$wt_deg)
    return(seeds)

  }else if(type == "max_eig"){
    seeds = seeds_out_fn(seeds_n, vill_df, out_obj = vill_df$eig)
    return(seeds)
    
  }else if(type == "max_wt_eig"){
    seeds = seeds_out_fn(seeds_n, vill_df, out_obj = vill_df$wt_eig)
    return(seeds)
    
  }else if(type == "max_complex_2"){
    seeds = seeds_out_fn(seeds_n, vill_df, out_obj = vill_df$complex_2)
    return(seeds)
    
  }else if(type == "max_wt_complex_2"){
    seeds = seeds_out_fn(seeds_n, vill_df, out_obj = vill_df$wt_complex_2)
    return(seeds)
    
  }else if(type == "max_complex_4"){
    seeds = seeds_out_fn(seeds_n, vill_df, out_obj = vill_df$complex_4)
    return(seeds)
    
  }else if(type == "max_wt_complex_4"){
    seeds = seeds_out_fn(seeds_n, vill_df, out_obj = vill_df$wt_complex_4)
    return(seeds)
    
  }else if(type == "max_complex_6"){
    seeds = seeds_out_fn(seeds_n, vill_df, out_obj = vill_df$complex_6)
    return(seeds)
    
  }else if(type == "max_wt_complex_6"){
    seeds = seeds_out_fn(seeds_n, vill_df, out_obj = vill_df$wt_complex_6)
    return(seeds)
    
  }else if(type == "max_perco"){
    seeds = seeds_out_fn(seeds_n, vill_df, out_obj = vill_df$perco)
    return(seeds)
    
  }else if(type == "max_wt_perco"){
    seeds = seeds_out_fn(seeds_n, vill_df, out_obj = vill_df$wt_perco)
    return(seeds)
    
  }else if(type == "max_coreness"){
    seeds = seeds_out_fn(seeds_n, vill_df, out_obj = vill_df$coreness)
    return(seeds)
    
  }else if(type == "max_wt_coreness"){
    seeds = seeds_out_fn(seeds_n, vill_df, out_obj = vill_df$wt_coreness)
    return(seeds)
    
  }else if(type == "max_closeness"){
    seeds = seeds_out_fn(seeds_n, vill_df, out_obj = vill_df$closeness)
    return(seeds)
    
  }else if(type == "max_wt_closeness"){
    seeds = seeds_out_fn(seeds_n, vill_df, out_obj = vill_df$wt_closeness)
    return(seeds)
    
  }else if(type == "max_between"){
    seeds = seeds_out_fn(seeds_n, vill_df, out_obj = vill_df$between)
    return(seeds)
    
  }else if(type == "max_wt_between"){
    seeds = seeds_out_fn(seeds_n, vill_df, out_obj = vill_df$wt_between)
    return(seeds)
    
  }else if(type == "max_inf_max01"){
    seeds = seeds_out_fn(seeds_n, vill_df, out_obj = vill_df$inf_max01)
    return(seeds)
    
  }else if(type == "max_wt_inf_max01"){
    seeds = seeds_out_fn(seeds_n, vill_df, out_obj = vill_df$wt_inf_max01)
    return(seeds)
    
  }else if(type == "max_inf_max10"){
    seeds = seeds_out_fn(seeds_n, vill_df, out_obj = vill_df$inf_max10)
    return(seeds)
    
  }else if(type == "max_wt_inf_max10"){
    seeds = seeds_out_fn(seeds_n, vill_df, out_obj = vill_df$wt_inf_max10)
    return(seeds)
    
  }else if(type == "max_inf_max25"){
    seeds = seeds_out_fn(seeds_n, vill_df, out_obj = vill_df$inf_max25)
    return(seeds)
    
  }else if(type == "max_wt_inf_max25"){
    seeds = seeds_out_fn(seeds_n, vill_df, out_obj = vill_df$wt_inf_max25)
    return(seeds)
    
  }else if(type == "max_inf_max50"){
    seeds = seeds_out_fn(seeds_n, vill_df, out_obj = vill_df$inf_max50)
    return(seeds)
    
  }else if(type == "max_wt_inf_max50"){
    seeds = seeds_out_fn(seeds_n, vill_df, out_obj = vill_df$wt_inf_max50)
    return(seeds)
    
  }
  
}