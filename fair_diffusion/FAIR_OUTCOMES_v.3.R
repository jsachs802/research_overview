out_fn <- function(df, df_obj, seeds_n, table, fair_seed_list, pop, agg){ ## Produces outcomes for all seeding strategies
  if(agg == "avg"){
    if(pop == "all"){
      
      female_nodes = df$i[df$female == 1] # female nodes
      male_nodes = df$i[df$female == 0] # male nodes
      
      avg_both_male = mean(df_obj[df$i %in% male_nodes], na.rm = TRUE) ## avg both of males in village
      avg_both_female = mean(df_obj[df$i %in% female_nodes], na.rm = TRUE) ## avg both of females in village
      
      male_out = table$male*avg_both_male
      female_out = table$female*avg_both_female
      
      return(list(male_out, female_out))
      
      
    }else if(pop == "seed"){
      
      female_nodes = df$i[df$female == 1] # female nodes
      male_nodes = df$i[df$female == 0] # male nodes
      
      male_both = df_obj[df$female == 0] # male both
      names(male_both) = male_nodes
      male_both = sort(male_both, decreasing = TRUE)
      
      female_both = df_obj[df$female == 1] # female both
      names(female_both) = female_nodes
      female_both = sort(female_both, decreasing = TRUE)
      
      male_out = sapply(1:(seeds_n-1), function(x){
        male_out = mean(male_both[1:table$male[x]], na.rm = T)
      })
      
      female_out = sapply(1:(seeds_n-1), function(x){
        female_out = mean(female_both[1:table$female[x]], na.rm = T)
      })
      
      return(list(male_out, female_out))
      
    }
    
  }else if(agg == "total"){
    
    if(pop == "all"){
      
      female_nodes = df$i[df$female == 1] # female nodes
      male_nodes = df$i[df$female == 0] # male nodes
      
      avg_both_male = sum(df_obj[df$i %in% male_nodes], na.rm = TRUE) ## avg both of males in village
      avg_both_female = sum(df_obj[df$i %in% female_nodes], na.rm = TRUE) ## avg both of females in village
      
      male_out = table$male*avg_both_male
      female_out = table$female*avg_both_female
      
      return(list(male_out, female_out))
      
      
    }else if(pop == "seed"){
      
      female_nodes = df$i[df$female == 1] # female nodes
      male_nodes = df$i[df$female == 0] # male nodes
      
      male_both = df_obj[df$female == 0] # male both
      names(male_both) = male_nodes
      male_both = sort(male_both, decreasing = TRUE)
      
      female_both = df_obj[df$female == 1] # female both
      names(female_both) = female_nodes
      female_both = sort(female_both, decreasing = TRUE)
      
      male_out = sapply(1:(seeds_n-1), function(x){
        male_out = sum(male_both[1:table$male[x]])
      })
      
      female_out = sapply(1:(seeds_n-1), function(x){
        female_out = sum(female_both[1:table$female[x]])
      })
      
      return(list(male_out, female_out))
      
    }
  }

}

fair_outcome_fn <- function(seeds_n, table, vill_df, fair_seed_list, type){
  if(type == "deg_all_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$degree, seeds_n, table, fair_seed_list, pop = "all", agg = "avg")
    return(out)
    
  }else if(type == "deg_seed_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$degree, seeds_n, table, fair_seed_list, pop = "seed", agg = "avg")
    return(out)
    
  }else if(type == "eig_all_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$eig, seeds_n, table, fair_seed_list, pop = "all", agg = "avg")
    return(out)
    
  }else if(type == "eig_seed_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$eig, seeds_n, table, fair_seed_list, pop = "seed", agg = "avg")
    return(out)
    
  }else if(type == "complex_2_all_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$complex_2, seeds_n, table, fair_seed_list, pop = "all", agg = "avg")
    return(out)
    
  }else if(type == "complex_2_seed_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$complex_2, seeds_n, table, fair_seed_list, pop = "seed", agg = "avg")
    return(out)
    
  }else if(type == "complex_4_all_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$complex_4, seeds_n, table, fair_seed_list, pop = "all", agg = "avg")
    return(out)
    
  }else if(type == "complex_4_seed_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$complex_4, seeds_n, table, fair_seed_list, pop = "seed", agg = "avg")
    return(out)
    
  }else if(type == "complex_6_all_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$complex_6, seeds_n, table, fair_seed_list, pop = "all", agg = "avg")
    return(out)
    
  }else if(type == "complex_6_seed_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$complex_6, seeds_n, table, fair_seed_list, pop = "seed", agg = "avg")
    return(out)
    
  }else if(type == "perco_all_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$perco, seeds_n, table, fair_seed_list, pop = "all", agg = "avg")
    return(out)
    
  }else if(type == "perco_seed_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$perco, seeds_n, table, fair_seed_list, pop = "seed", agg = "avg")
    return(out)
    
  }else if(type == "coreness_all_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$coreness, seeds_n, table, fair_seed_list, pop = "all", agg = "avg")
    return(out)
    
  }else if(type == "coreness_seed_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$coreness, seeds_n, table, fair_seed_list, pop = "seed", agg = "avg")
    return(out)
    
  }else if(type == "closeness_all_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$closeness, seeds_n, table, fair_seed_list, pop = "all", agg = "avg")
    return(out)
    
  }else if(type == "closeness_seed_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$closeness, seeds_n, table, fair_seed_list, pop = "seed", agg = "avg")
    return(out)
    
  }else if(type == "between_all_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$between, seeds_n, table, fair_seed_list, pop = "all", agg = "avg")
    return(out)
    
  }else if(type == "between_seed_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$between, seeds_n, table, fair_seed_list, pop = "seed", agg = "avg")
    return(out)
    
  }else if(type == "inf_max01_all_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$inf_max01, seeds_n, table, fair_seed_list, pop = "all", agg = "avg")
    return(out)
    
  }else if(type == "inf_max01_seed_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$inf_max01, seeds_n, table, fair_seed_list, pop = "seed", agg = "avg")
    return(out)
    
  }else if(type == "inf_max10_all_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$inf_max10, seeds_n, table, fair_seed_list, pop = "all", agg = "avg")
    return(out)
    
  }else if(type == "inf_max10_seed_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$inf_max10, seeds_n, table, fair_seed_list, pop = "seed", agg = "avg")
    return(out)
    
  }else if(type == "inf_max25_all_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$inf_max25, seeds_n, table, fair_seed_list, pop = "all", agg = "avg")
    return(out)
    
  }else if(type == "inf_max25_seed_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$inf_max25, seeds_n, table, fair_seed_list, pop = "seed", agg = "avg")
    return(out)
    
  }else if(type == "inf_max50_all_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$inf_max50, seeds_n, table, fair_seed_list, pop = "all", agg = "avg")
    return(out)
    
  }else if(type == "inf_max50_seed_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$inf_max50, seeds_n, table, fair_seed_list, pop = "seed", agg = "avg")
    return(out)
    
  }else if(type == "wt_deg_all_avg"){ 
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_deg, seeds_n, table, fair_seed_list, pop = "all", agg = "avg")
    return(out)
    
  }else if(type == "wt_deg_seed_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_deg, seeds_n, table, fair_seed_list, pop = "seed", agg = "avg")
    return(out)
    
  }else if(type == "wt_eig_all_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_eig, seeds_n, table, fair_seed_list, pop = "all", agg = "avg")
    return(out)
    
  }else if(type == "wt_eig_seed_avg"){
  
    out = out_fn(df = vill_df, df_obj = vill_df$wt_eig, seeds_n, table, fair_seed_list, pop = "seed", agg = "avg")
    return(out)  
    
  }else if(type == "wt_complex_2_all_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_complex_2, seeds_n, table, fair_seed_list, pop = "all", agg = "avg")
    return(out)
    
  }else if(type == "wt_complex_2_seed_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_complex_2, seeds_n, table, fair_seed_list, pop = "seed", agg = "avg")
    return(out)
    
  }else if(type == "wt_complex_4_all_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_complex_4, seeds_n, table, fair_seed_list, pop = "all", agg = "avg")
    return(out)  
  
  }else if(type == "wt_complex_4_seed_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_complex_4, seeds_n, table, fair_seed_list, pop = "seed", agg = "avg")
    return(out)
    
  }else if(type == "wt_complex_6_all_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_complex_6, seeds_n, table, fair_seed_list, pop = "all", agg = "avg")
    return(out)
    
  }else if(type == "wt_complex_6_seed_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_complex_6, seeds_n, table, fair_seed_list, pop = "seed", agg = "avg")
    return(out)
    
  }else if(type == "wt_perco_all_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_perco, seeds_n, table, fair_seed_list, pop = "all", agg = "avg")
    return(out)
    
  }else if(type == "wt_perco_seed_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_perco, seeds_n, table, fair_seed_list, pop = "seed", agg = "avg")
    return(out)
    
  }else if(type == "wt_coreness_all_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_coreness, seeds_n, table, fair_seed_list, pop = "all", agg = "avg")
    return(out)
    
  }else if(type == "wt_coreness_seed_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_coreness, seeds_n, table, fair_seed_list, pop = "seed", agg = "avg")
    return(out)
    
  }else if(type == "wt_closeness_all_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_closeness, seeds_n, table, fair_seed_list, pop = "all", agg = "avg")
    return(out)
    
  }else if(type == "wt_closeness_seed_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_closeness, seeds_n, table, fair_seed_list, pop = "seed", agg = "avg")
    return(out)

  }else if(type == "wt_between_all_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_between, seeds_n, table, fair_seed_list, pop = "all", agg = "avg")
    return(out)
    
  }else if(type == "wt_between_seed_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_between, seeds_n, table, fair_seed_list, pop = "seed", agg = "avg")
    return(out)
    
  }else if(type == "wt_inf_max01_all_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_inf_max01, seeds_n, table, fair_seed_list, pop = "all", agg = "avg")
    return(out)
    
  }else if(type == "wt_inf_max01_seed_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_inf_max01, seeds_n, table, fair_seed_list, pop = "seed", agg = "avg")
    return(out)
    
  }else if(type == "wt_inf_max10_all_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_inf_max10, seeds_n, table, fair_seed_list, pop = "all", agg = "avg")
    return(out)
    
  }else if(type == "wt_inf_max10_seed_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_inf_max10, seeds_n, table, fair_seed_list, pop = "seed", agg = "avg")
    return(out)
    
  }else if(type == "wt_inf_max25_all_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_inf_max25, seeds_n, table, fair_seed_list, pop = "all", agg = "avg")
    return(out)
    
  }else if(type == "wt_inf_max25_seed_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_inf_max25, seeds_n, table, fair_seed_list, pop = "seed", agg = "avg")
    return(out)
    
  }else if(type == "wt_inf_max50_all_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_inf_max50, seeds_n, table, fair_seed_list, pop = "all", agg = "avg")
    return(out)
    
  }else if(type == "wt_inf_max50_seed_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_inf_max50, seeds_n, table, fair_seed_list, pop = "seed", agg = "avg")
    return(out)
    
  }else if(type == "like_all_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$ex_info, seeds_n, table, fair_seed_list, pop = "all", agg = "avg")
    return(out)

  }else if(type == "like_seed_avg"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$ex_info, seeds_n, table, fair_seed_list, pop = "seed", agg = "avg")
    return(out)
  
  }else if(type == "deg_all_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$degree, seeds_n, table, fair_seed_list, pop = "all", agg = "total")
    return(out)
    
  }else if(type == "deg_seed_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$degree, seeds_n, table, fair_seed_list, pop = "seed", agg = "total")
    return(out)
    
  }else if(type == "eig_all_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$eig, seeds_n, table, fair_seed_list, pop = "all", agg = "total")
    return(out)
    
  }else if(type == "eig_seed_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$eig, seeds_n, table, fair_seed_list, pop = "seed", agg = "total")
    return(out)
    
  }else if(type == "complex_2_all_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$complex_2, seeds_n, table, fair_seed_list, pop = "all", agg = "total")
    return(out)
    
  }else if(type == "complex_2_seed_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$complex_2, seeds_n, table, fair_seed_list, pop = "seed", agg = "total")
    return(out)
    
  }else if(type == "complex_4_all_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$complex_4, seeds_n, table, fair_seed_list, pop = "all", agg = "total")
    return(out)
    
  }else if(type == "complex_4_seed_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$complex_4, seeds_n, table, fair_seed_list, pop = "seed", agg = "total")
    return(out)
    
  }else if(type == "complex_6_all_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$complex_6, seeds_n, table, fair_seed_list, pop = "all", agg = "total")
    return(out)
    
  }else if(type == "complex_6_seed_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$complex_6, seeds_n, table, fair_seed_list, pop = "seed", agg = "total")
    return(out)
    
  }else if(type == "perco_all_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$perco, seeds_n, table, fair_seed_list, pop = "all", agg = "total")
    return(out)
    
  }else if(type == "perco_seed_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$perco, seeds_n, table, fair_seed_list, pop = "seed", agg = "total")
    return(out)
    
  }else if(type == "coreness_all_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$coreness, seeds_n, table, fair_seed_list, pop = "all", agg = "total")
    return(out)
    
  }else if(type == "coreness_seed_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$coreness, seeds_n, table, fair_seed_list, pop = "seed", agg = "total")
    return(out)
    
  }else if(type == "closeness_all_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$closeness, seeds_n, table, fair_seed_list, pop = "all", agg = "total")
    return(out)
    
  }else if(type == "closeness_seed_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$closeness, seeds_n, table, fair_seed_list, pop = "seed", agg = "total")
    return(out)
    
  }else if(type == "between_all_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$between, seeds_n, table, fair_seed_list, pop = "all", agg = "total")
    return(out)
    
  }else if(type == "between_seed_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$between, seeds_n, table, fair_seed_list, pop = "seed", agg = "total")
    return(out)
    
  }else if(type == "inf_max01_all_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$inf_max01, seeds_n, table, fair_seed_list, pop = "all", agg = "total")
    return(out)
    
  }else if(type == "inf_max01_seed_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$inf_max01, seeds_n, table, fair_seed_list, pop = "seed", agg = "total")
    return(out)
    
  }else if(type == "inf_max10_all_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$inf_max10, seeds_n, table, fair_seed_list, pop = "all", agg = "total")
    return(out)
    
  }else if(type == "inf_max10_seed_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$inf_max10, seeds_n, table, fair_seed_list, pop = "seed", agg = "total")
    return(out)
    
  }else if(type == "inf_max25_all_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$inf_max25, seeds_n, table, fair_seed_list, pop = "all", agg = "total")
    return(out)
    
  }else if(type == "inf_max25_seed_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$inf_max25, seeds_n, table, fair_seed_list, pop = "seed", agg = "total")
    return(out)
    
  }else if(type == "inf_max50_all_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$inf_max50, seeds_n, table, fair_seed_list, pop = "all", agg = "total")
    return(out)
    
  }else if(type == "inf_max50_seed_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$inf_max50, seeds_n, table, fair_seed_list, pop = "seed", agg = "total")
    return(out)
    
  }else if(type == "wt_deg_all_total"){ 
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_deg, seeds_n, table, fair_seed_list, pop = "all", agg = "total")
    return(out)
    
  }else if(type == "wt_deg_seed_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_deg, seeds_n, table, fair_seed_list, pop = "seed", agg = "total")
    return(out)
    
  }else if(type == "wt_eig_all_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_eig, seeds_n, table, fair_seed_list, pop = "all", agg = "total")
    return(out)
    
  }else if(type == "wt_eig_seed_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_eig, seeds_n, table, fair_seed_list, pop = "seed", agg = "total")
    return(out)  
    
  }else if(type == "wt_complex_2_all_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_complex_2, seeds_n, table, fair_seed_list, pop = "all", agg = "total")
    return(out)
    
  }else if(type == "wt_complex_2_seed_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_complex_2, seeds_n, table, fair_seed_list, pop = "seed", agg = "total")
    return(out)
    
  }else if(type == "wt_complex_4_all_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_complex_4, seeds_n, table, fair_seed_list, pop = "all", agg = "total")
    return(out)  
    
  }else if(type == "wt_complex_4_seed_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_complex_4, seeds_n, table, fair_seed_list, pop = "seed", agg = "total")
    return(out)
    
  }else if(type == "wt_complex_6_all_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_complex_6, seeds_n, table, fair_seed_list, pop = "all", agg = "total")
    return(out)
    
  }else if(type == "wt_complex_6_seed_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_complex_6, seeds_n, table, fair_seed_list, pop = "seed", agg = "total")
    return(out)
    
  }else if(type == "wt_perco_all_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_perco, seeds_n, table, fair_seed_list, pop = "all", agg = "total")
    return(out)
    
  }else if(type == "wt_perco_seed_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_perco, seeds_n, table, fair_seed_list, pop = "seed", agg = "total")
    return(out)
    
  }else if(type == "wt_coreness_all_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_coreness, seeds_n, table, fair_seed_list, pop = "all", agg = "total")
    return(out)
    
  }else if(type == "wt_coreness_seed_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_coreness, seeds_n, table, fair_seed_list, pop = "seed", agg = "total")
    return(out)
    
  }else if(type == "wt_closeness_all_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_closeness, seeds_n, table, fair_seed_list, pop = "all", agg = "total")
    return(out)
    
  }else if(type == "wt_closeness_seed_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_closeness, seeds_n, table, fair_seed_list, pop = "seed", agg = "total")
    return(out)
    
  }else if(type == "wt_between_all_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_between, seeds_n, table, fair_seed_list, pop = "all", agg = "total")
    return(out)
    
  }else if(type == "wt_between_seed_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_between, seeds_n, table, fair_seed_list, pop = "seed", agg = "total")
    return(out)
    
  }else if(type == "wt_inf_max01_all_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_inf_max01, seeds_n, table, fair_seed_list, pop = "all", agg = "total")
    return(out)
    
  }else if(type == "wt_inf_max01_seed_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_inf_max01, seeds_n, table, fair_seed_list, pop = "seed", agg = "total")
    return(out)
    
  }else if(type == "wt_inf_max10_all_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_inf_max10, seeds_n, table, fair_seed_list, pop = "all", agg = "total")
    return(out)
    
  }else if(type == "wt_inf_max10_seed_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_inf_max10, seeds_n, table, fair_seed_list, pop = "seed", agg = "total")
    return(out)
    
  }else if(type == "wt_inf_max25_all_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_inf_max25, seeds_n, table, fair_seed_list, pop = "all", agg = "total")
    return(out)
    
  }else if(type == "wt_inf_max25_seed_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_inf_max25, seeds_n, table, fair_seed_list, pop = "seed", agg = "total")
    return(out)
    
  }else if(type == "wt_inf_max50_all_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_inf_max50, seeds_n, table, fair_seed_list, pop = "all", agg = "total")
    return(out)
    
  }else if(type == "wt_inf_max50_seed_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$wt_inf_max50, seeds_n, table, fair_seed_list, pop = "seed", agg = "total")
    return(out)
    
  }else if(type == "like_all_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$ex_info, seeds_n, table, fair_seed_list, pop = "all", agg = "total")
    return(out)
    
  }else if(type == "like_seed_total"){
    
    out = out_fn(df = vill_df, df_obj = vill_df$ex_info, seeds_n, table, fair_seed_list, pop = "seed", agg = "total")
    return(out)
    
  }
  
} 


### CATEGORIES 

### FAIRNESS TYPE: 
  ## ALL or SEEDS 
  ## AVG or TOTAL 

### SEEDING TYPE: 

### WEIGHTING - Y/N




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

### REACH FUNCTION 
reach_fn <- function(all_dfs, allo_table, sims){
  
  allo_table$heard <- NA
  allo_table$heard_p <- NA
  allo_table$male_heard <- NA
  allo_table$male_p <- NA
  allo_table$female_heard <- NA
  allo_table$female_p <- NA
  allo_table$heard_sd <- NA
  allo_table$h_male_sd <- NA
  allo_table$h_female_sd <- NA
  for(i in 1:length(all_dfs)){
    all_dfs[[i]] = data.table::rbindlist(all_dfs[[i]])
    all_dfs[[i]]$sim <- NA
    all_dfs[[i]]$sim <- sort(rep(1:sims, length(unique(all_dfs[[i]]$i))))
    allo_table$heard[i] <- sum(all_dfs[[i]]$heard, na.rm = TRUE)/sims
    allo_table$male_heard[i] <- sum(all_dfs[[i]]$heard[all_dfs[[i]]$female == 0], na.rm = TRUE)/sims
    allo_table$female_heard[i] <- sum(all_dfs[[i]]$heard[all_dfs[[i]]$female == 1], na.rm = TRUE)/sims
    allo_table$heard_p[i] <- allo_table$heard[i]/(length(all_dfs[[i]]$i)/sims)
    allo_table$male_p[i] <- allo_table$male_heard[i]/(length(all_dfs[[i]]$i[all_dfs[[i]]$female == 0])/sims)
    allo_table$female_p[i] <- allo_table$female_heard[i]/(length(all_dfs[[i]]$i[all_dfs[[i]]$female == 1])/sims)
    allo_table$heard_sd[i] <- reach_sd_fn(all_dfs = all_dfs[[i]], type = "both")
    allo_table$h_male_sd[i] <- reach_sd_fn(all_dfs = all_dfs[[i]], type = "male")
    allo_table$h_female_sd[i] <- reach_sd_fn(all_dfs = all_dfs[[i]], type = "female")
  }
  
  return(allo_table)
  
}




# reach_fn <- function(all_dfs, allo_table, sims){
#   
#   allo_table$heard <- NA
#   allo_table$heard_p <- NA
#   allo_table$male_heard <- NA
#   allo_table$male_p <- NA
#   allo_table$female_heard <- NA
#   allo_table$female_p <- NA
#   for(i in 1:length(all_dfs)){
#     all_dfs[[i]] = data.table::rbindlist(all_dfs[[i]])
#     allo_table$heard[i] <- sum(all_dfs[[i]]$heard, na.rm = TRUE)/sims
#     allo_table$male_heard[i] <- sum(all_dfs[[i]]$heard[all_dfs[[i]]$female == 0], na.rm = TRUE)/sims
#     allo_table$female_heard[i] <- sum(all_dfs[[i]]$heard[all_dfs[[i]]$female == 1], na.rm = TRUE)/sims
#     allo_table$heard_p[i] <- allo_table$heard[i]/(length(all_dfs[[i]]$i)/sims)
#     allo_table$male_p[i] <- allo_table$male_heard[i]/(length(all_dfs[[i]]$i[all_dfs[[i]]$female == 0])/sims)
#     allo_table$female_p[i] <- allo_table$female_heard[i]/(length(all_dfs[[i]]$i[all_dfs[[i]]$female == 1])/sims)
#   }
#   
#   return(allo_table)
#   
# }

## STATISTICAL RATE FUNCTION 
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
  
} ### Check if the ungroup() is needed


## AVERAGE CUM RATE FUNCTION
fair_avg_cr_fn <- function(cum_rates){
  flat = data.table::rbindlist(cum_rates)
  avg = flat %>% group_by(period) %>% summarize(avg_cum_heard = mean(cum_heard), cum_sd = sd(cum_heard), avg_male = mean(male), male_sd = sd(male), avg_female = mean(female), female_sd = sd(female))
  return(avg)
}