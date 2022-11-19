library(tidyverse)

train <- read.csv("train.csv")
outcomes <- read.csv("outcomes.csv")

all_features_outcomes <- train %>% left_join(outcomes)

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

hour_dx_tab <- table(train_hr_min$hour, train_hr_min$in_hosp_death)
props <- vector(hour_dx_tab[,1] / (hour_dx_tab[,1] + hour_dx_tab[,2]))
hour_table <- cbind(hour_dx_tab, props)

