library(tidyverse)
#The purpose of this recode is to accommodate the non-sequential models that we will
# be using now that we know our outcome is also non-sequential
train <- read.csv("train.csv")
outcomes <- read.csv("outcomes.csv") %>% rename(subjid = RecordID)
sum(is.na(outcomes$In.hospital_death))

all_features_outcomes <- train %>% left_join(outcomes, by = "subjid")
sum(is.na(all_features_outcomes$In.hospital_death))


#The outcome has more ids than the training dataset
train %>% left_join(outcomes, by = "subjid") %>% nrow()

summary(all_features_outcomes)
all_features_outcomes %>% filter(in_hosp_death == 1, Survival <= 2) %>% distinct(subjid) %>% nrow()

train_hr_min <- train %>% mutate(hour = as.numeric(substring(Time, 1,2)),
                 minute = substring(Time, 4,5),
                 window_4 = case_when(
                   hour %in% 0:11 ~ 1,
                   hour %in% 12:23 ~ 2,
                   hour %in% 24:35 ~ 3,
                   hour %in% 36:48 ~ 4
                 ))
sum(is.na(train_hr_min$in_hosp_death))

###
hour_dx_tab <- table(train_hr_min$hour, train_hr_min$in_hosp_death)
props <- (hour_dx_tab[,1] / (hour_dx_tab[,1] + hour_dx_tab[,2]))
hour_table <- cbind(hour_dx_tab, props)
###

#When an individual doesn't have any observed values for that time window,
#the aggregated value will remain an NaN, but if they even have 1 value in
#the time window, that 1 number will be used as the average.
train_agg <- train_hr_min %>%
  group_by(window_4, subjid) %>% 
  mutate(across(ALP:MechVent_cleaned, ~ mean(.x, na.rm = TRUE))) %>% 
  distinct(subjid, window_4, .keep_all = TRUE)
sum(is.na(train_agg$in_hosp_death))  

outcome_in_hosp_death <- outcomes %>%
  select(subjid, In.hospital_death) %>% 
  distinct()

transposed_train <- train_agg %>% 
  pivot_wider(id_cols = subjid,
              names_from = window_4,
              values_from = ALP:MechVent_cleaned) %>% 
  left_join(outcome_in_hosp_death, by = "subjid")

sum(is.na(transposed_train$In.hospital_death)) #finally has 0 looks like we are good

write.csv(transposed_train, "train_recode.csv")
