########################### MOMENT FUNCTIONS ##################################

# MOMENT DEFINITIONS  ----------------------------------------------------

## HEARD RELATED 
# 1. Percentage of individuals who heard with no neighbors who heard. 
# 2. Covariance of hearing with share of second-degree neighbors that heard  
# 3. Share of leaders that heard 
# 4. Percentage of those who heard that were female
# 5. Percentage of individuals with no participating neighbors who heard. 
# 6. Percentage of those who heard that were male
# 7. Total degree of individuals who heard
# 8. Average fraction of neighbors who heard 

## ADOPT RELATED 
# 9. Percentage of those who adopted that were male
# 10. Percentage of those who adopted that were female
# 11. Percentage of individuals who adopt with no neighbors who adopt 
# 12. Covariance of adoption with share of second-degree neighbors that adopt.  
# 13. Share of leaders that adopt. 
# 14. Total degree of individuals who adopt.
# 15. Average fraction of neighbors who adopt. 


## NEED to add adopt moments 
## NEED to select 3 adopt and 3 heard moment s


### FUNCTION FOR HANDLING FAILED SIMULATIONS
remove_error_fn <- function(sim_dfs){
  for(i in 1:length(sim_dfs)){
    for(y in 1:length(sim_dfs[[i]])){
      if(class(sim_dfs[[i]][[y]]) == "try-error" ){
        sim_dfs[[i]][[y]] <- NA
      }
    }
    sim_dfs[[i]] <- sim_dfs[[i]][!is.na(sim_dfs[[i]])]
  }
  return(sim_dfs)
}

#### HEARD MOMENTS ######## 

### SIMULATED MOMENT 1 FUNCTION ### - percentage who heard with no neighbors who heard 
sim_moment1_fn <- function(sim_dfs, edgelist){
  
  actual_heard <- vector(mode = "list", length = length(sim_dfs))
  moment <- vector(mode = "list", length = length(sim_dfs))
  moment1 <- vector(mode = "list", length = length(sim_dfs))
  avg_moment1 <- vector(mode = "list", length = length(sim_dfs))
  
  for(i in 1:length(sim_dfs)){
    actual_heard[[i]] <- vector(mode = "list", length = length(sim_dfs[[i]]))
    moment[[i]] <- vector(mode = "list", length = length(sim_dfs[[i]]))
    moment1[[i]] <- vector(mode = "list", length = length(sim_dfs[[i]]))
    
    for(y in 1:length(sim_dfs[[i]])){## changing 1 to i
      actual_heard[[i]][[y]] = sim_dfs[[i]][[y]]$i[sim_dfs[[i]][[y]]$heard == 1] # nodes who heard
      moment[[i]][[y]] = sapply(actual_heard[[i]][[y]], function(x){ # for each of those nodes
        k = unique(edgelist$j[edgelist$i == x]) # neighbors of that node
        h = sim_dfs[[i]][[y]]$i[sim_dfs[[i]][[y]]$heard == 1 & sim_dfs[[i]][[y]]$i %in% k] # of those neighbors who heard
        if(length(h) == 0){
          return(1) # if none heard
        }else{
          return(0) # if at least one heard
        }
      })
      
      
      moment1[[i]][[y]] = mean(moment[[i]][[y]], na.rm = TRUE)
      
    }
    
    avg_moment1[[i]] = mean(unlist(moment1[[i]], recursive = FALSE))
    
    
  }
  
  return(avg_moment1) 
  # sum of those with no neighbors who heard over total number who heard
  
}


### SIMULATED MOMENT 2 FUNCTION ### - Covariance of hearing with share of second-degree neighbors that heard  
sim_moment2_fn <- function(sim_dfs, edgelist){
  moment <- vector(mode = "list", length = length(sim_dfs))
  covar <- vector(mode = "list", length = length(sim_dfs))
  avg_moment2 <- vector(mode = "list", length = length(sim_dfs))
  
  
  for(i in 1:length(sim_dfs)){
    moment[[i]] <- vector(mode = "list", length = length(sim_dfs[[i]]))
    covar[[i]] <- vector(mode = "list", length = length(sim_dfs[[i]]))
    
    for(y in 1:length(sim_dfs[[i]])){
      
      moment[[i]][[y]] <-  sapply(sim_dfs[[i]][[y]]$i, function(x){
        k = unique(edgelist$j[edgelist$i == x]) # neighbors of a node
        k2 = unique(edgelist$j[(edgelist$i != x) & (edgelist$i %in% k)]) # second degree neighbors
        h = sim_dfs[[i]][[y]]$i[sim_dfs[[i]][[y]]$heard == 1 & sim_dfs[[i]][[y]]$i %in% k2] # those two-steps away that heard
        prop = length(h)/length(k2)
        
        return(prop)
        
      })
      
      sim_dfs[[i]][[y]]$twodeg <- NA
      sim_dfs[[i]][[y]]$twodeg <- moment[[i]][[y]]
      covar[[i]][[y]] = cov(sim_dfs[[i]][[y]]$heard, sim_dfs[[i]][[y]]$twodeg, use = "na.or.complete")
      
    }
    
    avg_moment2[[i]] <- mean(unlist(covar[[i]], recursive = FALSE))
    
  }
  
  
  return(avg_moment2)
  
  
}

### SIMULATED MOMENT 3 FUNCTION ### - Share of leaders that heard 
sim_moment3_fn <- function(sim_dfs, edgelist){
  
  condition1 <- vector(mode = "list", length = length(sim_dfs))
  condition2 <- vector(mode = "list", length = length(sim_dfs))
  prop_leader <- vector(mode = "list", length = length(sim_dfs))
  avg_moment3 <- vector(mode = "list", length = length(sim_dfs))
  
  
  for(i in 1:length(sim_dfs)){
    
    condition1[[i]] <- vector(mode = "list", length = length(sim_dfs[[i]]))
    condition2[[i]] <- vector(mode = "list", length = length(sim_dfs[[i]]))
    prop_leader[[i]] <- vector(mode = "list", length = length(sim_dfs[[i]]))
    
    for(x in 1:length(sim_dfs[[i]])){
      
      condition1[[i]][[x]] = length(sim_dfs[[i]][[x]]$i[sim_dfs[[i]][[x]]$leader == 1 & sim_dfs[[i]][[x]]$heard == 1]) ## number of female adopters
      condition2[[i]][[x]] = length(sim_dfs[[i]][[x]]$i[sim_dfs[[i]][[x]]$leader == 1]) ## number of leaders in the village
      prop_leader[[i]][[x]] = condition1[[i]][[x]]/condition2[[i]][[x]]
      
    }
    
    avg_moment3[[i]] <- mean(unlist(prop_leader[[i]], recursive = FALSE), na.rm = TRUE)
    
  }
  
  return(avg_moment3)
  
}

### SIMULATED MOMENT 4 FUNCTION ### - Percentage of those who heard that were female
sim_moment4_fn <- function(sim_dfs, edgelist){
  
  condition1 <- vector(mode = "list", length = length(sim_dfs))
  condition2 <- vector(mode = "list", length = length(sim_dfs))
  prop_female <- vector(mode = "list", length = length(sim_dfs))
  avg_moment4 <- vector(mode = "list", length = length(sim_dfs))
  
  for(i in 1:length(sim_dfs)){
    
    condition1[[i]] <- vector(mode = "list", length = length(sim_dfs[[i]]))
    condition2[[i]] <- vector(mode = "list", length = length(sim_dfs[[i]]))
    prop_female[[i]] <- vector(mode = "list", length = length(sim_dfs[[i]]))
    
    for(x in 1:length(sim_dfs[[i]])){
      
      condition1[[i]][[x]] = length(sim_dfs[[i]][[x]]$i[sim_dfs[[i]][[x]]$female == 1 & sim_dfs[[i]][[x]]$heard == 1]) ## number of female adopters
      condition2[[i]][[x]] = length(sim_dfs[[i]][[x]]$i[sim_dfs[[i]][[x]]$heard == 1]) ## number of adoptees in the village
      prop_female[[i]][[x]] = condition1[[i]][[x]]/condition2[[i]][[x]]
      
    }
    
    avg_moment4[[i]] <- mean(unlist(prop_female[[i]], recursive = FALSE), na.rm = TRUE)
    
  }
  
  return(avg_moment4)
  
}

### SIMULATED MOMENT 5 FUNCTION ### - Percentage of individuals with no participating neighbors who heard. 
sim_moment5_fn <- function(sim_dfs, edgelist){
  actual_heard <- vector(mode = "list", length = length(sim_dfs))
  moment <- vector(mode = "list", length = length(sim_dfs))
  moment5 <- vector(mode = "list", length = length(sim_dfs))
  avg_moment5 <- vector(mode = "list", length = length(sim_dfs))
  
  for(i in 1:length(sim_dfs)){
    actual_heard[[i]] <- vector(mode = "list", length = length(sim_dfs[[i]]))
    moment[[i]] <- vector(mode = "list", length = length(sim_dfs[[i]]))
    moment5[[i]] <- vector(mode = "list", length = length(sim_dfs[[i]]))
    
    for(y in 1:length(sim_dfs[[i]])){
      
      actual_heard[[i]][[y]] <-  sim_dfs[[i]][[y]]$i[sim_dfs[[i]][[y]]$heard == 1] # nodes who heard
      
      moment[[i]][[y]] = sapply(actual_heard[[i]][[y]], function(x){ # for each of those nodes
        k = unique(edgelist$j[edgelist$i == x]) # neighbors of that node
        h = sim_dfs[[i]][[y]]$i[sim_dfs[[i]][[y]]$adopt == 1 & sim_dfs[[i]][[y]]$i %in% k] # of those neighbors who adopt
        if(length(h) == 0){
          return(1) # if none heard
        }else{
          return(0) # if at least one heard
        }
      })
      
      moment5[[i]][[y]] <- mean(moment[[i]][[y]], na.rm = TRUE)
      
    }
    
    avg_moment5[[i]] <- mean(unlist(moment5[[i]], recursive = FALSE), na.rm = TRUE)
    
  }
  
  return(avg_moment5)
  
}

### SIMULATED MOMENT 6 FUNCTION ### - Percentage of those who heard that were male
sim_moment6_fn <- function(sim_dfs, edgelist){
  
  condition1 <- vector(mode = "list", length = length(sim_dfs))
  condition2 <- vector(mode = "list", length = length(sim_dfs))
  prop_male <- vector(mode = "list", length = length(sim_dfs))
  avg_moment6 <- vector(mode = "list", length = length(sim_dfs))
  
  for(i in 1:length(sim_dfs)){
    
    condition1[[i]] <- vector(mode = "list", length = length(sim_dfs[[i]]))
    condition2[[i]] <- vector(mode = "list", length = length(sim_dfs[[i]]))
    prop_male[[i]] <- vector(mode = "list", length = length(sim_dfs[[i]]))
    
    for(x in 1:length(sim_dfs[[i]])){
      
      condition1[[i]][[x]] = length(sim_dfs[[i]][[x]]$i[sim_dfs[[i]][[x]]$female == 0 & sim_dfs[[i]][[x]]$heard == 1]) ## number of males who heard
      condition2[[i]][[x]] = length(sim_dfs[[i]][[x]]$i[sim_dfs[[i]][[x]]$heard == 1]) ## number of males in the village
      prop_male[[i]][[x]] = condition1[[i]][[x]]/condition2[[i]][[x]]
      
    }
    
    avg_moment6[[i]] <- mean(unlist(prop_male[[i]], recursive = FALSE), na.rm = TRUE)
    
  }
  
  return(avg_moment6)
  
}

### SIMULATED MOMENT 7 FUNCTION ###  - Total degree of individuals who heard
sim_moment7_fn <- function(sim_dfs, edgelist){
  
  condition1 <- vector(mode = "list", length = length(sim_dfs))
  avg_moment7 <- vector(mode = "list", length = length(sim_dfs))
  
  for(i in 1:length(sim_dfs)){
    
    condition1[[i]] <- vector(mode = "list", length = length(sim_dfs[[i]]))
    
    for(x in 1:length(sim_dfs[[i]])){
      
      condition1[[i]][[x]] = sum(sim_dfs[[i]][[x]]$degree[sim_dfs[[i]][[x]]$heard == 1], na.rm = TRUE) ## number of female adopters
      
    }
    
    avg_moment7[[i]] <- mean(unlist(condition1[[i]], recursive = FALSE), na.rm = TRUE)
    
  }
  
  return(avg_moment7)
  
}

### SIMULATED MOMENT 8 FUNCTION ### - Average fraction of neighbors who heard 
sim_moment8_fn <- function(sim_dfs, edgelist){
  avg_moment8 <- vector(mode = "list", length(sim_dfs))
  moment <- vector(mode = "list", length = length(sim_dfs))
  
  for(i in 1:length(sim_dfs)){
    moment[[i]] <- vector(mode = "list", length = length(sim_dfs[[i]]))
    
    for(y in 1:length(sim_dfs[[i]])){
      
      
      moment[[i]][[y]] = sapply(sim_dfs[[i]][[y]]$i, function(x){ # for each of those nodes
        k = unique(edgelist$j[edgelist$i == x]) # neighbors of that node
        h = sim_dfs[[i]][[y]]$i[sim_dfs[[i]][[y]]$heard == 1 & sim_dfs[[i]][[y]]$i %in% k] # of those neighbors who heard
        return(length(h)/length(k))
        
        
      })
      
      
    }
    
    avg_moment8[[i]] <- mean(unlist(moment[[i]], recursive = FALSE), na.rm = TRUE)
    
  }
  
  return(avg_moment8)
  
}


##### ADOPTION MOMENTS ##### 

### SIMULATED MOMENT 9 FUNCTION ### - Percentage of those who adopted that were male
sim_moment9_fn <- function(sim_dfs, edgelist){
  condition1 <- vector(mode = "list", length = length(sim_dfs))
  condition2 <- vector(mode = "list", length = length(sim_dfs))
  prop_female <- vector(mode = "list", length = length(sim_dfs))
  avg_moment9 <- vector(mode = "list", length = length(sim_dfs))
  for(i in 1:length(sim_dfs)){
    
    condition1[[i]] <- vector(mode = "list", length = length(sim_dfs[[i]]))
    condition2[[i]] <- vector(mode = "list", length = length(sim_dfs[[i]]))
    prop_female[[i]] <- vector(mode = "list", length = length(sim_dfs[[i]]))
    
    for(x in 1:length(sim_dfs[[i]])){
      
      condition1[[i]][[x]] = length(sim_dfs[[i]][[x]]$i[sim_dfs[[i]][[x]]$female == 0 & sim_dfs[[i]][[x]]$adopt == 1]) ## number of female adopters
      condition2[[i]][[x]] = length(sim_dfs[[i]][[x]]$i[sim_dfs[[i]][[x]]$adopt == 1]) ## number of adoptees in the village
      if(condition2[[i]][[x]] == 0){
        
        prop_female[[i]][[x]] = 0
        
      }else{
        
        prop_female[[i]][[x]] = condition1[[i]][[x]]/condition2[[i]][[x]]
        
      }
      
      
    }
    
    avg_moment9[[i]] <- mean(unlist(prop_female[[i]], recursive = FALSE), na.rm = TRUE)
  }
  
  return(avg_moment9)
  
}



### SIMULATED MOMENT 10 FUNCTION ### - Percentage of those who adopted that were female

sim_moment10_fn <- function(sim_dfs, edgelist){
  
  condition1 <- vector(mode = "list", length = length(sim_dfs))
  condition2 <- vector(mode = "list", length = length(sim_dfs))
  prop_male <- vector(mode = "list", length = length(sim_dfs))
  avg_moment10 <- vector(mode = "list", length = length(sim_dfs))
  
  for(i in 1:length(sim_dfs)){
    
    condition1[[i]] <- vector(mode = "list", length = length(sim_dfs[[i]]))
    condition2[[i]] <- vector(mode = "list", length = length(sim_dfs[[i]]))
    prop_male[[i]] <- vector(mode = "list", length = length(sim_dfs[[i]]))
    
    for(x in 1:length(sim_dfs[[i]])){
      
      condition1[[i]][[x]] = length(sim_dfs[[i]][[x]]$i[sim_dfs[[i]][[x]]$female == 1 & sim_dfs[[i]][[x]]$adopt == 1]) ## number of males who heard
      condition2[[i]][[x]] = length(sim_dfs[[i]][[x]]$i[sim_dfs[[i]][[x]]$adopt == 1]) ## number of males in the village
      prop_male[[i]][[x]] = condition1[[i]][[x]]/condition2[[i]][[x]]
      
    }
    
    avg_moment10[[i]] <- mean(unlist(prop_male[[i]], recursive = FALSE), na.rm = TRUE)
    
  }
  
  return(avg_moment10)
  
}

### SIMULATED MOMENT 11 FUNCTION ### - Percentage of individuals who adopted with no neighbors who adopted

sim_moment11_fn <- function(sim_dfs, edgelist){
  
  actual_adopt <- vector(mode = "list", length = length(sim_dfs))
  moment <- vector(mode = "list", length = length(sim_dfs))
  moment11 <- vector(mode = "list", length = length(sim_dfs))
  avg_moment11 <- vector(mode = "list", length = length(sim_dfs))
  
  for(i in 1:length(sim_dfs)){
    actual_adopt[[i]] <- vector(mode = "list", length = length(sim_dfs[[i]]))
    moment[[i]] <- vector(mode = "list", length = length(sim_dfs[[i]]))
    moment11[[i]] <- vector(mode = "list", length = length(sim_dfs[[i]]))
    
    for(y in 1:length(sim_dfs[[i]])){## changing 1 to i
      actual_adopt[[i]][[y]] = sim_dfs[[i]][[y]]$i[sim_dfs[[i]][[y]]$adopt == 1] # nodes who adopted
      if(length(actual_adopt[[i]][[y]]) == 0){
        moment[[i]][[y]] = 0
      }else{
        moment[[i]][[y]] = sapply(actual_adopt[[i]][[y]], function(x){ # for each of those nodes
          k = unique(edgelist$j[edgelist$i == x]) # neighbors of that node
          h = sim_dfs[[i]][[y]]$i[sim_dfs[[i]][[y]]$adopt == 1 & sim_dfs[[i]][[y]]$i %in% k] # of those neighbors who adopted
          if(length(h) == 0){
            return(1) # if none heard
          }else{
            return(0) # if at least one heard
          }
        })
        
      }
      
        moment11[[i]][[y]] = mean(moment[[i]][[y]], na.rm = TRUE)
      
    }
    
      avg_moment11[[i]] = mean(unlist(moment11[[i]], recursive = FALSE), na.rm = TRUE)

  }
  
    return(avg_moment11) 
  # sum of those with no neighbors who heard over total number who heard
  
}




### SIMULATED MOMENT 12 ### - Covariance of adopting with share of second-degree neighbors that adopt. 
sim_moment12_fn <- function(sim_dfs, edgelist){
  moment <- vector(mode = "list", length = length(sim_dfs))
  covar <- vector(mode = "list", length = length(sim_dfs))
  avg_moment12 <- vector(mode = "list", length = length(sim_dfs))
  
  
  for(i in 1:length(sim_dfs)){
    moment[[i]] <- vector(mode = "list", length = length(sim_dfs[[i]]))
    covar[[i]] <- vector(mode = "list", length = length(sim_dfs[[i]]))
    
    for(y in 1:length(sim_dfs[[i]])){
      
      moment[[i]][[y]] <-  sapply(sim_dfs[[i]][[y]]$i, function(x){
        k = unique(edgelist$j[edgelist$i == x]) # neighbors of a node
        k2 = unique(edgelist$j[(edgelist$i != x) & (edgelist$i %in% k)]) # second degree neighbors
        h = sim_dfs[[i]][[y]]$i[sim_dfs[[i]][[y]]$adopt == 1 & sim_dfs[[i]][[y]]$i %in% k2] # those two-steps away that adopted
        prop = length(h)/length(k2)
        
        return(prop)
        
      })
      
      sim_dfs[[i]][[y]]$twodeg <- NA
      sim_dfs[[i]][[y]]$twodeg <- moment[[i]][[y]]
      covar[[i]][[y]] = cov(sim_dfs[[i]][[y]]$adopt, sim_dfs[[i]][[y]]$twodeg, use = "na.or.complete")
      
    }
    
    avg_moment12[[i]] <- mean(unlist(covar[[i]], recursive = FALSE))
    
  }
  
  
  return(avg_moment12)
  
  
}

### SIMULATED MOMENT 13 ### - Share of leaders that adopt
sim_moment13_fn <- function(sim_dfs, edgelist){
  
  condition1 <- vector(mode = "list", length = length(sim_dfs))
  condition2 <- vector(mode = "list", length = length(sim_dfs))
  prop_leader <- vector(mode = "list", length = length(sim_dfs))
  avg_moment13 <- vector(mode = "list", length = length(sim_dfs))
  
  
  for(i in 1:length(sim_dfs)){
    
    condition1[[i]] <- vector(mode = "list", length = length(sim_dfs[[i]]))
    condition2[[i]] <- vector(mode = "list", length = length(sim_dfs[[i]]))
    prop_leader[[i]] <- vector(mode = "list", length = length(sim_dfs[[i]]))
    
    for(x in 1:length(sim_dfs[[i]])){
      
      condition1[[i]][[x]] = length(sim_dfs[[i]][[x]]$i[sim_dfs[[i]][[x]]$leader == 1 & sim_dfs[[i]][[x]]$adopt == 1]) ## number of female adopters
      condition2[[i]][[x]] = length(sim_dfs[[i]][[x]]$i[sim_dfs[[i]][[x]]$leader == 1]) ## number of leaders in the village
      prop_leader[[i]][[x]] = condition1[[i]][[x]]/condition2[[i]][[x]]
      
    }
    
    avg_moment13[[i]] <- mean(unlist(prop_leader[[i]], recursive = FALSE), na.rm = TRUE)
    
  }
  
  return(avg_moment13)
  
}


### SIMULATED MOMENT 14 ### - Total degree of individuals who adopt

sim_moment14_fn <- function(sim_dfs, edgelist){
  
  condition1 <- vector(mode = "list", length = length(sim_dfs))
  avg_moment14 <- vector(mode = "list", length = length(sim_dfs))
  
  for(i in 1:length(sim_dfs)){
    
    condition1[[i]] <- vector(mode = "list", length = length(sim_dfs[[i]]))
    
    for(x in 1:length(sim_dfs[[i]])){
      
      condition1[[i]][[x]] = sum(sim_dfs[[i]][[x]]$degree[sim_dfs[[i]][[x]]$adopt == 1], na.rm = TRUE) ## number of female adopters
      
    }
    
    avg_moment14[[i]] <- mean(unlist(condition1[[i]], recursive = FALSE), na.rm = TRUE)
    
  }
  
  return(avg_moment14)
  
}

### SIMULATED MOMENT 15 ### - Avg fraction of neighbors that adopted
sim_moment15_fn <- function(sim_dfs, edgelist){
  avg_moment15 <- vector(mode = "list", length(sim_dfs))
  moment <- vector(mode = "list", length = length(sim_dfs))
  
  for(i in 1:length(sim_dfs)){
    moment[[i]] <- vector(mode = "list", length = length(sim_dfs[[i]]))
    
    for(y in 1:length(sim_dfs[[i]])){
      
      
      moment[[i]][[y]] = sapply(sim_dfs[[i]][[y]]$i, function(x){ # for each of those nodes
        k = unique(edgelist$j[edgelist$i == x]) # neighbors of that node
        h = sim_dfs[[i]][[y]]$i[sim_dfs[[i]][[y]]$adopt == 1 & sim_dfs[[i]][[y]]$i %in% k] # of those neighbors who adopt
        return(length(h)/length(k))
        
        
      })
      
      
    }
    
    avg_moment15[[i]] <- mean(unlist(moment[[i]], recursive = FALSE), na.rm = TRUE)
    
  }
  
  return(avg_moment15)
  
}




sim_funcs <- list(sim_moment1_fn,
                  sim_moment2_fn, 
                  sim_moment3_fn, 
                  sim_moment4_fn, 
                  sim_moment5_fn, 
                  sim_moment6_fn, 
                  sim_moment7_fn, 
                  sim_moment8_fn, 
                  sim_moment9_fn,
                  sim_moment10_fn, 
                  sim_moment11_fn, 
                  sim_moment12_fn, 
                  sim_moment13_fn, 
                  sim_moment14_fn, 
                  sim_moment15_fn) ## LIST OF MOMENT FUNCTIONS

