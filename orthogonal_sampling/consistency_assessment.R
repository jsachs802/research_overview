### Test for Consistency 
library(tidyverse)
library(lubridate)
library(boot)


### FILE MANAGEMENT 
## File management - set for hashtag focus
root <- "#######" # root (for easily moving entire project)
folder <- "Golf" # hashtag folder for storing data 
hash_oi <- "golf" # hashtag of interest

fractions = c(0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1)


### LOAD FILE PATHS 
source(file = paste0(root, "Orthogonal Sampling Project/Paths/paths.R"), local = TRUE)

# LOAD ESTIMATION FUNCTIONS
source(file = paste0(root, "Orthogonal Sampling Project/Functions/estimation_result.R"), local = TRUE)
### COVERAGE ASSESSMENT

iters = 100
# seeds <- vector(mode = "list", length = length(fractions))
# seeds2 <- vector(mode = "list", length = length(iters))
# consistency_objects <- vector(mode = "list", length = length(fractions))
# means <- vector(mode = "numeric", length = length(fractions))
# avg_lower_ci <- vector(mode = "numeric", length = length(fractions))
# avg_upper_ci <- vector(mode = "numeric", length = length(fractions))
# est <- vector(mode = "list", length = length(fractions))
# for(i in 1:length(fractions)){
  # seeds<- set.seed(sample(1:1000000, 1))
  estimates <- vector(mode = "list", length = iters)
  est <- vector(mode = "numeric", length = iters)
  lower_ci <- vector(mode = "numeric", length = iters)
  upper_ci <- vector(mode = "numeric", length = iters)
  for(j in 16:iters){
    seeds2 <- set.seed(sample(1:1000000, 1))
    estimates[[j]] <- get_estimate_fn(paths = estimation_paths, iterations = 1000, p = 0.1)
    est[j] <- estimates[[j]][[1]]
    lower_ci[j] <- estimates[[j]][[2]][1]
    upper_ci[j] <- estimates[[j]][[2]][2]
    print(j)
  }
  # means[[i]] <- mean(est, na.rm = T)
  # avg_lower_ci[[i]] <- mean(lower_ci, na.rm = T)
  # avg_upper_ci[[i]] <- mean(upper_ci, na.rm = T)
  # consistency_objects[[i]] = list(means[[i]], avg_lower_ci[[i]], avg_upper_ci[[i]], fractions[i])
# }

est[1:20]
  ## Do relative error for each one 
  
  abs(estimate_objects[[4]] - mean(est[1:20]))/estimate_objects[[4]]
  
  est[1:15]

test <- est[1:20]

test

mean(abs(estimate_objects[[4]] - test)/estimate_objects[[4]])




save(coverage, file = paste0(root, "Orthogonal Sampling Project/", folder, "/Data/consistency_objects.Rda"))
save(seeds, file = paste0(root, "Orthogonal Sampling Project/", folder, "/Data/consistency_seeds.Rda"))

