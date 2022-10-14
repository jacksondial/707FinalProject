import pandas as pd
from pandas_profiling import ProfileReport

df = pd.read_csv("ADS.csv")
profile = ProfileReport(df)

profile.to_file("ProfiledDataset.html")
