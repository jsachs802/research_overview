library(flexdashboard)
library(tidyverse)
library(rtweet)
library(httpuv)
library(DT)

# ## Authentication
# source(file = "~/Dropbox/sachs_karell_paper/trump_twitter/Trump Tweets/twitter_auth.R", local = TRUE) # load credentials
# 
# # create_token(app = "20278739", consumer_key = api_key, consumer_secret = api_secret_key, access_token = access_token, access_secret = access_token_secret)
# # auth <- get_token()
# # auth = rtweet::rtweet_app(bearer_token)
# # 
# 
# ### Tweet Collection Functions
# source(file = "~/Dropbox/sachs_karell_paper/trump_twitter/Trump Tweets/trump_activity_functions.R", local = TRUE) # load functions
# 
# auth_path = "~/Dropbox/sachs_karell_paper/trump_twitter/Trump Tweets/twitter_auth.R"
# 
# auth <- auth_fn(auth_path)
# 
# 
# ### Tweet update function
# user_activity_fn(10) # input indicates number of tweets per user

## Knit dashboard
rmarkdown::render("~/Dropbox/sachs_karell_paper/trump_twitter/Trump Tweets/user_activity_dash.Rmd")

