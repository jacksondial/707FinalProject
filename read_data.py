import pandas as pd
import os


def read_data(filename=str):
    "Read data from a specified text file"
    pat_id = filename.rsplit("/", 1)[1].split(".")[
        0
    ]  # get the filename to add as subjid column
    data = pd.read_table(filename, delimiter=",")
    data = data.iloc[1:, :]  # removefirst line as it is a weird second header
    data["subjid"] = pd.Series(
        [pat_id for x in range(len(data.index) + 1)]
    )  # add new subjid column
    return data


appended_data = []
with os.scandir(
    "../FinalProjectData/mortality_prediction/mortality_prediction2/set-a/"
) as entries:  # grab all of the filenames which are the subjids
    for entry in entries:
        single_data = read_data(
            f"../FinalProjectData/mortality_prediction/mortality_prediction2/set-a/{entry.name}"
        )

        appended_data.append(single_data)
    appended_data_concat = pd.concat(appended_data)  # rbind all the dataframes

    new_df = appended_data_concat.pivot_table(
        index=["subjid", "Time"], columns="Parameter", values="Value"
    )  # transpose the data from long format to wide format
    new_df.to_csv("ADS.csv")  # export data to csv file in current directory
    # print(new_df.head(10))

# print(read_data("Data/mortality_prediction/mortality_prediction2/set-a/132539.txt"))
