import pandas as pd
from pandas_profiling import ProfileReport

df = pd.read_csv("ADS.csv")
df_subset = df[["Age", "Gender", "Height", "ICUType", "Weight"]]

profile2 = ProfileReport(df_subset)

profile2.to_file("ProfiledDataset2.html")
