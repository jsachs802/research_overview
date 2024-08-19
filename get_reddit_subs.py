# Script for operating the get_submissions_from subreddit_function
import os # for getting environmental variables
import praw # for acccessing Reddit API

import reddit_methods2 as red_meth # Import module from reddit_methods.py
import psycopg2

# Load pkl file with subreddits using built-in pickle module
import pickle 

# Load the list from file
with open('####', 'rb') as f:
    subreddits_list = pickle.load(f)

# Tested on first two, starting scrape at 3
subreddits_list = subreddits_list[2:]

# Initialize the reddit instance 
    # Use os to get environmental variables
reddit = praw.Reddit(
    client_id=os.getenv("REDDIT_CLIENT_ID"),
    client_secret=os.getenv("REDDIT_CLIENT_SECRET"),
    password=os.getenv("REDDIT_PASSWORD"),
    user_agent=os.getenv("REDDIT_USER_AGENT"),
    username=os.getenv("REDDIT_USERNAME"),
)

conn = psycopg2.connect(
    dbname="####",
    user="####",
    password="####",
    host="####",
    port="####"
    )


# Call the get_submissions_from_subreddits function 
red_meth.get_submissions_from_subreddits(reddit, subreddits_list, conn)

