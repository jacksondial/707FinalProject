library(tidyverse)
#The purpose of this recode is to accommodate the non-sequential models that we will
# be using now that we know our outcome is also non-sequential
test <- read.csv("test.csv")
outcomes <- read.csv("outcomes.csv") %>% rename(subjid = RecordID)
sum(is.na(outcomes$subjid))

test_hr_min <- test %>% mutate(hour = as.numeric(substring(Time, 1,2)),
                                 minute = substring(Time, 4,5),
                                 window_4 = case_when(
                                   hour %in% 0:11 ~ 1,
                                   hour %in% 12:23 ~ 2,
                                   hour %in% 24:35 ~ 3,
                                   hour %in% 36:48 ~ 4
                                 ))
sum(is.na(test_hr_min$in_hosp_death))


test_agg <- test_hr_min %>%
  group_by(window_4, subjid) %>% 
  mutate(across(ALP:MechVent_cleaned, ~ mean(.x, na.rm = TRUE))) %>% 
  distinct(subjid, window_4, .keep_all = TRUE)
sum(is.na(test_agg$in_hosp_death))  


outcome_in_hosp_death <- outcomes %>%
  select(subjid, In.hospital_death) %>% 
  distinct()

transposed_test <- test_agg %>% 
  pivot_wider(id_cols = subjid,
              names_from = window_4,
              values_from = ALP:MechVent_cleaned) %>% 
  left_join(outcome_in_hosp_death, by = "subjid")
sum(is.na(transposed_test$In.hospital_death))

write.csv(transposed_test, "test_recode.csv")
