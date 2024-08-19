# STEP TWO - COLLECTING USERS --------------------------------------------------

### --------------------Pre-Process Orthogonal Hashtag List --------------------
# INPUTS: 
# open_path - file path of orthogonal hashtag object
# save_path - file path for saving processed hashtag object
#
# OUTPUTS: 
# processed orthogonal hashtags 


process_hash_fn <- function(open_path, save_path){
  load(open_path)
  orth_hash <- names(orthogonal_hashtags) # get names 
  
  ##Add '#' symbol 
  o_hash <- paste0("#", orth_hash)
  
  if(!is.null(save_path)){
    
    save(o_hash, file = save_path)
    
  }
  
}


### --------------------------- GET USERS ------------------------------------
# INPUTS: 
# open_path - file path of orthogonal hashtag object
# save_path - file path for saving all_users list
#
# OUTPUTS:
# list of all user_ids where each element is from a hashtag

user_collect_fn <- function(open_path, save_path, key){
  
  load(open_path)
  user_ids <- vector(mode = "list", length = length(o_hash))
  for(i in 1:length(o_hash)){
    tweets = try(rtweet::search_tweets(q = paste(o_hash[i], "-filter:verified OR filter:verified"), 
                               n = 18000, 
                               type = "recent", 
                               include_rts = TRUE, 
                               parse = TRUE, 
                               token = key, 
                               retryonratelimit = TRUE, 
                               lang = "en")) # tweets from each hashtag
    
    
    user_df <- attr(tweets, "users") # grab user name from tweet object
    
    if(length(user_df) == 0){
      user_ids[[i]] <- NA
    }else{
      user_ids[[i]] <- user_df$id_str ## if there is user info, grab the user_id 
    }
    
    rm(tweets) ## remove objects for reassignment
    rm(user_df)
    message(i)
    
  }
  
  save(user_ids, file = save_path)
  
}


### --------------------------- SAMPLE USERS  --------------------------------
# INPUTS: 
# open_path - file path of all_users list
# samp_size - (double) - specify sample size from hashtags
# seed - (integer) - set.seed for reproducibility 
# save_path - file path for saving sample list object
#
# OUTPUTS:
# list of sampled users from each hashtag

sample_users_fn <- function(open_path, samp_size, seed, save_path){
  
  load(open_path) # load all users list
  
  sample_user_list <- vector(mode = "list", length = length(user_ids))
  set.seed(seed)
  for(i in 1:length(user_ids)){
    sample_user_list[[i]] <- sample(unique(user_ids[[i]]), samp_size*length(unique(user_ids[[i]]))) ## take sample from each element
  }
  
  save(sample_user_list, file = save_path) # 10% sample of users, list
}


# 
# sample_user_list <- vector(mode = "list", length = length(user_ids))
# 
# for(i in 1:length(user_ids)){
#   sample_user_list[[i]] <- sample(unique(user_ids[[i]]), length(unique(user_ids[[i]]))*0.1) ## take sample from each element
# }



### --------------------------- GENERATE USER VECTOR -------------------------
# INPUTS: 
# open_path - file path of sample_users list
# save_path - file path for saving user_id_vec
# 
# OUTPUTS:
# vector of sampled users

user_vector_fn <- function(open_path, save_path){
  load(open_path) ## load sampled user list
  user_id_vec <- unlist(sample_user_list) # unlist to vector
  save(user_id_vec, file = save_path) # vector of users
  
}

### ----------------------- USER COLLECTION ALL TOGETHER -----------------------
# INPUTS: 
# paths - list of file paths for functions within
# samp_size - (double) - specify sample size for sampling
# seed - (integer) - set.seed for sampling
# 
# OUTPUTS:
# vector of sampled users

collect_users_fn <- function(paths, samp_size, seed, key){

  # load orthogonal hashtags <paths[1]>; save processed orthogonal hashtags <paths[2]>
  process_hash_fn(open_path = paths[1], save_path = paths[2]) # preprocess hashtags
  # # load processed hashtags <paths[2]>; save all users list <paths[3]>
  user_collect_fn(open_path = paths[2], save_path = paths[3], key) ## collect users
  # load all users list <paths[3]>; save sampled list of users <paths[4]>
  sample_users_fn(open_path = paths[3], samp_size = samp_size, seed = seed, save_path = paths[4]) ## create sample of users
  # load sampled list of users <paths[4]>; save sampled user vector <paths[5]>
  user_id_vec <- user_vector_fn(open_path = paths[4], save_path = paths[5]) ## create vector of sampled users

}
