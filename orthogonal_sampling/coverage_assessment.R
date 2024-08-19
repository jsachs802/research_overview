## Packages
library(lubridate)
library(boot)


### FILE MANAGEMENT 
## File management - set for hashtag focus
root <- "~/sampling_project/" # root (for easily moving entire project)
folder <- "Golf" # hashtag folder for storing data 
hash_oi <- "golf" # hashtag of interest
iters <- 100

### LOAD FILE PATHS 
source(file = paste0(root, "orthogonal_sampling_project/Paths/paths.R"), local = TRUE)

# LOAD ESTIMATION FUNCTIONS
source(file = paste0(root, "orthogonal_sampling_project/Functions/estimation.R"), local = TRUE)
### COVERAGE ASSESSMENT

# Coverage test
# run estimation 
seeds <- vector(mode = "list", length = iters)
estimate_objects <- vector(mode = "list", length = iters)
for(i in 68:iters){
  seeds[i] <- set.seed(sample(1:1000000, 1))
  estimate_objects[[i]] <- get_estimate_fn(paths = estimation_paths, iterations = 1000)
}

## Test coverage 
coverage <- vector(mode="numeric", length = iters)
for(i in 1:length(estimate_objects))
  if((estimate_objects[[i]][[4]] >= estimate_objects[[i]][[2]][1]) & (estimate_objects[[i]][[4]] <= estimate_objects[[i]][[2]][2])){
    coverage[i] = 1
  }else{
    coverage[i] = 0
  }


save(coverage, file = paste0(root, "orthogonal_sampling_project/", folder, "/Data/coverage.Rda"))
save(seeds, file = paste0(root, "orthogonal_sampling_project/", folder, "/Data/cov_seeds.Rda"))

