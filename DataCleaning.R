library(tidyverse)

data <- read.csv("ADS.csv")
sum(is.na(data))

lab_cols <- colnames(data)[3:43]

filled <- data %>% 
  group_by(subjid) %>% 
  tidyr::fill(lab_cols, .direction = c("down"))

sum(is.na(filled))

rowSums(is.na(filled)) # does not look too bad
mean(rowSums(is.na(filled))) #13.3 missing values per row on average

missing_per_row <- rowSums(is.na(filled))

average_missing_per_subjid <- filled %>% cbind.data.frame(missing_per_row) %>% 
  group_by(subjid) %>% 
  summarise(avg_missing_per_subjid = mean(missing_per_row))
#Grace is examining cols 1:11
#Caitlyn is examining cols 12:22
#Hannah is examining cols 23:33
#Jackson is examining cols 34:43

cleaned_dat <-filled %>%
  filter(Temp > 32,
         Weight > 0,
         pH < 14,
         pH > 3,
         Gender >= 0,
         Height > 100) %>% 
  mutate(height_cleaned = 
           case_when(
             Height > 205.7 ~ 205.7,
             TRUE ~ Height
             ),
         MechVent_cleaned = ifelse(is.na(MechVent), 0, MechVent)
         ) %>% 
  subset(select = -c(Height))  #remove height after cleaning it


