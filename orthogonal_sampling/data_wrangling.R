# DATA WRANGLING ---------------------------------------------------------------


### ------------------- CHECK FOR HASHTAG OF INTEREST --------------------------
# INPUTS: 
# ht - hashtag of interest
# df - follower tweets data frame to check
# 
#
# OUTPUTS:
# hash_oi_check - boolean vector - true or false for existence of hashtag of interest in each tweet 

check_hashtag_fn <- function(ht, dataf){
  hashtags <- vector(mode = "list", length = nrow(dataf)) ## list of hashtags from each post
  hash_oi_check <- vector(mode = "logical", length = nrow(dataf)) ## TRUE/FALSE vector - check for hashtag of interset
  
  for(i in 1:nrow(dataf)){
    
    if(length(dataf[i, ]$retweeted_status[[1]]) > 1){
      # if tweet has a retweet status - check hashtags of original tweet 
      # (can be missing from retweet hashtag attribute)
      # gathers hashtags from hashtag attribute, and retweet hashtag entity
      hashtags[[i]] <- c(tolower(dataf$entities[[i]]$hashtags$text), 
                         tolower(dataf[i, ]$retweeted_status[[1]]$entities$hashtags[[1]]$text))
      # check for any instances of hashtag of interest (TRUE if at least one)
      hash_oi_check[i] <- any(grepl(ht, hashtags[[i]]))
    }else{
      # if retweet status is empty, collect tweets from hashtag attribute
      hashtags[[i]] <- tolower(dataf$entities[[i]]$hashtags$text)
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
  return(range(ground_truth$created_at))
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
  
  load(paste0(root_path, "/", file_name))  #load follower_tweets table 
  
  # subset data by relevant date range
  ft_df <- follower_tweets[(follower_tweets$created_at >= date_range[1] & follower_tweets$created_at <= date_range[2]), ]
  
  if(nrow(ft_df) >= 1){
    ## NOTE: Separating columns into vectors is very quick way 
    ## to remove a huge number of table attributes included in twitter object
    ID <- ft_df$id_str ## twitter id column (character)
    TEXT <- ft_df$full_text ## tweet text column (character)
    CREATED <- ft_df$created_at ## created_at variable (date)
    HASH <- check_hashtag_fn(ht = ht, dataf = ft_df) # hash check (T/F) for 
                                            # hashtag of interest on each tweet
    # HASH[1] <- "golf" ### FOR TESTING
    # USER_ID <- attr(ft_df, "users")$id_str ## user id
    data <- tibble(id = ID, text = TEXT, created_at = CREATED, hashtag = HASH) 
    ## Remake smaller table
    
    rm(follower_tweets) # remove follower_tweets object to save memory
    
    return(data)
    
  }else{
    return(NULL)
  }
  
 
}



### ------------------- MANAGING FILES FOR DATA COLLECTION ---------------------
# INPUTS: 
# root_path - file path for folder with follower_tweets tables 
# 
#
# OUTPUTS: 
# list of files with names of follower_tweets tables with empty tables removed 

clean_files_fn <- function(root_path){
  files = list.files(path = root_path)
  new_files = vector(mode = "character")
  for(i in 1:length(files)){
    file_info = file.info(paste0(root_path, "/", files[i]))
    if(file_info$size < 900){
      
      unlink(paste0(root_path, "/", files[i]))
      
    }
    
    rm(file_info)
    
  }
  
}


### ------------------- DATA WRANGLING LOOP AND NOTIFICATIONS ------------------
# INPUTS: 
# root_path - File path for folder with follower_tweets tables 
# files - list of files with names of follower_tweets tables 
# ht - (character) hashtag of interest 
# date_range - (POSiX) - date range derived from ground truth 
#
# OUTPUTS:
# list of cleaned tibbles (id, text, created_at, hashtag) from each follower 
# tweets table


process_data_fn <- function(root_path, ht, date_range, save_path){
  
  files = list.files(path = root_path)
  df_list <- vector(mode = "list", length = length(files)) # initialize tibble 
                                                          # list
  
  for(i in 1:length(files)){ ## Compiling, cleaning, subsetting loop 
    df_list[[i]] <- tweet_df_fn(root_path, file_name = files[i], ht, date_range)
    
    if((i %% 10) == 0){
      message(paste0(i, " out of ", length(files), " done."))
    }
    
  }
  
  save(df_list, file = save_path)
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
  df_list <- process_data_fn(root_path = paths[2], ht, date_range, save_path = paths[3])
  
  ## clean list of tibbles; save cleaned list <paths[3]>
  clean_df_list_fn(df_list, save_path = paths[4])
  
  # convert list to large tibble 
  # load cleaned list <paths[3]>, save large tibble <paths[4]>
  make_tibble_fn(open_path = paths[4], save_path = paths[5])
}