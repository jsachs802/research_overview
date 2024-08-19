# ASSIGN CREDENTIAL VARIABLES 

SUPABASE_URL = "####" 
SUPABASE_KEY = "####"
REDDIT_PUBLIC = "####"
REDDIT_SECRET = "####"
REDDIT_USER_AGENT = "#####" #format - <institution:project-name (u/reddit-username)>


# Define the database table names to store data
DB_CONFIG = {
  "user": "wildf_redditor",
  "submission": "wildf_submission", 
  "comment": "wildf_comment"
}


# Login and create instances of reddit and supabase clients

import redditharbor.login as login 

reddit_client = login.reddit(public_key=REDDIT_PUBLIC, secret_key=REDDIT_SECRET, user_agent=REDDIT_USER_AGENT)
supabase_client = login.supabase(url=SUPABASE_URL, private_key=SUPABASE_KEY)


## DATA COLLECTION 

# After initializing an instance of the collect class, you can call its various functions to collect Reddit data.

from redditharbor.dock.pipeline import collect

collect = collect(reddit_client=reddit_client, supabase_client=supabase_client, db_config=DB_CONFIG)

subreddits = ["all"]
query2 = "wild fire"
sort_types = ["hot", "top"] 

import pickle  # For new keywords
with open("#####", "rb") as f:
    queries = pickle.load(f)

    queries = queries[158:]

import time 

for query in queries:

    collect.submission_by_keyword(subreddits, query, limit=100000)

    time.sleep(20)