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

my_df <- filled[,c(1:2,34:43)]
library(DataExplorer)

plot_missing(my_df)
plot_histogram(my_df)

#investigate potential outliers and missingness
summary(my_df$RespRate)
my_df %>% filter(RespRate == 0)
#65 individuals have a respiratory rate of 0.
#since these are individuals in the ICU, a RespRate of 0 is deemed to be reasonable
#the maximum RespRate is 98
plot(my_df$RespRate)
#There are 3 individuals above 80, one is observed 3 times at 98 at different
my_df %>% filter(RespRate > 80) %>% nrow()
#These values are deemed to be reasonable

plot(my_df$SaO2)
summary(my_df$SaO2)
boxplot(my_df$SaO2)
hist(my_df$SaO2)
#Sa02 is fine with a range of 26-100

plot(my_df$SysABP)
summary(my_df$SysABP)
boxplot(my_df$SysABP)
hist(my_df$SysABP)
#Range of 0-295 which is deemed reasonable

summary(my_df$Temp[my_df$Temp < 32])
my_df %>% filter(Temp < 32) %>% nrow()
his
#going to filter out to only be above 32 because 32 C is the lower range for mild hypothermia
#Will remove 502 values, the max value is ok

summary(my_df$TroponinI) #values seem reasonable

summary(my_df$TroponinT) #have some outliers but I think given context it is reasonable

summary(my_df$Urine)

summary(my_df$WBC)
plot(my_df$WBC)
my_df %>% filter(WBC > 100) %>% View()

summary(my_df$Weight)
hist(my_df$Weight)
#300 kilos is 661 pounds... is that reasonable?

summary(my_df$pH)
#A ph of 735 is incorrect
my_df %>% filter(pH > 14 | pH < 4) %>% select(pH, subjid, Time) %>% View()
hist(my_df$pH)




cleaned <- my_df %>% 
  filter(Temp > 32,
         Weight > 0,
         pH < 14,
         pH > 3)



