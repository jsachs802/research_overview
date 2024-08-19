# GROUND TRUTH  ----------------------------------------------------------------

### ---------------------- Check Validity of Ground Truth ----------------------
# INPUTS:
# hash - (character) - hashtag of interest
#
# OUTPUTS:
# twitter object - ground truth table of tweets featuring hashtag of interest


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
# INPUTS:
# hash - (character) - hashtag of interest
# save_path - file path for saving twitter object

# OUTPUTS:
# twitter object - ground truth table of tweets featuring hashtag of interest

get_ground_truth_fn <- function(hash, save_path = gt_path){
  
  ground_truth <- grnd_trth_fn(hash = hash) ### verify if we can get ground truth
  
  if(!is.null(ground_truth)){
    save(ground_truth, file = save_path)
  }else{
    message("Ground truth not verified.")
  }
}