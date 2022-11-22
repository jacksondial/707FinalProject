import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv("ADS.csv")
# plt.hist(df["Age"], color="blue", edgecolor="black", bins=10)

# plt.title("Histogram of Age")
# plt.xlabel("Age")
# plt.ylabel("Frequency")
# plt.show()


plt.bar(df["ICUType"], color="blue", edgecolor="black", bins=10)

plt.title("Barplot of ICU Type")
plt.xlabel("ICU Type")
plt.ylabel("Frequency")
plt.show()
