simulator_fn <- function(vill = vill,
                         t = t,
                         vill_logit = vill_logit,
                         nodes_df = nodes_df,
                         edgelist = edgelist,
                         A_p,
                         NA_p){

  # A_p = 0.001
  # NA_p = 0.001
  
  # 2.1 Initial Setup of Variables Within Function ----------------------------------------------------
  
  village_nodes <- nodes_df[nodes_df$village == vill, ] %>% select(i, heard, adopt, age, female, income, edu, hasPhone, leader, attend, village, degree) ## village specific subset of nodes_df
  edgelist_model <- edgelist[edgelist$villageId %in% vill,] ## edges specific to village
  n <- length(village_nodes$i) ## number of nodes in village
  village_nodes_model <- village_nodes ## create a duplicate village nodes df that can variables added to it. 
  
  
  # 2.2 Initialize Objects for Diffusion Data --------------------------------------------------------------------------------------------
  
  # 2.2.1 Initialize Matrices for Diffusion Data ------------------------------------------------------
  
  infected <- matrix(c(rep(rep(FALSE, n), t)), nrow = n, ncol = t, byrow = FALSE, dimnames = list(c(village_nodes_model$i), c(1:t))) ## matrix of nodes infected
  transmitting <- matrix(c(rep(rep(FALSE, n), t)), nrow = n, ncol = t, byrow = FALSE, dimnames = list(c(village_nodes_model$i), c(1:t))) ## which nodes are going to transmit information 
  contagious <- matrix(c(rep(rep(FALSE, n), t)), nrow = n, ncol = t, byrow = FALSE, dimnames = list(c(village_nodes_model$i), c(1:t))) ## matrix of contagious 
  contagious_before <- matrix(c(rep(rep(FALSE, n), t)), nrow = n, ncol = t, byrow = FALSE, dimnames = list(c(village_nodes_model$i), c(1:t))) ## matrix of prior contagious nodes
  trans_p <- matrix(c(rep(rep(0, n), t)), nrow = n, ncol = t, byrow = FALSE, dimnames = list(c(village_nodes_model$i), c(1:t))) ## matrix of transmission probabilities for contagious adopters and non-adopters

  
  # 2.2.3 Initialize Output Objects  -------------------------------------------------------------------
  
  ## Adopted & Heard
  
  adopted <- vector(mode = "list", length = t) ## which nodes adopted
  heard <- vector(mode = "list", length = t) ## which nodes heard
  
  
  # 2.3 Generate Initial Conditions Data (Time Period 1 Outcomes) -------------------------------------
  
  susceptible <- vector(mode = "list", length = t) ## placeholder for condition for susceptible nodes
  sus_nodes <- vector(mode = "list", length = t) ## placeholder for susceptible nodes 
  sus_length <-  vector(mode = "list", length = t) ## placeholder for length of random vector (number of nodes susceptible)
  sus_cov <-  vector(mode = "list", length = t) ## placeholder for subset of covariates pertinent to susceptible nodes
  
  # 2.3.1 Initial Adoption --------------------------------------------------
  susceptible[[1]] <- village_nodes$attend == 1 ## initial attendees of meeting
  sus_nodes[[1]] <- village_nodes$i[susceptible[[1]]] ## names of nodes that are susceptible
  sus_length[[1]] <- length(sus_nodes[[1]]) ## number of nodes that are susceptible
  sus_cov[[1]] <- village_nodes[village_nodes$attend == 1,] ## subset of covariates of susceptible nodes
  infected[rownames(infected) %in% sus_nodes[[1]], 1:t] <- unname(runif(sus_length[[1]], 0, 1) < predict(vill_logit, newdata = sus_cov[[1]], type = "response")) ## initial choice to adopt using random number comparison
  
  
  # 2.3.2 Initial Contagious Nodes --------------------------------------------------------------------
  
  contagious[sus_nodes[[1]], 1:t] <- TRUE ## setting initial contagious to attendees
  
  # 2.3.3 Transmitting ----------------------------------------------------------------------------------
  
  ## Two Transmitting Probabilities: 
  # 1. CONTAGIOUS & ADOPT - A_p
  # 2. CONTAGIOUS & NO ADOPT - NA_p
  
  ## Initialize Objects for Transmitting 
  con_adopt <- vector(mode = "list", length = t) # placeholder for condition 1
  con_no_adopt <- vector(mode = "list", length = t) # placeholder for condition 2
  con_before <- vector(mode = "list", length = t) # placeholder for contagious in prior time period
  
  informed_nodes <- vector(mode = "list", length = t) # placeholder for neighboring nodes that have been informed 
  transmit_logic <- vector(mode = "list", length = t) # random number comparison that makes true/false transmit decision 
  transmit_nodes <- vector(mode = "list", length = t) # which nodes are deciding whether to transmit information
  transmit_decision <- vector(mode = "list", length = t) # true/false value for transmitting information to other nodes
  

  ## Conditions for transmitting for period 1
  con_adopt[[1]] <- (rownames(trans_p) %in% rownames(infected[infected[, 1] == TRUE, ])) & (rownames(trans_p) %in% rownames(contagious[contagious[, 1] == TRUE, ])) & !(rownames(trans_p) %in% rownames(contagious_before[contagious_before[ ,1] == TRUE, ])) ## contagious and adopted 
  con_no_adopt[[1]] <- (rownames(trans_p) %in% rownames(infected[infected[, 1] == FALSE, ])) & (rownames(trans_p) %in% rownames(contagious[contagious[, 1] == TRUE, ])) & !(rownames(trans_p) %in% rownames(contagious_before[contagious_before[ ,1] == TRUE, ])) ## contagious and no adoption
  
  ## Accounting for transmission probabilies for each node
  
  trans_p[con_adopt[[1]], 1] <- A_p # transmission probability if contagious AND adopted 
  trans_p[con_no_adopt[[1]], 1] <- NA_p # transmission probability if contagious and did NOT adopt
  
  # transmit_names <- vector(mode = "list", length = t) ### list of those able to transmit in period [[t]]
  transmit_list <- vector(mode = "list", length = t) ### list with all nodes getting information in period [[t]]
  
  
  transmit_function <- function(i){
    transmit_names = names(trans_p[trans_p[ , i] != 0, i])
    probs = unname(trans_p[trans_p[ , i] != 0, i])
    
    transmit_probs <- vector(mode = "list", length = length(transmit_names))
    for(x in 1:length(transmit_names)){
      transmit_probs[[x]] = rep(probs[x], length(edgelist_model$j[edgelist_model$i == transmit_names[x]])) ## repeat probability of transfer for each neighbor
      names(transmit_probs[[x]]) = edgelist_model$j[edgelist_model$i == transmit_names[x]]
    }
    
    transmit_probs = unlist(transmit_probs)
    
    transmit_probs
    transmit_probs = transmit_probs[unique(names(transmit_probs))] ## names of potentially susceptible
    
    new_trans = transmit_probs[transmit_probs > runif(length(transmit_probs), 0, 1)]
    
    transmit_list = new_trans ## creates vector of T/F for newly susceptible
    
    if(length(transmit_list[!(names(transmit_list) %in% rownames(contagious[contagious[ , i] == TRUE, ]))]) > 0){
      
      transmit_list = transmit_list[!(names(transmit_list) %in% rownames(contagious[contagious[ , i] == TRUE, ]))] ## remove formerly contagious 
    }else{
      
      transmit_list = NA
    }
    
    return(transmit_list)
    
  }
  
  ### LOOK AT THIS AGAIN #### 
  ### TRANSMIT FUNCTION  
  if(sum(trans_p[trans_p[ , 1] != 0, 1] > 0) > 1){
    
      transmit_list[[1]] <- transmit_function(1)

  }else{
    
    transmit_list[[1]] <- NA
  }
  
 
  
  ## Accounting for node who were contagious in period 1
  con_before[[1]] <- rownames(contagious_before) %in% rownames(contagious[contagious[ , 1] == TRUE, ]) ## contagious before name index 
  contagious_before[unlist(con_before[[1]]), 1:t] <- TRUE
  
 
  # 2.3.6 Initial Outputs ------------------------------------------------------------------------------------
  if(is.null(rownames(infected[infected[ ,1] == TRUE, ]))){
    adopted[[1]] = 0
    
  }else{
    
    adopted[[1]] = rownames(infected[infected[ ,1] == TRUE, ])
    
  }
  
  if(is.null(rownames(contagious[contagious[ ,1] == TRUE, ]))){
    
    heard[[1]] = 0
    
  }else{
    
    heard[[1]] = rownames(contagious[contagious[ ,1] == TRUE, ])
    
  }
  
  # adopted[[1]] = rownames(infected[infected[ ,1] == TRUE, ]) ## nodes who adopted in period 1
  # heard[[1]] = rownames(contagious[contagious[ ,1] == TRUE, ]) ## nodes who heard in period 1
  
  # 2.3.7 Logical Placeholders for For-Loop ---------------------------------
  
  if1_logic <- vector(mode = "list", length = t)
  if2_logic <- vector(mode = "list", length = t)
  if3_logic <- vector(mode = "list", length = t)
  
  # 2.4 Diffusion Loop for T=2 to T=t --------------------------------------------------------------------------------------------------------------------------------
  
  # 2.4.1 Initializing Objects for Loop Diffusion Data ----------------------
  
  for(i in 2:t){
    
    ## Logical for whether transmit list has any elements
    if1_logic[[i]] <- (length(transmit_list[[i-1]]) > 1)
  
    if(if1_logic[[i]]){ ## if true 
      
      ## CHANGE INFORMED NODES 
      contagious[rownames(contagious) %in% names(transmit_list[[i-1]]), i:t] <- TRUE ## newly contagious nodes, susceptible for adoption (or infection) in period 2 to t
      
    } ### THIS IS WHERE THE INFORMATION IS TRANSFERED 
    
  
    ## ADOPTION
    # Conditions for nodes susceptible of adoption 
    susceptible[[i]] <- (village_nodes_model$i %in% rownames(contagious[contagious[ , i] == TRUE, i:t])) & (!village_nodes_model$i %in% rownames(contagious[contagious[, i-1] == TRUE, ]))
  
    # Set up variables for suceptible nodes 
    sus_nodes[[i]] <- village_nodes_model$i[susceptible[[i]]]
    sus_length[[i]] <-  length(sus_nodes[[i]]) ## number of susceptible nodes
    sus_cov[[i]] <-  village_nodes_model[susceptible[[i]], ] ## subset of covariates for susceptible nodes
    
    # Decision to adopt
    if2_logic[[i]] <- sum(susceptible[[i]]) >= 1 ## if there is at least one newly susceptible individual
  
    infected[rownames(infected) %in% sus_nodes[[i]], ]
    
    if(if2_logic[[i]]){ ## if true 
      infected[rownames(infected) %in% sus_nodes[[i]], ] <- unname(runif(sus_length[[i]], 0, 1) < predict(vill_logit, newdata = sus_cov[[i]], type = "response"))
    }
  
  
    ## OUTPUTS 
    
    
    ## ADOPTED
    if(is.null(rownames(infected[infected[ ,i] == TRUE, ]))){
      
      adopted[[i]] = NA
      
    }else{
      
      adopted[[i]] = rownames(infected[infected[ ,i] == TRUE, ])
      
    }
    
    # HEARD
    if(is.null(rownames(contagious[contagious[ ,i] == TRUE, ]))){
      
      heard[[i]] = NA
      
    }else{
      
      heard[[i]] = rownames(contagious[contagious[ ,i] == TRUE, ])
      
    }
    
    # adopted[[i]] = rownames(infected[infected[, i] == TRUE, ]) ## aggregate list of nodes who have heard ## THESE SHOULD BE UNLIST INFECTED LIST 
    # heard[[i]] = rownames(contagious[contagious[, i] == TRUE, ]) ## keeps track of cumulative adoption ## UNLIST CONTAGIOUS LIST 
    # 
    
    ## TRANSMITTING
    ## Conditions for transmissions probabilites for each node
    
    con_adopt[[i]] <- (rownames(trans_p) %in% rownames(infected[infected[, i] == TRUE, ])) & (rownames(trans_p) %in% rownames(contagious[contagious[, i] == TRUE, ])) & !(rownames(trans_p) %in% rownames(contagious_before[contagious_before[ , i] == TRUE, ])) ## contagious and adopted 
    con_no_adopt[[i]] <- (rownames(trans_p) %in% rownames(infected[infected[, i] == FALSE, ])) & (rownames(trans_p) %in% rownames(contagious[contagious[, i] == TRUE, ])) & !(rownames(trans_p) %in% rownames(contagious_before[contagious_before[ , i] == TRUE, ])) ## contagious and no adoption
    
    
    ## Assigning transmission probabilities to each node
    trans_p[con_adopt[[i]], i] <- A_p # transmission probability if contagious AND adopted 
    trans_p[con_no_adopt[[i]], i] <- NA_p # transmission probability if contagious and did not adopt
    
    
    ### TRANSMIT FUNCTION
    if(sum(trans_p[trans_p[ , i] != 0, i] > 0) > 1){
      
      transmit_list[[i]] <- transmit_function(i)
      
    }else{
      
      transmit_list[[i]] <- NA
    }
    
    
    # Update contagious_before
    con_before[[i]] <- rownames(contagious_before) %in% rownames(contagious[contagious[ , i] == TRUE, ]) # Updating list of nodes who are contagious and have decided to adopt or not 
    contagious_before[con_before[[i]], i:t] <- TRUE  # updating contagious_before so that those who choose not to adopt are not run again. 
    
    
  
   
    
  }
  
  
  # 2.5 Function Outputs -------------------------------------------------------------------------------------------------------------------------------------------------
  
  ### REPLACE NULL VALUES IN ADOPTED AND HEARD with 0's
  

  return(moment_df_fn(a = adopted, ear = heard, nodes = nodes_df))
  
  
  ################################### END OF FUNCTION ############################  
}


### OUTPUT FUNCTIONS FOR SIMULATOR 
moment_df_fn <- function(a = adopted, ear = heard, nodes = nodes_df){
  
  ad <- unique(unlist(a))
  h <- unique(unlist(ear))
  sim_nodes_df <- nodes[nodes$village == vill, ] %>% select(i, female, heard, adopt, degree, leader)
  
  ## Simulated Adopters
  sim_nodes_df$adopt <- NA
  sim_nodes_df$adopt[sim_nodes_df$i %in% ad] <- 1
  sim_nodes_df$adopt[!(sim_nodes_df$i %in% ad)] <- 0
  
  ## Simulated Hearers 
  sim_nodes_df$heard <- NA
  sim_nodes_df$heard[sim_nodes_df$i %in% h] <- 1
  sim_nodes_df$heard[!(sim_nodes_df$i %in% h)] <- 0
  
  return(sim_nodes_df)
  
}
