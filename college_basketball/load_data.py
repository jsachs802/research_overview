from get_team_functions_adv import parse_table
from get_team_data import headers
from get_team_data import team_url
import pandas as pd
import json
import time

# NOTE: should provide full paths 

def get_data(pad: float):
    """
    Master function for requesting data. 
    Collects tables for each team and returns 
    a large dataframe.
    
    :param pad - float - number of seconds to sleep in between calls
    """
    # Load team_dict
    with open('team_dict.json', 'r', encoding='utf-8') as testfile:
        team_dict = json.load(testfile)

    # Iterate and grab tables from each team 
    team_dfs = []
    for key, value in team_dict.items():
        team_dfs.append(parse_table(headers=headers, team_dict=team_dict, team_name=key, base_url=team_url))
        time.sleep(pad)

    # Combine list into single table
    all_team_data = pd.concat(team_dfs, ignore_index=True)

    # Save large table as csv
    all_team_data.to_csv('#####', encoding='UTF-8', index=False)
    


