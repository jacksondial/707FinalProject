# ---
# title: "Data Cleaning"
# author: "Hannah Damico"
# date: '2022-11-10'
# ---

# Libraries
library(tidyverse)
library(magrittr)
library(finalfit)
library(flextable)
library(DataExplorer)


# getwd()
# setwd("/Users/hannahdamico/Desktop/F22/707 - Machine Learning/Project/Hannah's work")




# Read Data for columns [23:33]
data <-
  read.csv(
    here::here(
      "/Users/hannahdamico/Desktop/F22/707 - Machine Learning/707FinalProject/ADS.csv"
    )
  )
data <- data[, c(1, 23:33)]
sum(is.na(data)) # Total NA = 2727627 for columns 23-33

lab_cols <- colnames(data)[1:11]

filled <- data %>%
  group_by(subjid) %>%
  tidyr::fill(lab_cols, .direction = c("down"))

sum(is.na(filled)) # Total NA after imputing = 1,177,434

max(rowSums(is.na(filled))) # does not look too bad, max NA in a row = 11
mean(rowSums(is.na(filled))) # approx. 4 missing values per row on average

missing_per_row <- rowSums(is.na(filled))

average_missing_per_subjid <-
  filled %>% cbind.data.frame(missing_per_row) %>%
  group_by(subjid) %>%
  summarise(avg_missing_per_subjid = mean(missing_per_row))

# Distribution of Missing Values After Down Filling Imputation
average_missing_per_subjid %>% 
  ggplot() + 
  geom_histogram(aes(x = avg_missing_per_subjid), bins = 50) +
  ggtitle("Distribution of Missing Values After Down Filling Imputation") +
  theme_bw()


# ____________________________________________________________________________________________
#### ADDITIONAL MISSING DATA WORK & EDA ON COLUMNS 23-33

data_glimpse <- filled %>% ff_glimpse()

data_glimpse$Continuous %>%
  dplyr::select(-var_type, -n, -quartile_25, -quartile_75) %>%
  arrange(desc(missing_percent)) %>%
  flextable() %>%
  autofit() %>%
  set_caption("Continuous Missing Value Table")


# Dark means data is PRESENT, light blue is missing data
data.frame(filled) %>%
  missing_plot()

## REPORT:
data_glimpse$Continuous %>%
  filter(missing_percent < 75) %>%
  flextable() %>% autofit

plot_missing(data.frame(filled))

# ______________________
## Platelets (cells/nL)
## Missing %: 95.29
## Normal Range:
## Data Range: [6, 1047]
## Num. Outliers:
filled %>%
  ggplot() +
  geom_boxplot(aes(y = Platelets)) +
  ggtitle("Platetlet Measurement Distribution") +
  theme_bw()
# ______________________
## Lactate (mmol/L)
## Missing %: 51.62
## Normal Range:
## Data Range: [0.3, 29.3]
## Num. Outliers:
filled %>%
  ggplot() +
  geom_boxplot(aes(y = Lactate)) +
  ggtitle("Lactate Measurement Distribution") +
  theme_bw()
# ______________________
## MechVent [Mechanical ventilation respiration (0:false, or 1:true)]
## Missing %: 35.12
## Normal Range:
## Data Range: 1/NA
## Num. Outliers:
filled %>%
  ggplot() +
  geom_bar(aes(x = as.factor(MechVent)), stat = "count") +
  ggtitle("MechVent Measurement Distribution") +
  theme_bw()
table(filled$MechVent, exclude = "ifany")

## COMMENTS: All patients either use MV or reported NA, this makes some sense since
## we'd expect patients in the ICU to need extra help, but everyone?
## Might be an issue with the fill function, but OG data only reports 1/NA
# ______________________
## MAP [Invasive mean arterial blood pressure (mmHg)]
## Missing %: 31.23
## Normal Range: [70, 100] mm Hg
## Data Range: [0, 300]
## Num. Outliers:
filled %>%
  ggplot() +
  geom_boxplot(aes(y = MAP)) +
  ggtitle("MAP Measurement Distribution") +
  theme_bw()
## COMMENTS: over 100mmHg considered high, under 60mmHg considered low
# ______________________
## NIMAP [Non-invasive mean arterial blood pressure (mmHg)]
## Missing %: 27.92
## Normal Range: COULD NOT LOCATE
## Data Range: [0, 209]
## Num. Outliers:
filled %>%
  ggplot() +
  geom_boxplot(aes(y = NIMAP)) +
  ggtitle("Non-Invasive MIP Measurement Distribution") +
  theme_bw()
# ______________________
## NIDiasABP [Non-invasive diastolic arterial blood pressure (mmHg)]
## Missing %: 27.83
## Normal Range: [< 120 (normal), >= 130 (hypertension)]
## Data Range: [0, 201]
## Num. Outliers:
filled %>%
  ggplot() +
  geom_boxplot(aes(y = NIDiasABP)) +
  ggtitle("Non-Invasive Diastolic ABP Measurement Distribution") +
  theme_bw()
# ______________________
## NISysABP [Non-invasive systolic arterial blood pressure (mmHg)]
## Missing %: 27.56
## Normal Range: [<= 80 (normal), > 80 (hypertension)]
## Data Range: [0, 296]
## Num. Outliers:
filled %>%
  ggplot() +
  geom_boxplot(aes(y = NISysABP)) +
  ggtitle("Non-Invasive Systolic ABP Measurement Distribution") +
  theme_bw()
# ______________________
## PaO2 [Partial pressure of arterial O2 (mmHg)]
## Missing %: 27.22
## Normal Range: [75, 100]
## Data Range: [0, 500]
## Num. Outliers: table(filled$PaO2[filled$PaO2 < 75]); table(filled$PaO2[filled$PaO2 > 100])
filled %>%
  ggplot() +
  geom_boxplot(aes(y = PaO2)) +
  ggtitle("Partial pressure of arterial O2 (mmHg) Measurement Distribution") +
  theme_bw()
# ______________________
## PaCO2 [partial pressure of arterial CO2 (mmHg)]
## Missing %: 27.15
## Normal Range: [35, 45mmHg] / Also: [4.7, 6.0 kPa]
## Data Range: [0.3, 100]
## Num. Outliers: table(filled$PaCO2[filled$PaCO2 < 35]); table(filled$PaCO2[filled$PaCO2 > 45])
filled %>%
  ggplot() +
  geom_boxplot(aes(y = PaCO2)) +
  ggtitle("Partial pressure of arterial CO2 (mmHg) Measurement Distribution") +
  theme_bw()
# ______________________
## Mg [Serum magnesium (mmol/L)]
## Missing %: 21.37
## Normal Range: [0.85, 1.1]
## Data Range: [0.6, 9.9]
## Num. Outliers:
filled %>%
  ggplot() +
  geom_boxplot(aes(y = Mg)) +
  ggtitle("Serum magnesium (mmol/L) Measurement Distribution") +
  theme_bw()
## COMMENTS: Outliers are more dispersed outside upper limit
# ______________________
## Na [Serum sodium (mEq/L)]
## Missing %: 21.14
## Normal Range: [135, 145]
## Data Range: [98, 177]
## Num. Outliers:
filled %>%
  ggplot() +
  geom_boxplot(aes(y = Na)) +
  ggtitle("Serum sodium (mEq/L) Measurement Distribution") +
  theme_bw()
# ______________________
