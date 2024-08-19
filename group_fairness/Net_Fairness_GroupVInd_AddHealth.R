### racial groups 

groups <- c(1, 2, 3, 4, 5)
names(groups) <- c("white", "black", "hispanic", "asian", "mixed")


deg_types_fn <- function(type, groups){
  
  if(type == 1){
    
    avg_out_deg_fn <- function(race){
      group <- unique(nodes$id[nodes$race == race])
      deg <- length(edgelist$target[(edgelist$source %in% group)])/length(group)
      return(deg)
    }
    
    avg_out_deg <- sapply(groups, avg_out_deg_fn)
    
    result <- c(avg_out_deg, min(avg_out_deg)/max(avg_out_deg))
    names(result) <- c(names(groups), "SR")
    
    return(result)
    
  }else if(type == 2){
    
    group_sizes_fn <- function(race){
      size <- length(unique(nodes$id[nodes$race == race]))
      return(size)
    }
    
    group_sizes <- sapply(groups, group_sizes_fn)
    
    index = c(group_sizes[1]/group_sizes[1], group_sizes[2]/group_sizes[1], group_sizes[3]/group_sizes[1], group_sizes[4]/group_sizes[1], group_sizes[5]/group_sizes[1])
    
    unique_out_group_ties_fn <- function(race){
      group <- unique(nodes$id[nodes$race == race])
      deg <- length(unique(edgelist$target[(edgelist$source %in% group) & !(edgelist$target %in% group)]))/index[race]
      return(deg)
    }
    
    unique_outside_group_ties <- sapply(groups, unique_out_group_ties_fn)
    
    result <- c(unique_outside_group_ties, min(unique_outside_group_ties)/max(unique_outside_group_ties))
    names(result) <- c(names(groups), "SR")
    
    return(result)

    }else if(type == 3){
    
    group_sizes_fn <- function(race){
      size <- length(unique(nodes$id[nodes$race == race]))
      return(size)
    }
    
    group_sizes <- sapply(groups, group_sizes_fn)
    
    index = c(group_sizes[1]/group_sizes[1], group_sizes[2]/group_sizes[1], group_sizes[3]/group_sizes[1], group_sizes[4]/group_sizes[1], group_sizes[5]/group_sizes[1])
    
    
    group_lev_unique_out_deg_fn <- function(race){
      group <- unique(nodes$id[nodes$race == race])
      deg <- length(unique(edgelist$target[(edgelist$source %in% group)]))/index[race]
      return(deg)
    }
    
    group_lev_unique_out <- sapply(groups, group_lev_unique_out_deg_fn)
    
    result <- c(group_lev_unique_out, min(group_lev_unique_out)/max(group_lev_unique_out))
    names(result) <- c(names(groups), "SR")
    
    return(result)
  
  }
  
  
}



deg_types_fn(type = 1, groups = groups)

deg_types_fn(type = 2, groups = groups)

deg_types_fn(type = 3, groups = groups)













