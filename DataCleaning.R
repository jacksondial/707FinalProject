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
