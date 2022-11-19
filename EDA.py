import pandas as pd

from pandas_profiling import ProfileReport

df = pd.read_csv("/Users/KovicFamily/Documents/Duke MB/Courses/2022-2023 Courses/Fall 2022/BIOSTAT 707 - Stat Machine Learning/Final Project/707FinalProject/ADS.csv")
profile = ProfileReport(df)

profile.to_file("ProfiledDataset.html")
