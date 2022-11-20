library(tidyverse)

train <- read.csv("train.csv")
outcomes <- read.csv("outcomes.csv") %>% rename(subjid = RecordID)
sum(is.na(outcomes$In.hospital_death))

all_features_outcomes <- train %>% left_join(outcomes, by = "subjid")
sum(is.na(all_features_outcomes$In.hospital_death))

train %>% left_join(outcomes) %>% nrow()

summary(all_features_outcomes)
all_features_outcomes %>% filter(in_hosp_death == 1, Survival <= 2) %>% distinct(subjid) %>% nrow()

train_hr_min <- train %>% mutate(hour = as.numeric(substring(Time, 1,2)),
                 minute = substring(Time, 4,5),
                 window_4 = case_when(
                   hour %in% 0:12 ~ 1,
                   hour %in% 13:24 ~ 2,
                   hour %in% 25:36 ~ 3,
                   hour %in% 37:48 ~ 4
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
## What is going on in the across thing
# train_hr_min %>% filter(subjid == 132547) %>% summarise(ALP)
# summary(train_hr_min$ALP)
# time_window_1 <- train_hr_min %>% filter(window_4 == 1)
# summary(time_window_1$ALP)
# time_window_2 <- train_hr_min %>% filter(window_4 == 2)
# summary(time_window_2$ALP)

# rownames_to_column() %>%
#   pivot_longer(, cols = -rowname) %>%
#   pivot_wider(, names_from = rowname) %>%
#   rename("category" = 1) %>%
#   as.data.frame()
# 
# id_cols = ID,
# names_from = Variable,
# values_from = Value
train_agg_alp <- train_agg %>% select(subjid, ALP, ALT, window_4)


outcome_in_hosp_death <- outcomes %>% select(subjid, In.hospital_death)
transposed <- train_agg %>% 
  pivot_wider(id_cols = subjid,
              names_from = window_4,
              values_from = ALP:MechVent_cleaned) 
#add in outcome var here^^

# 
# sum(is.na(transposed$in_hosp_death_4))
# sum(is.na(transposed$in_hosp_death_3))
# 
# #subjid 139045
# transposed %>% filter(is.na(in_hosp_death_4) == TRUE) %>% View()
