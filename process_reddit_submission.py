import pandas as pd 
import psycopg2
from sqlalchemy import create_engine
import re
import sys
import pickle
from transformers import pipeline
import openai
# import logging

db_params = {
    "dbname": "####",
    "user": "####",
    "password": "####",
    "host": "####",
    "port": "####"
}


import pickle
with open("####", "rb") as f:
    keyword_dict = pickle.load(f)


# Function for checking if text is about wildfires    

# Credentials 
open_ai_key = "####"
project_id = "####"

# OpenAI client
client = openai.OpenAI(api_key=open_ai_key, project=project_id)


def predict_wildfire(text, client, keyword_dict):   
    response = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[
            {"role": "system", "content":"You are a classifier that only responds with 'True' or 'False'."},
            {"role": "system", "content":"The landscape of wildfire adaptation is shaped by a diverse array of beliefs, opinions, and strategies, reflecting the complexity of managing fire-prone environments. Concerns about air quality are prominent, as wildfire smoke poses significant health risks, particularly to vulnerable populations. Creating defensible space around homes is widely advocated as a critical strategy for reducing fire risk in the Wildland-Urban Interface (WUI), though it requires ongoing maintenance and community cooperation. Prescribed burns and other treatments, like forest thinning, are essential tools for reducing fuel loads, yet they spark debate due to the immediate risks they pose, potential air quality impacts, and differing views on their ecological effects. The U.S. Forest Service plays a central role in managing public lands and implementing fire adaptation strategies, but it often faces challenges related to funding, public perception, and the need for coordination with state, local, and tribal governments. Tribal lands, with their deep-rooted traditions of fire management, offer valuable insights into sustainable practices, though integrating these practices into broader land management plans can be complex. Overall, wildfire adaptation involves balancing immediate risk reduction with long-term ecological health, requiring collaboration and nuanced approaches across various stakeholders. There are also others who are skeptical of climate change or are influenced by misinformation about wildfires and wildfire adapatation. Further, some conservationists are so against removing trees that they are opposed to certain wildfire adaptation pracices and fuel treatment."},
            # {"role": "system", "content":f"The following keywords might be helpful in determining if the text is relevant to wildfires: {keyword_dict['keywords']}."},
            {"role": "user", "content": f"True or False, is this text about wildfires? {text}"}
        ]
    )
    return response.choices[0].message.content.strip() == 'True'



def predict_and_log(text, client, keyword_dict, counter):
    result = predict_wildfire(text, client, keyword_dict)
    counter[0] += 1
    return result


# Function for cleaning

def clean_data(df, keyword_dict):
    # Convert 'created' column to datetime and make it timezone-naive
    df['created'] = pd.to_datetime(df['created'], utc=True).dt.tz_localize(None)
    
    # Filter rows based on 'created' date
    start_date = pd.Timestamp('2022-09-01')
    end_date = pd.Timestamp('2024-02-29')
    df = df[(df['created'] >= start_date) & (df['created'] <= end_date)]

    # amount = ((chunksize - len(df)) / chunksize)*100
    # # Print number of rows removed
    # sys.stdout.write(f"Date filtering removed {amount:.2f}% of rows.\n")
    # df_size = len(df)
    
    # Remove rows with null, NA, or empty 'body' entries
    df = df.dropna(subset=['text'])
    df = df[df['text'].str.strip() != '']

    # amount = amount + (((df_size - len(df)) / chunksize)*100)

    # # Print number of rows removed
    # sys.stdout.write(f"{amount:.2f}% of rows dropped after removing rows with null, NA, or empty 'text' entries.\n")
    # df_size = len(df)
    
    # Clean 'body' entries
    df['text'] = df['text'].apply(lambda x: re.sub(r'\s+', ' ', x.strip()))

    # Remove any numbers or symbols, keeping only letters and punctuation
    df['text'] = df['text'].apply(lambda x: re.sub(r'[^a-zA-Z\s.,!?\'"-]', '', x))
    
    counter = [0]

    # Use LLM to predict if the text is about wildfires
    df = df[df['text'].apply(lambda x: predict_and_log(x, client, keyword_dict, counter))]
    
    # Print number of rows removed
    # sys.stdout.write(f"\r3. Keyword filtering removed {df_size - len(df)} rows.")
    # sys.stdout.flush()
    
    return df


# Create connections
conn = psycopg2.connect(**db_params)
engine = create_engine(f"postgresql+psycopg2://{db_params['user']}:{db_params['password']}@{db_params['host']}:{db_params['port']}/{db_params['dbname']}")


# Read and process data in chunks

# Query the total number of rows in the table
total_rows = pd.read_sql("SELECT COUNT(*) FROM reddit_submissions", engine).iloc[0, 0]

chunksize = 10000
# required_keyword_count = 1
# processed_rows = 0
# filtered_rows = 0
step = 0
# spinner = ["-", "\\", "|", "/"]
size = 0
for chunk in pd.read_sql("SELECT * FROM reddit_submissions", engine, chunksize=chunksize):
    cleaned_chunk = clean_data(chunk, keyword_dict)

    size += len(cleaned_chunk)

    # Insert cleaned data into the database
    cleaned_chunk.to_sql('clean_reddit_submissions', engine, if_exists='append', index=False)

    # Commit the transaction
    conn.commit()

    # Update processed rows and calculate progress 
    # processed_rows += len(chunk)
    # progress_percentage = (processed_rows / total_rows) * 100
    # filtered_rows += len(cleaned_chunk)
    # filtered_percentage = (filtered_rows / processed_rows) * 100

    # Progress messsaging
    # spinner_index = step % len(spinner)
    # sys.stdout.write(f"Progress: {progress_percentage:.2f}% -- Distilling {filtered_percentage:.2f}% of raw data -- {spinner[spinner_index]}")
    # sys.stdout.write(f"\r{filtered_rows} rows added to clean_reddit_submissions. Distilling {filtered_percentage:.2f}% of raw data.")
    sys.stdout.flush()
    step += 1
    sys.stdout.write(f"\r{size} total rows added to clean_reddit_submissions")
# Print new line to end
print("\n")
# Close the connection clea
conn.close()