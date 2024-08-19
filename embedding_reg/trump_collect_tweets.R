### COLLECT TWEETS FROM FOLLOWERS
library(tidyverse)
library(rtweet)
library(httpuv)
library(textcat)

## Authentication
source(file = "####", local = TRUE) # load credentials 
## copy the bearer token 
clipr::write_clip(bearer_token)
auth <- rtweet_app() # initialize credentials, paste the bearer token


## TIMELINE FUNCTION 

### TIMELINE FROM UNLIMITED FOLLOWERS FUNCTION 

timeline_collect_fn <- function(users, n){
  obj <- vector(mode = "list", length = length(users))
  tweet_tib_list <- vector(mode = "list", length = length(users))
  for(i in 1:length(users)){
    
    obj[[i]] <- try(get_timeline(users[i], n, check = FALSE, token = auth))

    if(length(obj[[i]]) > 1){
      
      tweet_id <- as.character(obj[[i]]$id)
      created_at <- obj[[i]]$created_at
      full_text <- obj[[i]]$full_text
      user_id <- attr(obj[[i]], "users")$id
      
      tweet_tib_list[[i]] <- tibble(tweet_id = tweet_id, 
                                    created_at = created_at, 
                                    full_text = full_text,
                                    user_id = user_id)
      
    }else{
      
      tweet_tib_list[[i]] <- NULL
    }
    
  }
  
  tweet_tib_list2 <- tweet_tib_list[lapply(tweet_tib_list, length) > 0]
  tweet_tib_df <- data.table::rbindlist(tweet_tib_list2)
  
  return(tweet_tib_df)

}


get_timeline_unlimited <- function(users, n){
  
  if (length(users) ==0){
    return(NULL)
  }
  
  rl <- rate_limit("/statuses/user_timeline")
  
  if (length(users) <= rl$remaining){
    # print(paste("Getting data for", length(users), "users"))
    tweets <- timeline_collect_fn(users, n)
  }else{
    
    if (rl$remaining > 0){
      users_first <- users[1:rl$remaining]
      users_rest <- users[-(1:rl$remaining)]
      # print(paste("Getting data for", length(users_first),  "users"))
      tweets_first <- timeline_collect_fn(users_first, n)
      rl <- rate_limit("/statuses/user_timeline")
      print(rl$remaining)
    }else{
      tweets_first <- NULL
      users_rest <- users
    }
    wait <- rl$reset + 0.1
    # print(paste("Waiting for",round(wait,2), "minutes"))
    Sys.sleep(wait * 60)
    
    tweets_rest <- timeline_collect_fn(users_rest, n) 
    tweets <- bind_rows(tweets_first, tweets_rest)
  }
  return(tweets)
}




#LOAD FOLLOWER CSV 
csv <- read_csv("####")
followers <- csv$`0`
rm(csv)
save(followers, file = "####")


## Select 10000 followers randomly 
set.seed(94389432)
followers_samp <- sample(followers, 10000)
followers_samp <- as.character(followers_samp)
save(followers_samp, file = "####")

trump_fol_tweets <- get_timeline_unlimited(followers_samp, n = 200)

tweets_before <- trump_fol_tweets %>% filter(textcat(full_text) == "english")

save(tweets_before, file = "~/Desktop/Trump Tweets/Data/trump_follower_tweets_11_21.Rda")
