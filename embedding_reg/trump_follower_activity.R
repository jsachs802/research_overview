### Checking User Activity
library(tidyverse)
library(rtweet)
library(httpuv)
library(textcat)

## Authentication
source(file = "~/Dropbox/sachs_karell_paper/trump_twitter/Trump Tweets/twitter_auth.R", local = TRUE) # load credentials 
auth <- rtweet_app(bearer_token) # initialize credentials, paste the bearer token

### Tweet Collection Functions
source(file = "~/Dropbox/sachs_karell_paper/trump_twitter/Trump Tweets/trump_activity_functions.R", local = TRUE) # load credentials 

start <- Sys.time()
## Run Function for Update
user_activity_fn(10) # input is number of tweets per user, 20 new tweets

# load("~/Desktop/Trump Tweets/Data/users.Rda") ## load users
# which(users == "1589801664478789632")
# users <- users[users == "1589801664478789632"] ######## for testing!!!!!!!!!!!!
# tweets <- timeline_collect_fn2(user = users, 10)
# obj <- try(get_timeline(users, 10, check = FALSE, token = auth))
# nrow(obj)
# print(length(obj))

### Run Function for Visual and Summary 
plot <- activity_summary_fn(type = "plot")

df <- plot <- activity_summary_fn(type = "df")

finish <- Sys.time()
run_time <- finish - start 
run_time














