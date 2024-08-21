Back to [Main Page](https://github.com/jsachs802/research_overview/blob/main/README.md)

I often have a task of pulling data from an API and needing to store it somewhere -- I generally choose an RDBMS. The task is relatively straightforward, but there are a few problems one should be mindful of. Sometimes I'm querying an API with keywords, or in the case below, subreddits, and I don't know how much data the API is going to return. If I suspect that I will be collecting a lot of data, I will want to interate the data into the database, so I don't use up too much memory. Iterating commits to the database also safeguards against API interruptions that can occur. If an iterruption takes place, you might lose data you have in memory, so it's best to store the data in the database instead of holding it in memory. 

I like to setup a database and create a bit of a pipeline from the API to the sql server. 

In the example below, I'm collecting data from Reddit using the 'praw' python package. The specific task I'm outlining in my example is not important; the important part is iterating your commits. 

I would start by creating a database and table for storing the data. For something simple, I tend to use PostgreSQL. I would create the table with code that looks like this: 

```SQL

-- Create table reddit_submissions
CREATE TABLE reddit_submissions (
    id varchar primary key,
    text text,
    author varchar,
    author_blocked boolean,
    category varchar,
    created timestampz,
    subreddit varchar,
    title varchar,
    upvotes numeric,
    upvote_ratio numeric,
    upvote_ratio jsonb,
    url varchar,
    view_count numeric,
    score numeric,
    num_comments numeric
); 

-- Enable row-level security on reddit_submission
ALTER TABLE reddit_submissions ENABLE ROW LEVEL SECURITY;

```

The next bit requires connecting to your SQL table. In python, there are a number of ways to do this. For simplicity, I'm using the 'psycopg2' library: 

```python

import psycopg2

conn = psycopg2.connect(
    dbname="db_name",
    user="user_name",
    password="password",
    host="localhost",
    port="5432"
    )

```

Next, we want to configure a function that commits each API query to the database before moving onto the next. This looks like this: 

```python
import numpy as np
import pandas as pd
import praw

def get_submissions_from_subreddits(reddit, subreddits, conn):
    """Function to collect submissions given a list of subreddits

    Args:
        reddit (PRAW object): Authorization object from PRAW
        subreddits (list): list of subreddit strings from Reddit

    Returns:
        None (insert into psql table)
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

```

It is important to have your 'conn.commit()' call within the for loop to iterate the commits. In the particular example above, I actually commit each submission in each subreddit one after the other to the database, using ON CONFLICT (id) DO NOTHING in my SQL query to avoid loading duplicate submissions into the table. 

