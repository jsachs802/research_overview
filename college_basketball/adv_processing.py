import pandas as pd
import numpy as np


# Function to keep only duplicate games
def only_duplicates(df):
    duplicate_games = df['game_id'][df['game_id'].duplicated()] # list of duplicate game_ids
    df = df[df['game_id'].isin(duplicate_games)] # remove games without duplicates
    return df


# Function to convert percentages
def convert_percentages(df): 
    # Divide metrics that are on the 0 to 100 scale to 
    # 0 to 1 scale.
    conversions = ['trb_perc', 'ast_perc', 'stl_perc', 'blk_perc',
                     'tov_perc', 'orb_perc',]
    
    df[conversions] = df[conversions] / 100

    return df


# Function to create matchups
def convert_to_matchups(df):
    # Turn individual team data into matchup rows based on game_id

    opponent_features = ['pts', 'opp_pts', 'ortg', 'drtg', 'pace', 
                         'ftr','3par', 'ts_perc', 'trb_perc', 
                     'ast_perc', 'stl_perc', 'blk_perc','efg_perc', 
                     'tov_perc', 'orb_perc', 'ft_fga', 'srs', 'sos', 'wins', 
                     'losses', 'streak', 'game_id',]

    new_opp_feat_names_dict = {'pts': 'opp_pts_self', 
                               'opp_pts': 'opp_pts_team', 
                               'ortg': 'opp_ortg',
                               'drtg': 'opp_drtg',
                               'pace': 'opp_pace',
                               'ftr': 'opp_ftr', 
                               '3par': 'opp_3par',
                               'ts_perc': 'opp_ts_perc',
                               'trb_perc': 'opp_trb_perc',
                               'ast_perc': 'opp_ast_perc',
                               'stl_perc': 'opp_stl_perc',
                               'blk_perc': 'opp_blk_perc',
                               'efg_perc': 'opp_efg_perc',
                               'tov_perc': 'opp_tov_perc',
                               'orb_perc': 'opp_orb_perc', 
                               'tov_perc': 'opp_tov_perc',
                               'orb_perc': 'opp_orb_perc',
                               'ft_fga': 'opp_ft_fga',
                               'srs': 'opp_srs', 
                               'sos': 'opp_sos',
                               'wins': 'opp_wins', 
                               'losses': 'opp_losses', 
                               'streak': 'opp_streak',}
    
    list_of_matchups = []
    for i, id in enumerate(df['game_id'].unique()):
        
        order = list(np.random.randint(0,2,1))   
        if order[0] == 1: 
            order.append(0)
        else: 
            order.append(1)
            
        team_row = df[df['game_id'] == id].iloc[order[0]].to_frame().T # Team stats
        opp_row = df[opponent_features][df['game_id'] == id].iloc[order[1]].to_frame().T # Gets opponent features 
        opp_row = opp_row.rename(columns=new_opp_feat_names_dict) # new column names
        # opp_row = opp_row.drop('opp_pace', axis=1)
        new_row = pd.merge(team_row, opp_row, on='game_id', how='inner') # merge team and opponent data
        list_of_matchups.append(new_row) # add row to matchup list

    match_up_df = pd.concat(list_of_matchups)

    return match_up_df