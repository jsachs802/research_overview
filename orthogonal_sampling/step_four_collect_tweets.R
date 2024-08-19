# STEP FOUR - COLLECTING TWEETS FROM FOLLOWERS ---------------------------------

### ------------------- CREATE FOLLOWER CHUNKS ---------------------------------
# INPUTS: 
# open_path - file path for sample list of followers
# chunk_size - (integer) - number of user timelines per chunk
# 
# OUTPUTS:
# list of sampled followers divided into chunks
# NOTE: Purpose of creating chunks is to break up data collection and not overuse memory

create_chunks_fn <- function(open_path, chunk_size, save_path){
  
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

follower_tweet_fn <- function(chunk, vol, save_path, i){
  
  follower_tweets <- get_timeline_unlimited(users = chunk, n = vol) ## collect timeline tweets
  
  save(follower_tweets, file = paste0(save_path, i, ".Rda")) 
  
  rm(follower_tweets) # removes chunks to save memory
  
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

collect_tweets_fn <- function(paths, chunk_size, vol, amount){
  
  ## load sampled followers list <paths[1]>; save follower chunks <paths[2]>
  create_chunks_fn(open_path = paths[1], chunk_size, save_path = paths[2]) # create follower chunks
  
  load(paths[2]) # load follower chunks list <paths[2]>
  
  # proportion of follower chunks that should be gathered
  # default argument is 1, meaning all of the chunks
  objects <- ceiling(length(follower_chunks)*amount) 
  # message(paste(objects))
  
  for(i in 1:objects){
    # collect timeline tweets, save each chunk <paths[3]>
    try(follower_tweet_fn(chunk = follower_chunks[[i]], vol, save_path = paths[3], i))
    message(paste(i, " of", objects, " collection complete"))
  }
  
}
