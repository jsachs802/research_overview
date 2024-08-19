#### FUNCTIONS FOR ORTHOGONAL SAMPLING APPROACH 

# AUTHENTICATION  -------------------------------------------------------------
###  --------------------- Authenticate Twitter Credentials -------------------
# INPUTS:
# path - (character) - file path for twitter bearer token 
#
# OUTPUTS:
# auth - authentication object


auth_fn <- function(path){
  ## Authentication
  source(file = path, local = TRUE) # load credentials 
  ## bearer token
  return(rtweet::rtweet_app(bearer_token)) # initialize credentials
}


# GROUND TRUTH  ----------------------------------------------------------------

### ---------------------- Check Validity of Ground Truth ----------------------
grnd_trth_fn <- function(hash){
  
  a <- search_tweets(paste(hash, "-filter:verified OR filter:verified"), 
                     n = 10000000, 
                     type = "recent", 
                     include_rts = TRUE, 
                     parse = TRUE, 
                     token = auth, 
                     retryonratelimit = TRUE, 
                     lang = "en")
  b <- search_tweets(paste(hash, "-filter:verified OR filter:verified"), 
                     n = 10000000, 
                     type = "recent", 
                     include_rts = TRUE, 
                     parse = TRUE, 
                     token = auth, 
                     retryonratelimit = TRUE, lang = "en")
  
  b <- b %>% filter(created_at <= range(a$created_at)[2])
  a <- a %>% filter(created_at >= range(b$created_at)[1])
  
  diff <- length(setdiff(a$id_str, b$id_str))
  
  if(diff == 0){
    
    return(a)
  }else{
    return(a)
    message("Ground truth not verified.")
  }
  
}

### ------------------------- Save Ground Truth -------------------------------

get_ground_truth_fn <- function(hash, save_path = gt_path){
  
  ground_truth <- grnd_trth_fn(hash = hash) ### verify if we can get ground truth
  
  if(!is.null(ground_truth)){
    save(ground_truth, file = save_path)
  }else{
    message("Ground truth not verified.")
  }
}



# STEP ONE - FORMULATE ORTHOGONAL HASHTAGS ------------------------------------

### --------------------------Load and Format Embedding Space ------------------
# INPUTS: 
# open_path - file path to open pre-trained embedding space
#
# OUTPUTS: 
# pre-processed embedding space (matrix)

embed_process_fn <- function(open_path = embed_path){
  
  twit_embed <- data.table::fread(open_path) # Load pre-trained embedding space
  twit_mat <- as.matrix(twit_embed[, 2:201]) ## convert to matrix from dataframe, the first column contains the words
  dimnames(twit_mat) <- list(twit_embed$V1, 1:200) ## apply rownames # Uses the first column (words) as rownames 
  
  selected_rows <- stringr::str_extract(rownames(twit_mat), pattern = "[A-Z|a-z|0-9]+") ### keep only english alphabet letters and numbers
  selected_rows <- selected_rows[!is.na(selected_rows)] ## remove NAs
  twit_mat2 <- twit_mat[rownames(twit_mat) %in% selected_rows, ] ## subset embedding space to subset of words
  
  return(twit_mat2)
  
}


### -------------------- Load and Format English Dictionary ---------------------
# INPUTS: 
# open_path = file path to slang dictionary
#
# OUTPUTS: 
# dictionary (character vector) of english and slang terms for language subsetting


dic_fn <- function(open_path = dictionary_path){
  
  load(open_path) ### Load slang dictionary
  dic <- c(lexicon::grady_augmented, slang_dictionary)
  
  return(dic)
}


### --------------------- Create Orthogonal Hashtag List -----------------------
# INPUTS: 
# hashtag - (character) - hashtag of interest
# embed - (matrix) embedding space matrix 
# rounding - (integer) specification for rounding 
# dic - (character vector) - dictionary for subsetting language
#
# OUTPUTS:
# orthogonal hashtag object - (named list) - names: hashtags, values: cosine similarity


orthog_fn <- function(hashtag, embed, rounding = 2, dic){
  
  hash_mat <- embed[rownames(embed) == hashtag, ] ## create cue matrix
  hasht <- t(hash_mat) # transpose cue matrix 
  dimnames(hasht) <- list(hashtag, 1:ncol(embed)) # add dimension names to cue matrix
  
  cue_sims <- text2vec::sim2(hasht, embed, method = "cosine") ## finds cosine similarity 
  
  round_zeros <- which(round(cue_sims, digits = rounding) == 0, arr.ind = T, useNames = T) ## finds words that have close to zero similarity
  ## With rounding = 2, counts anything below 0.005 and above -0.005 as close enough to zero 
  
  orthogs <- cue_sims[1, c(round_zeros[, 2])]  ## creates vector of orthogonal words
  
  grady_orthogs <- orthogs[names(orthogs) %in% dic] ## subsets those words to English words in Grady's Augmented Dictionary 
  
  return(grady_orthogs)
  
}


### ------------- Function for All Steps (Orthogonal Hashtags) -----------------
# INPUTS:
# hash - (character) - hashtag of interest
# path - (character) - file path to save object
# rounding - (integer) specification for rounding 
#
# OUTPUTS: 
# orthogonal hashtag object - (named list) - names: hashtags, values: cosine similarity


orthog_hash_fn <- function(paths, hash, rounding){
  
  twit_mat <- embed_process_fn(paths[1]) # Load and format embedding space <paths[1]>
  
  dict <- dic_fn(paths[2]) # Load and format dictionary <paths[2]>
  
  # Create orthogonal hashtag list
  orthogonal_hashtags <- orthog_fn(hashtag = hash, embed = twit_mat, rounding = 2, dic = dict)
  
  save(orthogonal_hashtags, file = paths[3]) # Save orthogonal hashtags list <paths[3]>

}


# STEP TWO - COLLECTING USERS --------------------------------------------------

### --------------------Pre-Process Orthogonal Hashtag List --------------------
# INPUTS: 
# open_path - file path of orthogonal hashtag object
# save_path - file path for saving processed hashtag object
#
# OUTPUTS: 
# processed orthogonal hashtags 


process_hash_fn <- function(open_path = orthog_path, save_path = hashtag_path){
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

user_collect_fn <- function(open_path, save_path){
  
  load(open_path)
  user_ids <- vector(mode = "list", length = length(o_hash))
  for(i in 1:length(o_hash)){
    tweets = try(search_tweets(paste(o_hash[i], "-filter:verified OR filter:verified"), 
                               n = 18000, 
                               type = "recent", 
                               include_rts = TRUE, 
                               parse = TRUE, 
                               token = auth, 
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
  sample_user_list <- vector(mode = "list", length = length(all_users))
  set.seed(seed)
  for(i in 1:length(all_users)){
    sample_user_list[[i]] <- sample(unique(user_ids[[i]]), samp_size*length(unique(user_ids[[i]]))) ## take sample from each element
  }
  
  save(sample_user_list, file = save_path) # 10% sample of users, list
}


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
  # load processed hashtags <paths[2]>; save all users list <paths[3]>
  user_collect_fn(open_path = paths[2], save_path = paths[3]) ## collect users
  # load all users list <paths[3]>; save sampled list of users <paths[4]>
  sample_users_fn(open_path = paths[3], samp_size = samp_size, seed = seed, save_path = paths[4]) ## create sample of users
  # load sampled list of users <paths[4]>; save sampled user vector <paths[5]>
  user_id_vec <- user_vector_fn(open_path = paths[4], save_path = paths[5]) ## create vector of sampled users
  
}


# STEP THREE - COLLECTING FOLLOWERS --------------------------------------------


### --------------------------- GET FOLLOWERS ---------------------------------
# INPUTS: 
# open_path - file path for user_id_vec - vector of user_ids
# save_path - file path for saving list of followers from user_ids
# 
# OUTPUTS:
# list of followers - each element is a user

follower_collect_fn <- function(open_path = sample_user_vec, save_path = all_followers){
  load(open_path)
  follower_list <- vector(mode = "list", length = length(user_id_vec))
  for(i in 1:length(user_id_vec)){
    try(follower_list[[i]] <- get_followers(user_id_vec[i], n = 75000, retryonratelimit = TRUE, token = auth)) # collect followers
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


sample_followers_fn <- function(open_path = all_followers, samp_size, seed, save_path = sample_followers){
  
  sample_follower_list <- vector(mode = "list", length = length(follower_list))
  set.seed(seed)
  for(i in 1:length(follower_list)){
    
    sample_follower_list[[i]] <- sample(unique(follower_list[[i]]$from_id), samp_prop*length(unique(follower_list[[i]]$from_id))) # sample followers
    
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
  
  # load user_id_vec <paths[1]>; save all followers list <paths[2]>
  follower_collect_fn(open_path = paths[1], save_path = paths[2]) # collect followers 
  # load all followers list <paths[2]>; save sampled followers list <paths[3]>
  sample_followers_fn(open_path = paths[2], samp_size = samp_size, seed = seed, save_path = paths[3]) # sample followers
  
}


# STEP FOUR - COLLECTING TWEETS FROM FOLLOWERS ---------------------------------

### ------------------- CREATE FOLLOWER CHUNKS ---------------------------------
# INPUTS: 
# open_path - file path for sample list of followers
# chunk_size - (integer) - number of user timelines per chunk
# 
# OUTPUTS:
# list of sampled followers divided into chunks
# NOTE: Purpose of creating chunks is to break up data collection and not overuse memory

create_chunks_fn <- function(open_path = sample_followers, chunk_size = 100, save_path = chunk_path){
  
  load(open_path)
  ### see how many users in follower_list 
  follower_vector <- unlist(samp_follower_list)
  
  chunk_size <- chunk_size # number of followers in each chunk
  chunks <- length(follower_vector) %/% chunk_size # floor division, # of chunks with chunk size in each chunk 
  follower_chunks <- vector(mode = "list", length = chunks)
  
  for(i in 1:chunks){  ### split vector up into chunks of 10 follower ids
    follower_chunks[[i]] <- follower_vector[(((i-1)*chunk_size) + 1):(i*chunk_size)]
    
  }
  
  save(follower_chunks, file = save_path)
  
}




###  ------------------- GET USER TIMELINE  ------------------------------------
# INPUTS: 
# users - character vector of users 
# n - (integer) - number of tweets being collected from each user timeline
# 
# OUTPUTS:
# user timeline tweets in table

get_timeline_unlimited <- function(users, n){
  
  if (length(users) == 0){
    return(NULL)
  }
  
  rl <- rate_limit("/statuses/user_timeline") # query rate limits to control collection
  
  if (length(users) <= rl$remaining){
    # print(paste("Getting data for", length(users), "users"))
    tweets <- get_timeline(users, n, check = FALSE, token = auth)  
  }else{
    
    if (rl$remaining > 0){
      users_first <- users[1:rl$remaining]
      users_rest <- users[-(1:rl$remaining)]
      # print(paste("Getting data for", length(users_first),  "users"))
      tweets_first <- get_timeline(users_first, n, check = FALSE, token = auth)
      rl <- rate_limit("/statuses/user_timeline")
      print(rl$remaining)
    }else{
      tweets_first <- NULL
      users_rest <- users
    }
    wait <- rl$reset + 0.1
    # print(paste("Waiting for",round(wait,2), "minutes"))
    Sys.sleep(wait * 60)
    
    tweets_rest <- get_timeline_unlimited(users_rest, n)  
    tweets <- bind_rows(tweets_first, tweets_rest)
  }
  return(tweets)
}


### ------------------- COLLECT AND SAVE FOLLOWER CHUNK ------------------------
# INPUTS: 
# chunk - (list element) - chunk of followers to collect 
# vol - number of timeline tweets requested per user
# save_path - file path for saving follower chunks list
#
# OUTPUTS:
# follower_tweets_"v" - table of tweets for follower chunk 

follower_tweet_fn <- function(chunk, vol = vol, save_path = follower_tweets_path){

  follower_tweets <- get_timeline_unlimited(users = chunk, n = vol) ## collect timeline tweets
  
  save(follower_tweets, file = paste0(save_path, v, ".Rda")) 
  
  rm(follower_tweets) # removes chunks to keep memory
  
}

### ------------------- COLLECT TWEETS ALL TOGETHER ----------------------------
# INPUTS: 
# paths - list of file paths for collecting tweets
# chunk_size (integer) - number of followers to collect tweets from in each session
# vol - number of tweets to collect from each timeline
# amount - amount of the total number of twitter chunks to collect (for time)
#
# OUTPUTS:
# follower_tweets_"v" - table of tweets for follower chunk 

collect_tweets_fn <- function(paths = collect_tweets_path, chunk_size = 100, vol = 3200, amount = 1){
  
  ## load sampled followers list <paths[1]>; save follower chunks <paths[2]>
  create_chunks_fn(open_path = paths[1], chunk_size = chunk_size, save_path = paths[2]) # create follower chunks
  
  load(paths[2]) # load follower chunks list <paths[2]>
  
  # proportion of follower chunks that should be gathered
  # default argument is 1, meaning all of the chunks
  objects <- ceiling(length(follower_chunks)*amount) 
  
  for(i in 1:length(objects)){
    # collect timeline tweets, save each chunk <paths[3]>
    try(follower_tweet_fn(chunk = follower_chunks[[i]], vol = vol, save_path = paths[3]))
  }
  
}


# DATA WRANGLING ---------------------------------------------------------------


### ------------------- CHECK FOR HASHTAG OF INTEREST --------------------------
# INPUTS: 
# ht - hashtag of interest
# df - follower tweets data frame to check
# 
#
# OUTPUTS:
# hash_oi_check - boolean vector - true or false for existence of hashtag of interest in each tweet 

check_hashtag_fn <- function(ht, df){
  hashtags <- vector(mode = "list", length = nrow(df)) ## list of hashtags from each post
  hash_oi_check <- vector(mode = "logical", length = nrow(df)) ## TRUE/FALSE vector - check for hashtag of interset
  
  for(i in 1:nrow(df)){
    
    if(length(df[i, ]$retweeted_status[[1]]) > 1){
      # if tweet has a retweet status - check hashtags of original tweet 
      # (can be missing from retweet hashtag attribute)
      # gathers hashtags from hashtag attribute, and retweet hashtag entity
      hashtags[[i]] <- c(tolower(df$entities[[i]]$hashtags$text), 
                         tolower(df[i, ]$retweeted_status[[1]]$entities$hashtags[[1]]$text))
      # check for any instances of hashtag of interest (TRUE if at least one)
      hash_oi_check[i] <- any(grepl(ht, hashtags[[i]]))
    }else{
      # if retweet status is empty, collect tweets from hashtag attribute
      hashtags[[i]] <- tolower(df$entities[[i]]$hashtags$text)
      # check for any instances of hashtag of interest (TRUE if at least one)
      hash_oi_check[i] <- any(grepl(ht, hashtags[[i]]))
      
    }
  }
  
  return(hash_oi_check)
}


### ------------------- CREATE RELEVANT DATE RANGE  --------------------------
# INPUTS: 
# open_path - file path for ground truth data table 
# 
#
# OUTPUTS:
# date range of ground truth data (allows us to get rid of irrelevant data) 

date_range_fn <- function(open_path){
  load(gt_path)
  return(range(gt_path))
}


### ------------------- PROCESS FOLLOWER TWEET TABLES --------------------------
# INPUTS: 
# root_path - File path for folder with follower_tweets tables 
# file_name - File name for specific follower_tweet table
# ht - (character) hashtag of interest 
# date_range - (POSiX) - date range derived from ground truth 
#
# OUTPUTS:
# cleaned tibble (id, text, created_at, hashtag) from each follower tweets table

tweet_df_fn <- function(root_path, file_name, ht, date_range){
  
  load(paste0(files_path, file_name))  #load follower_tweets table 
  
  # subset data by relevant date range
  ft_df <- follower_tweets[(follower_tweets$created_at >= date_range[1] & follower_tweets$created_at <= date_range[2]), ]
  
  ## NOTE: Separating columns into vectors is very quick way 
  ## to remove a huge number of table attributes included in twitter object
  ID <- ft_df$id_str ## twitter id column (character)
  TEXT <- ft_df$full_text ## tweet text column (character)
  CREATED <- ft_df$created_at ## created_at variable (date)
  HASH <- hashtag_check_fn(ht = ht, df = ft_df) # hash check (T/F) for hashtag of interest on each tweet
  # HASH[1] <- "golf" ### FOR TESTING
  # USER_ID <- attr(ft_df, "users")$id_str ## user id
  data <- tibble(id = ID, text = TEXT, created_at = CREATED, hashtag = HASH) ## Remake smaller table
  
  rm(follower_tweets) # remove follower_tweets object to save memory
  
  return(data)
  
}

### ------------------- DATA WRANGLING LOOP AND NOTIFICATIONS ------------------
# INPUTS: 
# root_path - File path for folder with follower_tweets tables 
# file_name - File name for specific follower_tweet table
# ht - (character) hashtag of interest 
# date_range - (POSiX) - date range derived from ground truth 
#
# OUTPUTS:
# list of cleaned tibbles (id, text, created_at, hashtag) from each follower tweets table


process_data_fn <- function(root_path, ht, date_range){
  
  files = list.files(path = root_path)
  df_list <- vector(mode = "list", length = length(files)) # initialize tibble list
  number_of_tweets <- 0
  for(i in seq_along(files)){ ## Compiling, cleaning, subsetting loop
    df_list[[i]] <- tweet_df_fn(root_path, file_name = files[i], ht, date_range)
    number_of_tweets <- number_of_tweets + sum(df_list[[i]]$hashtag)
    if(number_of_tweets > last_count){
      
      message(paste0(i, ": ", number_of_tweets))
    }else if((i %% 10) == 0){
      
      message(paste0(i, " out of ", length(files), " done."))
    }
    
    last_count <- number_of_tweets
  }
  
  return(df_list)
  
}


### ------------ CLEAN LIST, SAVE --------------------------------------------
# INPUTS: 
# df_list - list of cleaned tweet tibbles
# save_path - file path for saving cleaned list 
#
# OUTPUTS:
# list of cleaned tibbles with empty elements removed 


clean_df_list_fn <- function(df_list, save_path){

### remove any empty list elements
df_list_clean <- df_list[unlist(lapply(df_list,nrow))>0]
save(df_list_clean, file = save_path) ## save to df_list_path
  
}


### ------------ CONVERT TO LARGE TIBBLE ---------------------------------------
# INPUTS: 
# open_path - file path to loading clean list of tibbles
# save_path - file path to saving large tibble 
#
# OUTPUTS:
# large combined tibble (id, text, created_at, hashtag)

make_tibble_fn <- function(open_path, save_path){
  load(open_path) # open cleaned list of tibbles 
  hash_df <- data.table::rbindlist(df_list_clean) # combine list 
  save(hash_df, file = save_path) # save tibble
  
}


### ------------ DATA WRANGLING ALL TOGETHER -----------------------------------
# INPUTS: 
# paths - list of file paths for cleaning of data
# ht - hashtag of interest, formatted for grepl - e.g., "^golf$"
#
# OUTPUTS:
# large combined tibble (id, text, created_at, hashtag)


data_wrang_fn <- function(paths, ht){
  ## create date range - load ground truth <paths[1]>
  date_range <- date_range_fn(open_path = paths[1])
  
  ## process follower tweets objects into list of processed tibbles
  # load root path <paths[2]>
  df_list <- process_data_fn(root_path = paths[2], ht, date_range)
  
  ## clean list of tibbles; save cleaned list <paths[3]>
  clean_df_list_fn(df_list, save_path = paths[3])
  
  # convert list to large tibble 
  # load cleaned list <paths[3]>, save large tibble <paths[4]>
  make_tibble_fn(open_path = paths[3], save_path = paths[4])
}


# ESTIMATION ------------------------------------------------------------------


### ------------ GENERATE DATE RANGE FOR STORY WRANGLER -----------------------
# INPUTS: 
# gt_df - ground truth data table 
#
# OUTPUTS: 
# date range - a date range rounded for agreement with story wrangler date boundaries
#
# RULES: The ground truth has a date range - bottom (oldest) and top (most recent).
# Function should round up to next (more recent) bottom range, and down to less 
# than start of day for the top range. 

get_date_range_fn <- function(gt_df){
  
  ## get the original date range from the ground truth df
  orig_date_range <- range(gt_df$created_at)
  
  # rounding lower boundary
  lower_bound = lubridate::ceiling_date(orig_date_range[1], unit = "day")
  # date interval should be >= to lower boundary
  
  # rounding upper boundary
  upper_bound = lubridate::floor_date(range(orig_date_range[2]), unit = "day")
  # date interval should be < upper boundary
  
  new_date_range = c(lower_bound, upper_bound)
  
  return(new_date_range)
}


### ------------ SUBSET DATA TO DATE RATE -----------------------
# INPUTS: 
# df - dataframe object with date variable
#
# OUTPUTS: 
# new df - dataframe object subset to date interval that agrees with story wrangler
#

set_date_interval_fn <- function(df, date_range){
  
  # subset the data frame to dates falling equal to or above bottom and less than top
  new_df = df[df$created_at >= date_range[1] & df$created_at < date_range[2], ]
  return(new_df)
  
}

### ------------ GET TWEET VOLUME FROM STORY WRANGLER --------------------------
# INPUTS: 
# open_path - file path for loading story wrangler data
# date_time - time interval for indexing count values
#
# OUTPUTS: 
# count - (integer) - total number of English tweets falling within time interval

get_english_count_fn <- function(open_path, date_range){
  # load story wrangler data
  load(open_path)
  # get the sum of all the tweet counts for the date range interval
  count = sum(story_wrang$count[story_wrang$date >= date_range[1] & story_wrang$date < date_range[2]])
  
  # multiply times 10 because 10% sample
  return(count*10)
}


### -------------------- GET WEIGHTED AVERAGE FUNCTION  -----------------------
# INPUTS: 
# x - value to be weighted
# w - weight
#
# OUTPUTS: 
# weighted average

w_mean_fn <- function(x, w) sum(x*w)

### ------- GET CAPTURE PROBABILITY ESTIMATE OF POPULATION OF INTEREST ---------
# INPUTS: 
# df_sub - large collected dataframe subset for interval of date range
# iterations - (integer) - number of bootstrap resamples
#
# OUTPUTS: 
# bootstrap - bootstrapped estimate of capture probability

get_boot_capture_prob_fn <- function(df_sub, iterations){
  
  df_sub$count = NA 
  df_sub$count = as.integer(df_sub$hashtag)
  
  boot_strap = boot::boot(df_sub$count, statistic = w_mean_fn, R = 1000, stype = "w")
  
  return(boostrap)
}


### ----------------- GET CONFIDENCE INTERVALS ---------------------------------
# INPUTS: 
# boot_strap
#
# OUTPUTS: 
# conf_int - bootstrapped estimation of 95% confidence intervals

get_boot_conf_int_fn <- function(boot_strap){
  
  conf_int = boot::boot.ci(boot_strap, type = "basic")
  return(conf_int)
}


### ------------ ESTIMATION ALL TOGETHER ---------------------------------------
# INPUTS: 
# paths - files paths for loading tibbles
# iterations - number of bootstrap iterations
#
# OUTPUTS: 
# object list - [[1]] - abundance_est, [[2]] - confidence_int, [[3]] - sample_abundance_dist

## NOTE: Function for comparison with ground truth 
# (sample is subset to ground truth time interval)

get_estimate_fn <- function(paths, iterations){
  
  # load ground truth data <paths[1]>
  load(paths[1])
  # load collected data <paths[2]>
  load(paths[2])
  # load story wrangler data <paths[3]>
  load(paths[3])
  
  # get rounded date interval
  date_range = get_date_range_fn(ground_truth)
  
  #subset sampled data to date interval 
  sample_sub = set_date_interval_fn(hash_df, date_range)
  
  # get estimated capture probability from sample (bootstrap)
  capture_est = get_boot_capture_prob_fn(sample_sub, iterations)
  
  # get estimated confidence intervals from sample (bootstrap)
  capture_ci = get_boot_conf_int_fn(capture_est)
  
  # get story wrangler English tweet volume 
  tweet_volume = get_english_count_fn(story_wrang, date_range)
  
  # convert capture probability estimate to abundance estimate 
  abundance_est = capture_est$t0*tweet_volume
  
  # convert capture probability CI into abundance CI 
  confidence_int = c(capture_ci$basic[4]*tweet_volume, capture_ci$basic[5]*tweet_volume)
  
  # convert distribution of capture probabilities from bootstrap to abundance dist
  sample_abundance_dist = capture_est$t*tweet_volume
  
  # return objects as list: [[1]] - abundance_est, [[2]] - confidence_int
  # [[3]] - sample_abundance_dist
  estimate_objects = c(abundance_est, confidence_int, sample_abundance_dist)
  
  # save estimate objects
  save(estimate_objects, file = paths[4])
  
  return(estimate_objects)
  
}

# For other steps we want to look at capture probability 
# Test for consistency and efficiency 

# VISUALIZATION ----------------------------------------------------------------

### ---------------------- MAKE VISUALIZATION FUNCTION ------------------------
# INPUTS: 
# paths - files paths making visualization
# name - hashtag of interest or folder name for title of plot
#
# OUTPUTS: 
# plot - density of plot of sampling distribution with GT, estimate, and confidence intevals

make_viz_fn <- function(paths, name){
  
  #load ground truth data <paths[1]>
  load(paths[1])
  # load estimate objects <paths[2]>
  load(paths[2])
  
  
  # get rounded date interval
  date_range = get_date_range_fn(ground_truth)
  #subset ground truth data to date interval 
  gt_sub = set_date_interval_fn(ground_truth, date_range)
  
  ## objects for plot
  estimate = estimate_objects[[1]]
  ci = estimate_objects[[2]]
  sample_dist = estimate_objects[[3]]
  
  
  ## Aesthetic Specs for Plot
  line_width = 1.2
  line_width_b = 1
  alph = 0.3
  bg_col = "#0bb4ff"
  gt_col = "#e60049"
  org_col = "#9b19f5"
  boot_col = "#ffa300"
  ci_col = "#dc0ab4"
  panel_col = "#3b3734"
  
  ## Saving plot as png
  png(filename = paths[3], width = 10, height = 8, units = "in", res = 300)
  ggplot() + 
    # geom_histogram(mapping = aes(x = estimate, y = ..density..), color = "white", fill = NA, bins = 28) + 
    geom_density(mapping = aes(sample_dist), fill = bg_col, 
                 color = "white", alpha = alph) + 
    geom_vline(aes(xintercept = gt_count), linetype = "solid", 
               color = gt_col, linewidth = line_width) +
    geom_vline(aes(xintercept = estimate), linetype = "dashed", 
               color = boot_col, size = line_width) +
    geom_vline(aes(xintercept = ci[1]), linetype = "dotted", 
               color = ci_col, linewidth = line_width_b) +
    geom_vline(aes(xintercept = ci[2]), linetype = "dotted", 
               color = ci_col, linewidth = line_width_b) +
    labs(Title = paste0(name," Sampling Distribution"), 
         x = "Population Abundance Estimate", y = "Density") + 
    theme(panel.background = element_rect(fill = panel_col, 
                                          color = panel_col), 
          panel.border = element_blank(),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(), 
          plot.background = element_rect(fill = panel_col), 
          text = element_text(color = "white"), 
          axis.text = element_text(color = "white"))
  dev.off()
  
  ## Creating plot object to return
  plot <- ggplot() + 
    # geom_histogram(mapping = aes(x = estimate, y = ..density..), color = "white", fill = NA, bins = 28) + 
    geom_density(mapping = aes(sample_dist), fill = bg_col, 
                 color = "white", alpha = alph) + 
    geom_vline(aes(xintercept = gt_count), linetype = "solid", 
               color = gt_col, linewidth = line_width) +
    geom_vline(aes(xintercept = estimate), linetype = "dashed", 
               color = boot_col, size = line_width) +
    geom_vline(aes(xintercept = ci[1]), linetype = "dotted", 
               color = ci_col, linewidth = line_width_b) +
    geom_vline(aes(xintercept = ci[2]), linetype = "dotted", 
               color = ci_col, linewidth = line_width_b) +
    labs(Title = paste0(hame," Sampling Distribution"), 
         x = "Population Abundance Estimate", y = "Density") + 
    theme(panel.background = element_rect(fill = panel_col, 
                                          color = panel_col), 
          panel.border = element_blank(),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(), 
          plot.background = element_rect(fill = panel_col), 
          text = element_text(color = "white"), 
          axis.text = element_text(color = "white"))
  
  return(plot)
  
}


# STATUSES  -------------------------------------------------------------------

### ---------------------- UPDATE STATUS ------------------------
# INPUTS: 
# status - text string indicating status 
# name - text for indicating hashtag of interest and where to save
#
# OUTPUTS: 
# save - save of status text (to keep track of where in the sampling process)

update_status_fn <- function(status, root, name){
  text <- paste("TIME:", Sys.time(), "STATUS:", status, "for #", name)
  file <- paste0(root, "Orthogonal Sampling Project/", name, "/statuses.txt")
  write(text, file, sep = "\n", append = TRUE)
  
}



