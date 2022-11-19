import pandas as pd


def read_data(filename=str):
    "Read outcome data text file"
    outcome_data = pd.read_table(filename, delimiter=",")
    return outcome_data


outcomes_df = read_data(
    "../FinalProjectData/mortality_prediction/mortality_prediction2/Outcomes-a.txt"
)
outcomes_df.to_csv("outcomes.csv")
