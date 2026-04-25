library(haven)
library(tidyverse)

# load data
data <- read_sas('/Users/ifynwosu/Desktop/DATA 555/data.sas7bdat')

# clean data
df <- data %>% 
  filter(PATH_STAGE_GROUP != 88 &
           PATH_STAGE_GROUP != 99 &
           PATH_STAGE_GROUP != "Unk") %>% 
  filter(FIGO_STAGE %in% c("1", "1A", "1A1", "1A2", 
                           "1B", "1B1", "1B2", 
                           "2", "2A", "2A1", "2A2", "2B", 
                           "3", "3A", "3B", 
                           "4", "4A", "4B")) %>%
  filter(PUF_VITAL_STATUS %in% c("0", "1")) %>% 
  filter(LYMPH_VASCULAR_INVASION %in% c("0", "1")) %>% 
  mutate(STAGE = case_when(
    FIGO_STAGE %in% c("1", "1A", "1A1", "1A2", "1B", "1B1", "1B2") ~ "Stage I",
    FIGO_STAGE %in% c("2", "2A", "2A1", "2A2", "2B") ~ "Stage II",
    FIGO_STAGE %in% c("3", "3A", "3B") ~ "Stage III", 
    FIGO_STAGE %in% c("4", "4A", "4B") ~ "Stage IV"), 
    VITAL_STATUS = as.numeric(PUF_VITAL_STATUS),
    AGE_GROUP = case_when(
      AGE_ < 40 ~ "<40",
      AGE_ >= 40 & AGE_ < 50 ~ "40-49",
      AGE_ >= 50 & AGE_ < 60 ~ "50-59",
      AGE_ >= 60 & AGE_ < 70 ~ "60-69",
      AGE_ >= 70 ~ ">=70"
    ))

# save data
saveRDS(data, here::here("output", "original_data.rds"))
saveRDS(object = df, file = here::here("output","clean_data.rds"))
