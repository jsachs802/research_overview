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
  
  return(boot_strap)
}

?boot


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
  
  # get rounded date interval
  date_range = get_date_range_fn(ground_truth)
  
  ## get ground truth estimate 
  
  # subset ground truth data to date interval 
  gt_sub = set_date_interval_fn(ground_truth, date_range)
  
  # count row in subset of ground truth 
  gt_count = nrow(gt_sub)
  
  #subset sampled data to date interval 
  sample_sub = set_date_interval_fn(hash_df, date_range)
  
  # get estimated capture probability from sample (bootstrap)
  capture_est = get_boot_capture_prob_fn(sample_sub, iterations)
  
  # get estimated confidence intervals from sample (bootstrap)
  capture_ci = get_boot_conf_int_fn(capture_est)
  
  # get story wrangler English tweet volume 
  tweet_volume = get_english_count_fn(paths[3], date_range)
  
  # convert capture probability estimate to abundance estimate 
  abundance_est = capture_est$t0*tweet_volume
  
  # convert capture probability CI into abundance CI 
  confidence_int = c(capture_ci$basic[4]*tweet_volume, capture_ci$basic[5]*tweet_volume)
  
  # convert distribution of capture probabilities from bootstrap to abundance dist
  sample_abundance_dist = capture_est$t*tweet_volume
  
  # return objects as list: [[1]] - abundance_est, [[2]] - confidence_int
  # [[3]] - sample_abundance_dist
  estimate_objects = list(abundance_est, confidence_int, sample_abundance_dist, gt_count, capture_est)
  
  # # save estimate objects
  # save(estimate_objects, file = paths[4])
  # 
  return(estimate_objects)
  
}