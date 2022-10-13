import pandas as pd
import os


def read_data(filename=str):
    pat_id = filename.rsplit("/", 1)[1].split(".")[0]
    data = pd.read_table(filename, delimiter=",")
    data = data.iloc[1:, :]
    data["subjid"] = pd.Series([pat_id for x in range(len(data.index) + 1)])
    return data


appended_data = []
with os.scandir(
    "../FinalProjectData/mortality_prediction/mortality_prediction2/set-a/"
) as entries:
    for entry in entries:
        single_data = read_data(
            f"../FinalProjectData/mortality_prediction/mortality_prediction2/set-a/{entry.name}"
        )

        appended_data.append(single_data)
    appended_data_concat = pd.concat(appended_data)

    new_df = appended_data_concat.pivot_table(
        index=["subjid", "Time"], columns="Parameter", values="Value"
    )
    new_df.to_csv("ADS.csv")
    # print(new_df.head(10))

# print(read_data("Data/mortality_prediction/mortality_prediction2/set-a/132539.txt"))
