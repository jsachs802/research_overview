import reddit_methods2 as red_meth
import set_environment_vars
import os
import praw
import psycopg2

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

# Call get urls and collect comments from urls functions

# request urls with sql query 
urls = red_meth.get_urls_from_submissions(conn) # call function to get urls from database 

# print(len(urls)) # for debugging 

# # Find the index of the last processed url 
# last_processed_index = urls.index(last_processed_url)

# # Slice the list from the index of the last procsssed url onwards
# urls = urls[last_processed_index + 1:]

# gather comments from reddit api

conn = psycopg2.connect(
    dbname="####",
    user="####",
    password="####",
    host="####",
    port="####"
    )

red_meth.get_comments_from_urls(reddit, urls, conn)