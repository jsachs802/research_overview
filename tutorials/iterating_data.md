Back to [Main Page](https://github.com/jsachs802/research_overview/blob/main/README.md)

'''python

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

'''

