library(tidyverse)

############################# MOMENTS #########################################

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

# 2. EMPIRICAL MOMENTS ----------------------------------------------------

### MUST BE IN THE RIGHT ORDER!!! ### MUST MATCH SIMULATED MOMENTS !!!

## 2.1 EMPIRICAL MOMENT FUNCTIONS 

### EMPIRICAL MOMENT 1: Percentage of individuals who heard with no neighbors who heard
moment1_fn <- function(v){
  actual_heard = nodes_df$i[nodes_df$heard == 1 & nodes_df$village == v] # nodes who heard
  
  moment = sapply(actual_heard, function(x){ # for each of those nodes
    k = unique(edgelist$j[edgelist$i == x]) # neighbors of that node
    h = nodes_df$i[nodes_df$heard == 1 & nodes_df$i %in% k] # of those neighbors who heard
    if(length(h) == 0){
      return(1) # if none heard
    }else{
      return(0) # if at least one heard
    }
  })
  
  return(sum(moment)/length(moment)) 
  # sum of those with no neighbors who heard over total number who heard
  
}

## EMPIRICAL MOMENT 2: Covariance of hearing with share of second-degree neighbors that 
## heard 
moment2_fn <- function(v){
  
  vill_df = nodes_df[nodes_df$village == v, ]
  
  moment = sapply(vill_df$i, function(x){
    k = unique(edgelist$j[edgelist$i == x]) # neighbors of a node
    k2 = unique(edgelist$j[(edgelist$i != x) & (edgelist$i %in% k)]) # second degree neighbors
    h = nodes_df$i[nodes_df$heard == 1 & nodes_df$i %in% k2] # those two-steps away that heard
    prop = length(h)/length(k2)
    
    return(prop)
    
  })
  
  vill_df$twodeg <- NA
  vill_df$twodeg <- moment
  covar = cov(vill_df$heard, vill_df$twodeg, use = "na.or.complete")
  
  return(covar)
  
}

## EMPIRICAL MOMENT 3: Share of leaders that heard 
moment3_fn <- function(x){
  
  condition1 = length(nodes_df$i[nodes_df$leader == 1 & nodes_df$heard == 1 & nodes_df$village == x]) ## number of female adopters
  condition2 = length(nodes_df$i[nodes_df$leader == 1 & nodes_df$village == x]) ## number of leaders in the village
  prop_leader = condition1/condition2
  return(prop_leader)
}



## EMPIRICAL MOMENT 4:  Percentage of those who heard that were female
moment4_fn <- function(x){
  condition1 = length(nodes_df$i[nodes_df$female == 1 & nodes_df$heard == 1 & nodes_df$village == x]) ## number of female adopters
  condition2 = length(nodes_df$i[nodes_df$heard == 1 & nodes_df$village == x]) ## number of adoptees in the village
  prop_female = condition1/condition2
  return(prop_female)

}


## EMPIRICAL MOMENT 5: Percentage of individuals with no participating neighbors who heard 
moment5_fn <- function(v){
  actual_heard = nodes_df$i[nodes_df$heard == 1 & nodes_df$village == v] # nodes who heard
  
  moment = sapply(actual_heard, function(x){ # for each of those nodes
    k = unique(edgelist$j[edgelist$i == x]) # neighbors of that node
    h = nodes_df$i[nodes_df$adopt == 1 & nodes_df$i %in% k] # of those neighbors who adopted
    if(length(h) == 0){
      return(1) # if none heard
    }else{
      return(0) # if at least one heard
    }
  })
  
  return(sum(moment)/length(moment)) 
  # sum of those with no neighbors who heard over total number who heard
  
}


## EMPIRICAL MOMENT 6: Percentage of those who heard that were male
moment6_fn <- function(x){
  condition1 = length(nodes_df$i[nodes_df$female == 0 & nodes_df$heard == 1 & nodes_df$village == x]) ## number of female adopters
  condition2 = length(nodes_df$i[nodes_df$heard == 1 & nodes_df$village == x]) ## number of adoptees in the village
  prop_female = condition1/condition2
  return(prop_female)
  
}


##EMPIRICAL MOMENT 7: Total degree of individuals who heard 
moment7_fn <- function(x){
  
  total_deg = sum(nodes_df$degree[nodes_df$heard == 1 & nodes_df$village == x], na.rm = TRUE)
  return(total_deg)
  
}


##EMPIRICAL MOMENT 8: Average fraction of neighbors who heard 
moment8_fn <- function(v){
  actual_heard = nodes_df$i[nodes_df$village == v] # nodes who heard
  
  moment = sapply(actual_heard, function(x){ # for each of those nodes
    k = unique(edgelist$j[edgelist$i == x]) # neighbors of that node
    h = nodes_df$i[nodes_df$heard == 1 & nodes_df$i %in% k] # of those neighbors who heard
    frac = length(h)/length(k)
    return(frac)
  })
  
  return(mean(moment, na.rm = TRUE)) 
  # sum of those with no neighbors who heard over total number who heard
  
}


### EMPIRICAL MOMENT 9: Percentage of those who adopted that were male
moment9_fn <- function(x){
  condition1 = length(nodes_df$i[nodes_df$female == 0 & nodes_df$adopt == 1 & nodes_df$village == x]) ## number of female adopters
  condition2 = length(nodes_df$i[nodes_df$adopt == 1 & nodes_df$village == x]) ## number of adoptees in the village
  prop_female = condition1/condition2
  return(prop_female)
  
}


### EMPIRICAL MOMENT 10: Percentage of those who adopted that were female
moment10_fn <- function(x){
  condition1 = length(nodes_df$i[nodes_df$female == 1 & nodes_df$adopt == 1 & nodes_df$village == x]) ## number of female adopters
  condition2 = length(nodes_df$i[nodes_df$adopt == 1 & nodes_df$village == x]) ## number of adoptees in the village
  prop_female = condition1/condition2
  return(prop_female)
  
}


### EMPIRICAL MOMENT 11: Percentage of individuals who adopt with no neighbors who adopt 
moment11_fn <- function(v){
  actual_adopt = nodes_df$i[nodes_df$adopt == 1 & nodes_df$village == v] # nodes who heard
  
  moment = sapply(actual_adopt, function(x){ # for each of those nodes
    k = unique(edgelist$j[edgelist$i == x]) # neighbors of that node
    h = nodes_df$i[nodes_df$adopt == 1 & nodes_df$i %in% k] # of those neighbors who heard
    if(length(h) == 0){
      return(1) # if none heard
    }else{
      return(0) # if at least one heard
    }
  })
  
  return(sum(moment)/length(moment)) 
  # sum of those with no neighbors who heard over total number who heard
  
}


### EMPIRICAL MOMENT 12: Covariance of adoption with share of second-degree neighbors that adopt.  
moment12_fn <- function(v){
  
  vill_df = nodes_df[nodes_df$village == v, ]
  
  moment = sapply(vill_df$i, function(x){
    k = unique(edgelist$j[edgelist$i == x]) # neighbors of a node
    k2 = unique(edgelist$j[(edgelist$i != x) & (edgelist$i %in% k)]) # second degree neighbors
    h = nodes_df$i[nodes_df$adopt == 1 & nodes_df$i %in% k2] # those two-steps away that heard
    prop = length(h)/length(k2)
    
    return(prop)
    
  })
  
  vill_df$twodeg <- NA
  vill_df$twodeg <- moment
  covar = cov(vill_df$adopt, vill_df$twodeg, use = "na.or.complete")
  
  return(covar)
  
}


### EMPIRICAL MOMENT 13: Share of leaders that adopt. 
moment13_fn <- function(x){
  condition1 = length(nodes_df$i[nodes_df$leader == 1 & nodes_df$adopt == 1 & nodes_df$village == x]) ## number of female adopters
  condition2 = length(nodes_df$leader[nodes_df$leader == 1 & nodes_df$village == x]) ## number of leaders in the village
  prop_leader = condition1/condition2
  return(prop_leader)
}


### EMPIRICAL MOMENT 14: Total degree of individuals who adopt.
moment14_fn <- function(x){
  
  total_deg = sum(nodes_df$degree[nodes_df$adopt == 1 & nodes_df$village == x], na.rm = TRUE)
  return(total_deg)
  
}


### EMPIRICAL MOMENT 15: Average fraction of neighbors who adopt. 
moment15_fn <- function(v){
  actual_adopt = nodes_df$i[nodes_df$village == v] # nodes who heard
  
  moment = sapply(actual_adopt, function(x){ # for each of those nodes
    k = unique(edgelist$j[edgelist$i == x]) # neighbors of that node
    h = nodes_df$i[nodes_df$adopt == 1 & nodes_df$i %in% k] # of those neighbors who heard
    frac = length(h)/length(k)
    return(frac)
  })
  
  return(mean(moment, na.rm = TRUE)) 
  # sum of those with no neighbors who heard over total number who heard
  
}



## 2.2 EMPRICIAL MOMENTS GENERATING FUNCTION 
emp_moment_fn <- function(edgelist, nodes_df, villages){

  ## Initialize Matrix
  emp_mo <- matrix(data = NA, nrow = 15, ncol = length(villages))
  
  ### EMPIRICAL MOMENT 1 ### Percentage of individuals who heard with no neighbors who heard
  emp_mo[1,] <- sapply(villages, moment1_fn)
  
  ### EMPIRICAL MOMENT 2 ### Covariance of hearing with share of second-degree neighbors that heard
  emp_mo[2,] <- sapply(villages, moment2_fn)
  
  ### EMPIRICAL MOMENT 3 ### Share of leaders that heard 
  emp_mo[3,] <- sapply(villages, moment3_fn)
  
  ### EMPIRICAL MOMENT 4 ### Percentage of those who heard that were female
  emp_mo[4,] <- sapply(villages, moment4_fn)
  
  ### EMPIRICAL MOMENT 5 ### Percentage of individuals with no participating neighbors who heard 
  emp_mo[5,] <- sapply(villages, moment5_fn)
  
  ### EMPIRICAL MOMENT 6 ### Percentage of those who heard that were male
  emp_mo[6, ] <- sapply(villages, moment6_fn)
  
  ### EMPIRICAL MOMENT 7 ### Total degree of individuals that heard
  emp_mo[7, ] <- sapply(villages, moment7_fn)
  
  ### EMPIRICAL MOMENT 8 ### Average fraction of neighbors who heard
  emp_mo[8, ] <- sapply(villages, moment8_fn)
  
  ### EMPIRICAL MOMENT 9 ### Percentage of those who adopted that were male
  emp_mo[9, ] <- sapply(villages, moment9_fn)
  
  ### EMPIRICAL MOMENT 10 ### Percentage of those who adopted that were female
  emp_mo[10, ] <- sapply(villages, moment10_fn)
  
  ### EMPIRICAL MOMENT 11 ### Percentage of individuals who adopt with no neighbors who adopt 
  emp_mo[11, ] <- sapply(villages, moment11_fn)
  
  ### EMPIRICAL MOMENT 12 ### Covariance of adoption with share of second-degree neighbors that adopt.
  emp_mo[12, ] <- sapply(villages, moment12_fn)
  
  ### EMPIRICAL MOMENT 13 ### Share of leaders that adopt. 
  emp_mo[13, ] <- sapply(villages, moment13_fn)
  
  ### EMPIRICAL MOMENT 14 ### Total degree of individuals who adopt.
  emp_mo[14, ] <- sapply(villages, moment14_fn)
  
  ### EMPIRICAL MOMENT 15 ### Average fraction of neighbors who adopt. 
  emp_mo[15, ] <- sapply(villages, moment15_fn)
  
  
  ### OUTPUT ### 
  return(emp_mo) ## Matrix (15, 16): 15 moments (rows), 16 villages (cols)
  
}




## 2.3 CALCULATING EMPIRICAL MOMENTS 
empirical_moments <- emp_moment_fn(edgelist = edgelist, nodes_df = nodes_df, villages = villages)

dimnames(empirical_moments) <- list(1:15, 1:14)

empirical_moments

save(empirical_moments, file = "empirical_moments.Rda")

