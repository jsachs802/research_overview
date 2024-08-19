## Trump Activity Functions

auth_path = 
auth_fn <- function(path){
  ## Authentication
  source(file = path, local = TRUE) # load credentials 
  ## bearer token
  return(rtweet::rtweet_app(bearer_token)) # initialize credentials
}


timeline_collect_fn2 <- function(user, n){ ## cleans returned data object
  obj <- try(get_timeline(user, n, check = FALSE, token = auth))
  # message(paste(nrow(obj)))
  # message(paste(class(obj)))
  if(class(obj)[1] != "try-error"){
    if(nrow(obj) >= 1){
      
      tweet_id <- as.character(obj$id)
      created_at <- obj$created_at
      full_text <- obj$full_text
      user_id <- attr(obj, "users")$id
      
      tweet_tib <- tibble(tweet_id = tweet_id, 
                          created_at = created_at, 
                          full_text = full_text,
                          user_id = user_id)
      
    }else{
      
      tweet_tib <- NULL
    }
  }else{
    
    tweet_tib <- NULL
    
  }
  
  
  return(tweet_tib)
  
}


rate_limit_fn <- function(end_point){
  out <- tryCatch(
    {
      
      rl <- rate_limit(end_point)
    },
    error=function(cond){## if rate limit is zero, error will be thrown
      
      return(0)
    })    
  return(out)
}


get_timeline_fn2 <- function(user, n){
  rl <- rate_limit_fn(end_point = "/statuses/user_timeline") # check number of requests left
  
  if(length(rl) == 1){
    message("Waiting 15 minutes")
    Sys.sleep(960)
    tweet_df <- timeline_collect_fn2(user, n)
  }else if(rl$remaining < 20){ # if fewer than 20 requests left, sleep
    
      message("Waiting 15 minutes")
      Sys.sleep((rl$reset * 60) + 1)
      tweet_df <- timeline_collect_fn2(user, n)
      
  }else{
    
    tweet_df <- timeline_collect_fn2(user, n)
    
  }
  
  return(tweet_df)
  
}



user_activity_fn <- function(n){
  load("~/Dropbox/sachs_karell_paper/trump_twitter/Trump Tweets/Data/users.Rda") ## load users 
  # users <- users[350:360] ### FOR TESTING A BUG - REMOVE IN REGULAR USE
  load("~/Dropbox/sachs_karell_paper/trump_twitter/Trump Tweets/Data/trump_follower_tweets_11_21.Rda") ## load initial tweet dataframe 
  updates <- list.files("~/Dropbox/sachs_karell_paper/trump_twitter/Trump Tweets/Data/Updates/") ### dfs from previous activity checks
  user_tibs <- vector(mode = "list", length = length(users))
  update_list <- vector(mode = "list", length = length(users))
  
  ## Updating data 
  if(length(updates) > 0){
    update_files_list <- vector(mode = "list", length = length(updates))
    for(i in 1:length(updates)){
      
      load(paste0("~/Dropbox/sachs_karell_paper/trump_twitter/Trump Tweets/Data/Updates/update_", i, ".Rda"))
      update_files_list[[i]] <- update
      rm(update)
      
    }
    
    update_df <- data.table::rbindlist(update_files_list)
    updated_df <- rbind(tweets_before, update_df)
    rm(update_files_list)
    rm(update_df)
    
  }
  
  for(i in 1:length(users)){
    
    tweets <- get_timeline_fn2(user = users[i], n)
    if(!is.null(tweets)){
      tweets <- tweets %>% filter(textcat(full_text) == "english")
      update_list[[i]] <- tweets
    }else{
      
      next
    }
    
    ### if statement that checks if there have been previous updates
    if(length(updates) == 0){
      
      maximum <- max(tweets_before$created_at[as.character(tweets_before$user_id) == users[i]]) ## most recent tweet date of last check
      
    }else{
      
      maximum <- max(updated_df$created_at[as.character(updated_df$user_id) == users[i]])
      
    }
    
    ### if statement returns a maximum date for 0 or more updates
    count <- length(tweets$tweet_id[tweets$created_at > maximum])
    user_tibs[[i]] <- tibble(user = users[i], date = Sys.Date(), n = count)
    rm(tweets)
    rm(count)
    
  }
  
  update_list2 <- update_list[lapply(update_list, length) > 0] ## remove empty cells if any
  update <- data.table::rbindlist(update_list2) ## create update df 
  save(update, file = paste0("~/Dropbox/sachs_karell_paper/trump_twitter/Trump Tweets/Data/Updates/update_", length(updates) + 1, ".Rda"))
  user_tib <- data.table::rbindlist(user_tibs)
  
  ### saving update summary
  update_summaries <- list.files("~/Dropbox/sachs_karell_paper/trump_twitter/Trump Tweets/Data/Update summaries") ### dfs from previous activity checks
  user_update = user_tib
  save(user_update, file = paste0("~/Dropbox/sachs_karell_paper/trump_twitter/Trump Tweets/Data/Update summaries/user_update_", length(update_summaries) + 1, ".Rda"))
  
  # ## return tibble
  # return(user_tib)
  
}


activity_summary_fn <- function(type = "plot"){
  
  filenames <- list.files("~/Dropbox/sachs_karell_paper/trump_twitter/Trump Tweets/Data/Update summaries")
  update_list <- vector(mode = "list", length = length(filenames) + 1)
  for(i in 1:length(filenames)){
    load(paste0("~/Dropbox/sachs_karell_paper/trump_twitter/Trump Tweets/Data/Update summaries/user_update_", i, ".Rda"))
    update_list[[i]] <- user_update
    rm(user_update)
    
  }
  
  update_list[[length(filenames) + 1]] <- tibble(user = "8675309", date = as.Date("2022-11-20"), n = 0)
  
  update_df <- data.table::rbindlist(update_list)
  
  tweeters_df <- update_df %>% filter(n >= 1)
  
  tweeters_avg <- update_df %>% filter(n >= 1) %>% summarize(avg_tweets = mean(n, na.rm = T))
  
  tweeters <- paste0(round((length(unique(tweeters_df$user))/length(unique(update_df$user)))*100, 2), " %") ## fraction of user sample that tweeted
  
  avg_df <- update_df %>% group_by(date) %>% summarize(min = min(n, na.rm = T), 
                                                       q1 = quantile(n, probs = 0.25, na.rm = FALSE), 
                                                       avg = mean(n, na.rm = T), median = median(n, na.rm = T), 
                                                       q3 = quantile(n, probs = 0.75, na.rm = FALSE), 
                                                       max = max(n, na.rm = T))
  
  plot1 <- ggplot(avg_df) +
    geom_line(mapping = aes(x = date, y = avg), color = "#51127CFF", size = 3) +
    geom_line(mapping = aes(x = date, y = median), color = "#FEC287FF", size = 3) + 
    theme_minimal() + 
    labs(title = "Mean (purple) and Median (yellow) New Tweets in Sample", x = "Date", y = "New Tweets")
  
  
  
  if(type == "plot"){
    return(plot1)
  }else if (type == "table"){
    return(avg_df)
  }else if(type == "plot2"){
    return(flexdashboard::valueBox(tweeters, caption = "Percentage of users who have Tweeted across all time periods", icon = "fa-comments"))
  }else if(type == "plot3"){
    return(flexdashboard::valueBox(round(tweeters_avg, 3), caption = "Average # of Tweets among users Tweeting", icon = "fa-comments"))
  }

}
