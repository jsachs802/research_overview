#### SAMPLING APPROACH (ALL STEPS), ESTIMATION, AND VISUALIZATION

## File management - set for hashtag focus
root <- "#####" # root (for easily moving entire project)
folder <- "Work" # hashtag folder for storing data 
hash_oi <- "work" # hashtag of interest


## Libraries 
## MIGHT WANT TO CALL THESE AS NEEDED
library(tidyverse)
library(text2vec)
library(lexicon)
library(rtweet)
library(httpuv)
library(boot)

### SPECIFICATIONS
round <- 2 ## rounding level on cosine similarity
sample_size = 0.1 ## sample sizes for user and follower samples
amount_to_collect = 0.05 # Proportion of follower chunks to try request
chunk_s = 100

### LOAD FILE PATHS 
source(file = paste0(root, "/orthogonal_sampling_project/paths.R"), local = TRUE)

### LOAD STATUS UPDATE FUNCTION 
source(file = paste0(root, "/orthogonal_sampling_project/status_update.R"), local = TRUE)

### TWITTER AUTHENTICATION 
# Load functions 
source(file = paste0(root, "/orthogonal_sampling_project/authentication.R"), local = TRUE)
# Run authentication 
auth <- auth_fn(auth_path)

# GROUND TRUTH -----------------------------------------------------------------
# Load functions 
source(file = paste0(root, "/orthogonal_sampling_project/ground_truth.R"), local = TRUE)
# Run ground truth
get_ground_truth_fn(hash = paste0("#", hash_oi), save_path = gt_path)

# COMPLETE
update_status_fn(status = "validated and collected ground truth sample", root = root, name = folder) 

# STEP ONE - FORMULATE ORTHOGONAL HASHTAGS -------------------------------------
# Load functions 
source(file = paste0(root, "/orthogonal_sampling_project/Functions/step_one_orth_hashtags.R"), local = TRUE)
# Run step one
orthog_hash_fn(paths = embedding_paths, hash = hash_oi, rounding = round)

# COMPLETE
update_status_fn(status = "step one complete: formulated orthogonal hashtag object", root = root, name = folder)


# STEP TWO - COLLECT USERS FROM ORTHOGONAL HASHTAGS ----------------------------
# Load functions 
source(file = paste0(root, "/orthogonal_sampling_project/step_two_collect_users.R"), local = TRUE)
# Run step two
user_seed <- sample(0000000:9999999, 1) ## set seed function
collect_users_fn(paths = user_collect_paths, samp_size = sample_size, seed = user_seed, key = auth)

# COMPLETE
update_status_fn(status = "step two complete: collected users", root = root, name = folder)


# STEP THREE - COLLECT FOLLOWERS FROM USERS ------------------------------------
# Load functions
source(file = paste0(root, "/orthogonal_sampling_project/step_three_collect_folls.R"), local = TRUE)
# Run step three
follower_seed <- sample(0000000:9999999, 1) ## set seed function
collect_followers_fn(paths = follower_collect_paths, samp_size = sample_size, seed = follower_seed)

# COMPLETE
update_status_fn(status = "step three complete: collected followers and created 10% sample from sample of users", root = root, name = folder)


# STEP FOUR - COLLECT TWEETS FROM FOLLOWERS ------------------------------------
# Load functions 
source(file = paste0(root, "/orthogonal_sampling_project/step_four_collect_tweets.R"), local = TRUE)
# Run step four
collect_tweets_fn(paths = collect_tweets_paths, chunk_size = chunk_s, vol = 3200, amount = amount_to_collect)

# COMPLETE
update_status_fn(status = "step four complete: collected tweets from 10% sample of followers", root = root, name = folder)


# DATA WRANGLING ---------------------------------------------------------------
# Load functions 
source(file = paste0(root, "/orthogonal_sampling_project/data_wrangling.R"), local = TRUE)
# Run data wrangling
hash_format <- paste0("^", hash_oi, "$")
data_wrang_fn(paths = wrangling_paths, ht = hash_format)

# COMPLETE
update_status_fn(status = "primary dataframe created from list of collect tweet chunks: ready for estimation", root = root, name = folder)


# ESTIMATION -------------------------------------------------------------------
# Load functions 
source(file = paste0(root, "/orthogonal_sampling_project/estimation.R"), local = TRUE)
# run estimation 
estimate_objects <- get_estimate_fn(paths = estimation_paths, iterations = 1000)

# COMPLETE 
update_status_fn(status = "Esimate generated", root = root, name = folder)

# VISUALIZATION ----------------------------------------------------------------
source(file = paste0(root, "/orthogonal_sampling_project/visualization.R"), local = TRUE)
visual <- make_viz_fn(paths = visual_paths, name = folder)
save(visual, file = "#####.Rda")

# COMPLETE
update_status_fn(status = "Visualization generated", root = root, name = folder)



