############################### MOMENT EVALUATION FUNCTION ######################

moment_select_fn <- function(vill, empirical_moments){
  
  vill_emp = empirical_moments[, which(villages == vill)]
  moment_sel = vill_emp[vill_emp > 0]
  moment_sel = as.numeric(names(moment_sel))
  
  return(moment_sel)
  
} ###  FUNCTION TO SELECT MOMENTS


moment_gen_fn <- function(sim_funcs, sim_dfs, moment_sel, edgelist){
  
  avg_moments = moment_sel %>% map(~sim_funcs[[.x]](sim_dfs = sim_dfs, edgelist = edgelist)) 
  sim_mo = matrix(nrow = length(avg_moments), ncol = length(sim_dfs)) 
  
  for(i in 1:length(avg_moments)){
    for(j in 1:length(avg_moments[[1]])){
      
      sim_mo[i, j] = avg_moments[[i]][[j]]
      
    }
  }
  
  dimnames(sim_mo) <- list(moment_sel, 1:length(avg_moments[[1]]))
  return(sim_mo)
  
} ### MOMENT GENERATING FUNCTION 



### NEED TO CREATE COMBINATIONS OF 6
moment_grid_fn <- function(moment_sel){
  moment_grid = combn(moment_sel, n_moments)
  return(moment_grid)
  
} ### POSSIBLE MOMENT COMBINATIONS FUNCTION




criterion_fn <- function(.x, vill, villages,
                         sim_moments_mat, 
                         empirical_moments, 
                         grid, sim_dfs, 
                         n_moments, 
                         moment_grid, 
                         moment_sel){
  
  ## 1.2 SETUP OF OTHER OBJECTS 
  
  ### EMPIRICAL MOMENT VECTOR FOR VILLAGE 
  emp_mat = as.matrix(empirical_moments[, which(villages == vill)]) 
  emp_mat = emp_mat[c(moment_grid[, .x])]
  ## empirical moments vector for a particular village
  
  ### LIST OF SIMULATED MOMENT VECTORS FOR PARAMETER COMBOS 
  sim_mat_list <- vector(mode = "list", length = length(sim_dfs))
  # Initialize matrix list
  for(i in 1:length(sim_dfs)){
    sim_mat_list[[i]] = as.matrix(sim_moments_mat[(rownames(sim_moments_mat) %in% moment_grid[, .x]), i]) 
    ## simulated moments vector for a particular parameter combination
  }
  
  
  ### 2. ERROR VECTOR 
  error_vec_list <- vector(mode = "list", length = length(sim_dfs))
  for(i in 1:length(sim_dfs)){
    error_vec_list[[i]] <- (sim_mat_list[[i]] - emp_mat)/emp_mat 
  } 
  ## element-wise error between data and model (percentage change) 
  ## for a particular village across a set of parameter combinations 
  
  
  ## 3. TWO STEP VARIANCE COVARIANCE ESTIMATOR OF W 
  
  ### 3.1 STEP ONE: IDENTITY MATRIX 
  I = diag(n_moments) ## (M, M) Identity Matrix: M = num of moments
  
  
  
  ## Initialize list of error estimates 
  step1 <- vector(mode = "list", length = length(sim_dfs))
  
  ## Initialize list for COV Matrix of Moment Error Vector
  omega <- vector(mode = "list", length = length(sim_dfs)) 
  
  ## Initialize list for weighting matrix 
  w_hat <- vector(mode = "list", length = length(sim_dfs))
  
  ## Initialize list of step 2 error estimates
  step2 <- vector(mode = "list", length = length(sim_dfs))
  
  
  for(i in 1:length(sim_dfs)){
    ### 3.2 STEP ONE: SUM OF SQUARED ERROR WITH I MATRIX 
    step1[[i]] <- t(error_vec_list[[i]])%*%I%*%error_vec_list[[i]]
    
    
    ### 3.4 STEP TWO: ESTIMATE VARIANCE COVARIANCE MATRIX OF MOMENT ERROR VECTOR
    omega[[i]] = error_vec_list[[i]]%*%t(error_vec_list[[i]])/n_moments
    
    ### 3.5 STEP TWO: OPTIMAL WEIGHTING IS INVERSE OF VAR-COVAR MATRIX
    w_hat[[i]] = pseudoinverse(omega[[i]]) 
    ## Using pseudo-inverse calculated by SVD because matrix is not conditioned for 
    ## inverse solution
    
    ### 3.6 STEP TWO: APPLY OPTIMAL WEIGHTING
    step2[[i]] <- t(error_vec_list[[i]])%*%w_hat[[i]]%*%error_vec_list[[i]]
    ## Generate squared error estimates for each parameter combination with w_hat 
    ## as weighting matrix instead of the identity
  }
  ## Generate squared error estimates for each parameter combination
  

  ###### PROBLEM ######
  
  # ### 3.3 STEP ONE: FIND MINIMUM 
  # min = which.min(as.matrix(unlist(step1)))
  
#   omega = error_vec_list[[min]]%*%t(error_vec_list[[min]])/n_moments
  
  ### 3.5 STEP TWO: OPTIMAL WEIGHTING IS INVERSE OF VAR-COVAR MATRIX
  # w_hat = pseudoinverse(omega) 
  # ## Using pseudo-inverse calculated by SVD because matrix is not conditioned for 
  # ## inverse solution
  # 
  # ### 3.6 STEP TWO: APPLY OPTIMAL WEIGHTING
  # step2 <- vector(mode = "list", length = length(sim_dfs))
  # initialize list of error estimates 
  
  # for(i in 1:length(sim_dfs)){
  #   step2[[i]] <- t(error_vec_list[[i]])%*%w_hat%*%error_vec_list[[i]]
  # }
  ## Generate squared error estimates for each parameter combination with w_hat 
  ## as weighting matrix instead of the identity
  
  min2 = which.min(as.matrix(unlist(step2))) ## locate minimum in simulated data
  
  optimal_params = grid[min2, ] ## identify optimal parameter pair
  
  return(c(min(as.matrix(unlist(step2))), optimal_params, min2))
  
  
} ### CRITERION FUNCTION

validation_fn <- function(.x, sim_dfs, critical_values, nodes_df, vill){
  
  avg_adpt <- vector(mode = "list", length = length(sim_dfs[[critical_values[[.x]][[4]]]])) 
  avg_hrd <- vector(mode = "list", length = length(sim_dfs[[critical_values[[.x]][[4]]]]))
  
  for(i in 1:length(sim_dfs[[critical_values[[.x]][[4]]]])){
    
    avg_adpt[[i]] <-  sum(sim_dfs[[critical_values[[.x]][[4]]]][[i]]$adopt) ## Simulated 
    ## Adoption 
    
    avg_hrd[[i]] <- sum(sim_dfs[[critical_values[[.x]][[4]]]][[i]]$heard) ## Simulated 
    ## Heard
    
  }
  
  average_a = mean(unlist(avg_adpt), na.rm = TRUE) ## Average adoption across 
  ## simulations
  average_h = mean(unlist(avg_hrd), na.rm = TRUE) ## Average heard across 
  ## simulations 
  
  actual_a = sum(nodes_df$adopt[nodes_df$village == vill]) ## Actual Adoption 
  actual_h = sum(nodes_df$heard[nodes_df$village == vill]) ## Actual Heard 
  
  tib = tibble(sim_adopt_avg = average_a,
               actual_adopt = actual_a,
               sim_heard_avg = average_h, 
               actual_heard = actual_h)
  
  return(tib)
  
} ### VALIDATION FUNCTION 

val_qual_fn <- function(.x, val_list){
  
  adopt_diff = abs(val_list[[.x]]$sim_adopt_avg - val_list[[.x]]$actual_adopt) ## absolute difference between simulated adopt and actual adopt
  heard_diff = abs(val_list[[.x]]$sim_heard_avg - val_list[[.x]]$actual_heard) ## absolute difference between simulated heard and actual heard
  comb_diff = adopt_diff + heard_diff
  
} ### VALIDATION QUALITY FUNCTION 

master_moment_fn <- function(vill, villages, empirical_moments, sim_dfs, nodes_df, edgelist, sim_funcs, grid, n_moments){
  
  ### REMOVE SIMULATION FAILURES 
  sim_dfs <- remove_error_fn(sim_dfs = sim_dfs)
  
  ### SELECT MOMENTS
  moment_sel = moment_select_fn(vill = vill, empirical_moments = empirical_moments)
  
  ## CALCULATE MOMENTS
  sim_moments_mat = moment_gen_fn(sim_funcs = sim_funcs, sim_dfs = sim_dfs, moment_sel = moment_sel, edgelist = edgelist)
  
  ### GENERATE MOMENT COMBINTION GRID
  moment_grid = moment_grid_fn(moment_sel)
  
  ### CALCULATE CRITERION VALUES OF EACH MOMENT COMBINATION ### 
  critical_values = 1:ncol(moment_grid) %>% map(~criterion_fn(.x, 
                                                              vill = vill, 
                                                              villages = villages, 
                                                              sim_moments_mat = sim_moments_mat, 
                                                              empirical_moments = empirical_moments, 
                                                              grid = grid, 
                                                              sim_dfs = sim_dfs, 
                                                              n_moments = n_moments, 
                                                              moment_grid = moment_grid, 
                                                              moment_sel = moment_sel))
  
  ## VALIDATE EACH CRITERION VALUES FOR EACH MOMENT COMBINATION 
  val_list = 1:ncol(moment_grid) %>% map(~validation_fn(.x, sim_dfs = sim_dfs, critical_values = critical_values, nodes_df = nodes_df, vill = vill))
  
  ### CALCULATE VALIDATION QUALITY
  val_qual_list = 1:ncol(moment_grid) %>% map(~val_qual_fn(.x, val_list = val_list))
  
  ## OUTPUT OBJECTS 
  best_val_index = which.min(val_qual_list) ## index for finding best moment combination outputs 
  best_val_diff = val_qual_list[[best_val_index]] ## best validation quality result
  best_val_tib = val_list[[best_val_index]] ## tibble row of simulated and actual adoption and heard results
  best_mo_comb = moment_grid[, best_val_index] ## best combination of moments
  crit_vals = critical_values[[best_val_index]] ## critical values from best validation
  
  return(c(best_val_index, best_val_diff, best_val_tib, best_mo_comb, crit_vals))
  
}



