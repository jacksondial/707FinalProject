library(tidyverse)
library(caTools)
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

write.csv(cleaned_dat, "FinalDF.csv")

library(DataExplorer)
plot_missing(cleaned_dat)

subjid_uniques <- unique(cleaned_dat$subjid)

set.seed(11022009)

sample <- sample.split(subjid_uniques, SplitRatio = 0.7)
table(sample)
train_no_outcome <- cleaned_dat %>% filter(subjid %in% subjid_uniques[sample])
test_no_outcome <- cleaned_dat %>% filter(!(subjid %in% subjid_uniques[sample]))

#check the numbers of rows
train_no_outcome %>% inner_join(test_no_outcome, by = "subjid") %>% nrow()
cleaned_dat %>% distinct(subjid) %>% nrow()

outcomes_df <- read.csv("outcomes.csv")
outcomes_to_join <- outcomes_df %>% select(RecordID, In.hospital_death) %>% rename(subjid = RecordID, in_hosp_death = In.hospital_death)

train <- train_no_outcome %>%
  left_join(outcomes_to_join)

test <- test_no_outcome %>% 
  left_join(outcomes_to_join)

write.csv(train, "train.csv")
write.csv(test, "test.csv")



