# STEP THREE - COLLECTING FOLLOWERS --------------------------------------------


### --------------------------- GET FOLLOWERS ---------------------------------
# INPUTS: 
# open_path - file path for user_id_vec - vector of user_ids
# save_path - file path for saving list of followers from user_ids
# 
# OUTPUTS:
# list of followers - each element is a user

follower_collect_fn <- function(open_path, save_path){
  load(open_path)
  follower_list <- vector(mode = "list", length = length(user_id_vec))
  for(i in 1:length(user_id_vec)){
    follower_list[[i]] <- try(get_followers(user_id_vec[i], n = 75000, retryonratelimit = TRUE, token = auth)) # collect followers
    message(i)
  } 
  
  save(follower_list, file = save_path)
  
}



### --------------------------- SAMPLE FOLLOWERS ------------------------------
# INPUTS: 
# open_path - file path for loading all follower list
# samp_size - (double) - specify sample size for sampling
# seed - set.seed for sampling reproducibility
# save_path - file path for saving list of sampled followers
# 
# 
# OUTPUTS:
# list of sampled followers


sample_followers_fn <- function(open_path, samp_size, seed, save_path){
  load(open_path)
  sample_follower_list <- vector(mode = "list", length = length(follower_list))
  set.seed(seed)
  for(i in 1:length(follower_list)){
    
    sample_follower_list[[i]] <- try(sample(unique(follower_list[[i]]$from_id), samp_size*length(unique(follower_list[[i]]$from_id)))) # sample followers
    
  }
  
  samp_follower_list <- sample_follower_list[lapply(sample_follower_list,length)>0] ## remove any empty elements
  save(samp_follower_list, file = save_path)
  
}


### ------------------- FOLLOWER COLLECTION ALL TOGETHER -----------------------
# INPUTS: 
# paths - list of file paths for collecting followers
# samp_size - (double) - specify sample size for sampling
# seed - set.seed for sampling reproducibility
# 
# OUTPUTS:
# list of sampled followers

collect_followers_fn <- function(paths, samp_size, seed){
  
  # # load user_id_vec <paths[1]>; save all followers list <paths[2]>
  follower_collect_fn(open_path = paths[1], save_path = paths[2]) # collect followers
  # 
  # load all followers list <paths[2]>; save sampled followers list <paths[3]>
  sample_followers_fn(open_path = paths[2], samp_size = samp_size, seed = seed, save_path = paths[3]) # sample followers
  
}