import time
import os
import praw
from datetime import datetime, timezone
import set_environment_vars
import psycopg2
import numpy as np
import pandas as pd


# Credentials 
reddit = praw.Reddit(
    client_id=os.getenv("REDDIT_CLIENT_ID"),
    client_secret=os.getenv("REDDIT_CLIENT_SECRET"),
    password=os.getenv("REDDIT_PASSWORD"),
    user_agent=os.getenv("REDDIT_USER_AGENT"),
    username=os.getenv("REDDIT_USERNAME"),
)


# List of landscapes 
    # Add list of landscapes 
    # If subreddit is from landscape then denote it as such in datatable

### SCRAPING FUNCTIONS 

## GET SUBMISSIONS FUNCTION 

def get_submissions_from_subreddits(reddit, subreddits, conn):
    """Function to collect submissions given a list of subreddits

    Args:
        reddit (PRAW object): Authorization object from PRAW
        subreddits (list): list of subreddit strings from Reddit

    Returns:
        None (insert row in supabase table)
    """
    cur = conn.cursor() # Create cursor object

    i = 0 # for noting progress
    for subreddit in subreddits: 
        i += 1 # for marking progress
        print(f"Index: {i-1}")
        print(f"Processing subreddit: {subreddit}: {round((i/len(subreddits))*100, 1)}% done")
        try: 
            for post in reddit.subreddit(subreddit).hot(limit=10000): # Loop through subreddit list
                    # Format Date
                    created_utc = datetime.fromtimestamp(post.created_utc, tz=timezone.utc).isoformat()
                    
                    # Load data row by row
                    cur.execute('''
                    INSERT INTO reddit_submissions (id, text, author, author_blocked, category, created, subreddit, title, upvotes, upvote_ratio, url, view_count, score, num_comments)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                    ON CONFLICT (id) DO NOTHING
                    ''', (post.id, str(post.selftext), str(post.author), post.author_is_blocked, post.category, created_utc, str(post.subreddit), post.title, post.ups, post.upvote_ratio, str(post.url), post.view_count, post.score, post.num_comments))
                 
                    conn.commit()
                    # print(response) # for debugging

        except Exception as e:
            print(f"Error while processing subreddit {subreddit}: {e}")

        time.sleep(10)

    cur.close() # Close cursor object
    conn.close() # Close connection object


# ### FUNCTION THAT CREATES URLS LIST FROM SUBMISSIONS 

def get_urls_from_submissions(conn):
    """Function to get urls from submissions in the reddit_submissions_table

    Args: postgresql connection object

    Returns: urls (list): list of urls from submissions
    """
    # Query the reddit_submissions_table
    urls = []
    try:
        # Create a cursor object
        cur = conn.cursor()
        
        # Execute the query to fetch all urls from the reddit_submissions table
        cur.execute("SELECT url FROM clean_reddit_submissions")
        
        # Fetch all rows from the executed query
        rows = cur.fetchall()
        
        # Extract urls from the rows
        urls = [row[0] for row in rows]
        
        # Close the cursor
        cur.close()
    except Exception as e:
        print(f"Error while fetching URLs: {e}")
    
    return urls


# ### GET COMMENTS FUNCTION 

def get_comments_from_urls(reddit, urls, conn):
    """Function to collect comments given a list of urls

    Args:
        reddit (PRAW object): Authorization object from PRAW
        urls (list): url strings from Reddit

    Returns: None (insert row in supabase table)
    """
    i = 0 # for noting progress
    for url in urls: # Loop through urls list
        i += 1 # for marking progress
        print(f"Index: {i-1} -- {round((i/len(urls))*100, 1)}% done")
        try: 
            submission = reddit.submission(url=url) # Initialize submission object
            submission.comments.replace_more(limit=None) # Replace MoreComments objects with Comment objects
            for comment in submission.comments.list(): # Loop through each comment in submission
                
                # Check if the comment already exists in the reddit_comments table
                with conn.cursor() as cur:
                    cur.execute("SELECT 1 FROM reddit_comments WHERE id = %s", (comment.id,))
                    result = cur.fetchone()
                    
                    if result is None:
                        # Insert the comment into the reddit_comments table
                        created_utc = datetime.fromtimestamp(comment.created_utc, tz=timezone.utc).isoformat()
                        cur.execute("""
                            INSERT INTO reddit_comments (id, author, text, created, link_id, parent_id, score, controversiality, subreddit)
                            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
                        """, (
                            comment.id,
                            str(comment.author),
                            str(comment.body),
                            created_utc,
                            comment.link_id,
                            comment.parent_id,
                            comment.score,
                            comment.controversiality,
                            str(comment.subreddit)
                        ))
                        conn.commit()

                # print(response) # for debugging

        except Exception as e:
            print(f"Error while processing subreddit {url}: {e}")
        
        
             
        time.sleep(1)


        