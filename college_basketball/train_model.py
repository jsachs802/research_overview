import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import GridSearchCV
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.compose import ColumnTransformer 
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import MinMaxScaler
from sklearn.neighbors import NearestNeighbors


## Functions for training and tuning learning model

# Function to split data into training and test data
def split_data_to_test(df, date: str, type='train'):
    if type == 'train':
        data = df[df['date'] < date]
    else: 
        data = df[df['date'] >= date]
    return data



# Standardization Pipeline
# Create a pipeline for numerical features
num_transformer = Pipeline(steps=[('scaler', StandardScaler())]) 

# Create a column transformer to apply different transformations to different columns
preprocessor = ColumnTransformer(
    transformers=[
        ('num', num_transformer, ['pace', 'ftr','3par', 'ts_perc', 
                                  'trb_perc', 'ast_perc', 'stl_perc', 'blk_perc',
                                'efg_perc', 'tov_perc', 'orb_perc', 'ft_fga', 'opp_pace',
                                'opp_ftr', 'opp_3par', 'opp_ts_perc', 'opp_trb_perc', 'opp_ast_perc',
                                'opp_stl_perc', 'opp_blk_perc', 'opp_efg_perc', 'opp_tov_perc',
                                'opp_orb_perc', 'opp_ft_fga'])
        ], 
        remainder='passthrough'
    )  


# Function that trains and tests model
def learn_from_data(df, process=preprocessor):
    X = df.drop('game_result', axis=1)
    y = df['game_result']
    y = y.astype('int')

    # split, train, test 
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, shuffle=False, random_state=235)


    # Scale Training Data
    X_train_scaled = process.fit_transform(X_train) # Scale Data
    
    # Transform Test data 
    X_test_scaled = process.transform(X_test) # Scale Data


    # Define the hyperparameters to use with GridSearchCV
    param_grid = {
        'n_estimators': [64, 100, 128, 200],
        'max_depth': [None, 5, 10],
        'min_samples_split': [2, 5, 10],
        'min_samples_leaf': [1, 2, 4],
        'max_features': ['sqrt', 'log2'],
        'bootstrap': [True, False], 
        'oob_score': [True, False]
    }

    # Define Random Forest Classifier 
    rfc = RandomForestClassifier()

    # Define Grid Search CV
    grid = GridSearchCV(rfc, param_grid)

    # Fit Grid Search
    grid.fit(X_train_scaled, y_train)  


    # Evaluate performance of Random Forests Model 
    from sklearn.metrics import classification_report

    predictions = grid.predict(X_test_scaled)
    print(classification_report(y_test, predictions))   

    return grid


# Normalization processor
# Create a pipeline for numerical features
num_transformer2 = Pipeline(steps=[('scaler', MinMaxScaler(feature_range=(0,1)))])

# Create a column transformer to apply different transformations to different columns
preprocessor2 = ColumnTransformer(
    transformers=[
            ('num', num_transformer2, ['pace', 'ftr','3par', 'ts_perc', 
                                  'trb_perc', 'ast_perc', 'stl_perc', 'blk_perc',
                                'efg_perc', 'tov_perc', 'orb_perc', 'ft_fga', 'srs',
                                'wins', 'losses', 'streak'])
        ], 
    remainder='passthrough'
    )


# Function for nearest neighbor similarity 
def get_nearest_neighbors(df, k: int, process=preprocessor2):
    
    df = df[['pace', 'ftr', '3par', 'ts_perc', 'trb_perc', 'ast_perc', 'stl_perc', 'blk_perc', 
                 'efg_perc', 'tov_perc', 'orb_perc', 'ft_fga', 'srs', 'wins', 'losses', 'streak']] # Subset df to wanted features

    # Use pipeline to scale numerical data Use sklearn.preprocessing MinMaxScaler
    # scaler = MinMaxScaler(feature_range=(0,1))
    df = process.fit_transform(df)

    # Fit NearestNeighbors with k neighbors (k number of similar matchups

    knn = NearestNeighbors(n_neighbors=k) # 10 most similar neighbors 

    knn.fit(df) # Fit matchup stats  

    return knn


# Function that normalizes 
def get_norm_team_stats(df, process=preprocessor2):

    season_stats_dict = {}
    for name in df['school'].unique():
        dataframe = df[df['school'] == name]
        dataframe = dataframe[['pace', 'ftr', '3par', 'ts_perc', 'trb_perc', 'ast_perc', 'stl_perc', 'blk_perc', 
                 'efg_perc', 'tov_perc', 'orb_perc', 'ft_fga', 'srs', 'wins', 'losses', 'streak']]
        dataframe = process.transform(dataframe)
        season_stats_dict[name] = dataframe
    
    return season_stats_dict


# Function to create matchup sample of main df 
def get_matchup_sample(team_a: str, team_b: str, season_stats_dict, df, knn, k):
    
    distances_a, indices_a = knn.kneighbors(season_stats_dict[team_a]) # get distances and indices for team a
    distances_b, indices_b = knn.kneighbors(season_stats_dict[team_b]) 

    similar_teams = [] # similar teams to team_a
    for i, indx in enumerate(indices_a): 
        similar_teams.extend(list(indx[1:(k+1)]))

    similar_opps = []
    for i, indx in enumerate(indices_b): 
        similar_opps.extend(list(indx[1:(k+1)]))

    # Game ids that involve both teams
    similar_game_ids = [x for x in list(df['game_id'].iloc[similar_teams]) if x in list(df['game_id'].iloc[similar_opps])]

    similar_school_df = df.iloc[similar_teams] # df subset by teams similar to team_a
    # subset of teams similar that have game_ids in similar_game_ids
    similar_df = similar_school_df[similar_school_df['game_id'].isin(similar_game_ids)]
    # drop duplicate games if they exist
    similar_df = similar_df.drop_duplicates()

    return similar_df


# # Function to create matchup format df
# def sim_convert_to_matchups(df):
#     # Turn individual team data into matchup rows based on game_id

#     opponent_features = ['pace', 'ftr','3par', 'ts_perc', 'trb_perc', 
#                      'ast_perc', 'stl_perc', 'blk_perc','efg_perc', 
#                      'tov_perc', 'orb_perc', 'ft_fga', 'srs', 'wins', 
#                      'losses', 'streak', 'game_id',]

#     new_opp_feat_names_dict = {'pace': 'opp_pace',
#                            'ftr': 'opp_ftr', 
#                            '3par': 'opp_3par',
#                            'ts_perc': 'opp_ts_perc',
#                            'trb_perc': 'opp_trb_perc',
#                            'ast_perc': 'opp_ast_perc',
#                            'stl_perc': 'opp_stl_perc',
#                            'blk_perc': 'opp_blk_perc',
#                            'efg_perc': 'opp_efg_perc',
#                            'tov_perc': 'opp_tov_perc',
#                            'orb_perc': 'opp_orb_perc', 
#                            'tov_perc': 'opp_tov_perc',
#                            'orb_perc': 'opp_orb_perc',
#                            'ft_fga': 'opp_ft_fga',
#                            'srs': 'opp_srs', 
#                            'wins': 'opp_wins', 
#                            'losses': 'opp_losses', 
#                            'streak': 'opp_streak',}
    
#     list_of_matchups = []
#     for id, school in zip(df['game_id'], df['school']):
#         team_row = df[(df['game_id'] == id) & (df['school'] == school)]
#         opp_row = df[opponent_features][(df['game_id'] == id) & (df['opp_team_id'] != school)] # Gets opponent features 
#         opp_row = opp_row.rename(columns=new_opp_feat_names_dict) # new column names
#         new_row = pd.merge(team_row, opp_row, on='game_id', how='inner') # merge team and opponent data
#         list_of_matchups.append(new_row) # add row to matchup list

#     match_up_df = pd.concat(list_of_matchups)

#     return match_up_df


# # Function which puts data in matchup format, drops unneeded features and normalizes data
# def process_matchups_for_model(df, process=preprocessor2):
#     sample_df = sim_convert_to_matchups(df) # Convert to matchup format
#     # remove features that don't go in model
#     sample_df = sample_df.drop(['game', 'game_result', 'date', 'school', 'opp_team_id', 'game_id'], axis=1)
#     # scale data
#     sample_df_scaled = process.transform(sample_df)

#     return sample_df_scaled


# Function that bootstrap samples similar matchups n times 
# and generates a predicted probability of team_a winning
def simulate_and_predict(df, model, n: int):
    n_simulations = n
    simulated_outcomes = []

    for i in range(n_simulations):
        random_row = np.random.choice(df.shape[0])
        matchup = df[random_row]
        outcome = model.predict(matchup.reshape(1, -1))
        simulated_outcomes.append(outcome)

    team_win_prob = np.mean(simulated_outcomes)

    return team_win_prob


# FOR SUMMARIZING DATA
# Function that returns one if positive cases 
# account for at least half the scenarios

def prediction_binary(pred):
    """Summarizes predictions as a 1 or 0 
    by taking the positive count over the total"""
    percentage_pos = np.sum(pred)/len(pred)

    if percentage_pos > 0.5: 
        return 1
    else: 
        return 0
    


# Function that creates data for training or for historical prediction purposes
def transform_data(df, k: int):
    list_of_games = []
    for game, team, id in zip(df['game'], df['school'], df['game_id']):
        if game <= k:
            continue
        else: 
            current_stats = df[['game', 'date', 'game_result', 'school', 'opp_team_id', 'home', 'away', 'srs', 'sos']][(df['school'] == team) & (df['game'] == game)]
            current_stats['game_id'] = id
            as_of_last_game = df[['streak', 'wins', 'losses']][(df['school'] == team) & (df['game'] == (game - 1))]
            as_of_last_game['game_id'] = id
            average_of_last_k = df[['pace', 'pts', 'opp_pts', 'ortg', 'drtg', 'ftr', '3par', 'ts_perc', 'trb_perc', 'ast_perc', 'stl_perc', 
                'blk_perc', 'efg_perc', 'tov_perc', 'orb_perc', 'ft_fga', 'overtimes']][(df['game'] >= (game - k)) & (df['game'] < game) & (df['school'] == team)].mean().to_frame().T
            average_of_last_k['game_id'] = id
            merged_row = pd.merge(pd.merge(current_stats, as_of_last_game, on='game_id'), average_of_last_k, on='game_id')
            list_of_games.append(merged_row)
            
    df = pd.concat(list_of_games) # merge list into df
    return df