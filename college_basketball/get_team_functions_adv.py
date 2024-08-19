
### FUNCTIONS FOR GETTING AND PREPROCESSING TEAM DATA
from get_team_data import new_adv_gl_names
from get_team_data import old_adv_gl_names
from get_team_data import new_s_names
from get_team_data import schedule_sel
import pandas as pd
import numpy as np

# Function to rename columns in table
def rename_columns(df, features: list, team_name: str, type='gamelogs'):
    """
    Generate new column names for pulled tables 

    :params 
        df - team_df 
        orig_names - list of original variables names 
        new_names - list of new variables names 
    :return
        df - team_df data frame with new names
    """

    if type == 'gamelogs':
        # Flatten multilevel columns 
        df.columns = [col[0] + '_' + col[1] for col in df.columns]
        
    new_col_dict = {} # create empty dictionary for names

    # create dictionary, original(keys), new(values)
    for orig, new in zip(df.columns, features):
        new_col_dict[orig] = new

    # Use dictionary to change column names 
    df = df.rename(columns=new_col_dict)

    # Add team name variable
    df['school'] = team_name
    
    # return dataframe
    return df


# Function that fixes data types for df variables
def fix_data_types(df, new_names, type='schedule'):
    """
    Input data frame, correct variable types

    :params 
        df - input df 
        type - type of table 

    :return df
    """
    if type == 'schedule':
        convert_dict={
            'game': int,
            'srs': float,
            'pts': int,
            'opp_pts': int,
            'wins': int,
            'losses': int}

        df = df.astype(convert_dict)
        df['date'] = pd.to_datetime(df['date'])
    else:
        df[new_names[0]] = df[new_names[0]].apply(pd.to_numeric)
        df[new_names[5:]] = df[new_names[5:]].apply(pd.to_numeric)
        df['date'] = pd.to_datetime(df['date'])

    return df


def change_values(df, type='schedule'):
    """
    Change some variable values to appropriate values 
    Ex. W/L - O,1

    :params
        df - dataframe
        type - table type
    :return - dataframe with corrected values
    """
    # Making overtimes numerical 
    if type == 'schedule':
        over_map = {
        'OT': '1',
        '2OT': '2',
        '3OT': '3', 
        '4OT': '4',
        }
        # map the legend
        df['overtimes'] = df['overtimes'].map(over_map)

         # fill in nas 
        df['overtimes'] = df['overtimes'].fillna(0)

        # convert to numerical  
        df['overtimes'] = df['overtimes'].astype(int)

    # Making streaks numerical
    if type == 'schedule':
        df['streak'] = [-int(value[1]) if value[0] == "L" else int(value[1]) for value in df['streak'].apply(str.split)]

    # Making game result 0,1 
    df['game_result'] = [value[0] if len(value) > 1 else value for value in df['game_result']]
    df['game_result'] = df['game_result'].map({'W': 1, 'L': 0})

    # Making location dummies
    # fill in na locations 
    df['game_location'] = df['game_location'].fillna('h')
    # # create new map
    # loc_map = {
    #     'h': 'home',
    #     'N': 'neutral',
    #     '@': 'away',
    # }
    # df['game_location'] = df['game_location'].map(loc_map)
    
    # # create dummies 
    # df = pd.get_dummies(df, columns = ['game_location'], drop_first=True)

    # # rename dummies
    # df = df.rename(columns={'game_location_home': 'home', 'game_location_away': 'away'})


    return df


# Function to select and clean tables
def select_table(df, team_name: str, features: list, new_names: list, type='schedule'):
    """
    Index table and remove missing values/future games

    :params 
        df - data_frame to be cleaned 
        team_name: dictionary key
        type: type of table

    :return - df - preprocessed dataframe
    """
    if type == 'schedule':
        # Index correct table
        df = df[1]

        # Change column names 
        df = rename_columns(df=df, features=features, team_name=team_name, type='schedule')
        # team_df['School'] = team_name
        df = df[df['game_result'].notnull()]  # remove games that haven't been played yet
        # Fix data types
        df = fix_data_types(df=df, new_names=new_names, type='schedule')


    else:
        df = df[0] # Index correct table

        # Change column names
        df = rename_columns(df=df, features=features, team_name=team_name, type='gamelogs')

        df = df[df['date'].notnull()]  # remove table split
        df = df[df['date'] != 'Date']  # remove table split columns
        df = df[df['game_result'].notnull()]  # remove values for games that haven't been played

        # Fix data types
        df = fix_data_types(df=df, new_names=new_names, type='gamelogs')

    return df


def subset_tables(df, columns):
    """
    Input a data frame and get back a dataframe with a subset of the columns

    :params
        df - dataframe 
        columns - list of column strings
        type - type of table
    :return - subset df 
    """
    df = df[columns]
    return df


# Function that gets table and cleans the table
def load_clean(url: str, type: str, team_name: str, game_log_names=new_adv_gl_names, schedule_names=new_s_names, schedule_cols=schedule_sel):
    """
    Input url and get clean table for team

    :param - team url 
    :return - team table 
    """
    team_df = pd.read_html(url)

    from get_team_data import old_s_names 
    from get_team_data import old_adv_gl_names

    if type == "schedule":
        # Select and preprocess table
        team_df = select_table(df=team_df, team_name=team_name, features=old_s_names, new_names=schedule_names, type='schedule')

        # # Create game_id for merging and filtering duplicates
        # team_df = create_game_id(team_df)

        # Convert non-numerical values 
        team_df = change_values(df=team_df, type='schedule')
       
        # Subset data to needed columns
        team_df = subset_tables(df=team_df, columns=schedule_cols)
    

    else:
        # Select and preprocess table
        team_df = select_table(df=team_df, team_name=team_name, features=old_adv_gl_names, new_names=game_log_names, type='gamelogs')
        
        # # Create game_id for merging and filtering duplicates
        # team_df = create_game_id(team_df)

        # Convert non-numerical values 
        team_df = change_values(df=team_df, type='gamelogs')

        # # Subset data to needed columns
        # team_df = subset_tables(df=team_df, columns=game_log_cols)


    return team_df


def parse_table(headers: dict, team_dict: dict, team_name: str, base_url: str, game_log_names=new_adv_gl_names, schedule_names=new_s_names):
    """
    Get table rows from specified table - 'schedule', and 'gamelogs'
    (sgl-basic)

    :params
        headers: dict of headers that mimic a browser request
        team_name: string url section or short team name
        id = string id of table
        team_url = string base url for tables
    :return
        team_data = list with pandas dataframe object appended
    """

    # Generate url for specified table 
    sched_url = base_url + team_dict[team_name] + '2023-schedule.html'
    game_log_url = base_url + team_dict[team_name] + '2023-gamelogs-advanced.html'
    print(sched_url)
    print(game_log_url)
    # Load data and clean 
    # Get schedule table data
    schedule_table = load_clean(url=sched_url, type='schedule', team_name=team_name)
    # Get game log table data
    game_log_table = load_clean(url=game_log_url, type='gamelogs', team_name=team_name)

    # Merge both tables on game id
    merged_df = pd.merge(game_log_table, schedule_table, how='inner', on='game') # inner merge with pandas 

    return merged_df
