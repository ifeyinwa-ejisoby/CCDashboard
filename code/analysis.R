library(tidyverse)
library(lme4)
library(broom)
library(survival)

# laod data
data <- readRDS(file = here::here("output", "original_data.rds")) # used for choropleth map
df <- readRDS(file = here::here("output", "clean_data.rds")) # used for survival analysis

#####

# Choropleth Maps for Geographic Distribution of Cases and Mortality Rate

# find number of cases per region
df_cases <- data %>%
  filter(AGE_ >= 40) %>%
  filter(FACILITY_LOCATION_CD != " ") %>% 
  group_by(YEAR_OF_DIAGNOSIS, FACILITY_LOCATION_CD) %>%
  summarise(cases = n(), .groups = "drop") 

# match facility location ID to states and regions
region_map <- data.frame(
  facility_location = c(
    rep(1,6),
    rep(2,3),
    rep(3,9),
    rep(4,5),
    rep(5,4),
    rep(6,7),
    rep(7,4),
    rep(8,8),
    rep(9,5)
  ),
  
  states = c("CT", "MA", "ME", "NH", "RI", "VT",
             "NJ", "NY", "PA",
             "DC", "DE", "FL", "GA", "MD", "NC", "SC", "VA", "WV",
             "IL", "IN", "MI", "OH", "WI",
             "AL", "KY", "MS", "TN", 
             "IA", "KS", "MN", "MO", "ND", "NE", "SD", 
             "AR", "LA", "OK", "TX", 
             "AZ", "CO", "ID", "MT", "NM", "NV", "UT", "WY", 
             "AK", "CA", "HI", "OR", "WA"),
  
  regions = c(
    rep("New England", 6),
    rep("Middle Atlantic", 3),
    rep("South Atlantic", 9),
    rep("East North Central", 5),
    rep("East South Central", 4),
    rep("West North Central", 7),
    rep("West South Central", 4),
    rep("Mountain", 8),
    rep("Pacific", 5))
) %>% 
  mutate(FACILITY_LOCATION_CD = as.character(facility_location)) %>% 
  select(-facility_location)

# calculate percent of cases per region
plot_df <- df_cases %>%
  group_by(YEAR_OF_DIAGNOSIS) %>%
  mutate(Percent = cases / sum(cases) * 100)

# join dataset
plot_df_full <- region_map %>%
  left_join(plot_df, by = "FACILITY_LOCATION_CD") %>% 
  mutate(`Year of Diagnosis` = YEAR_OF_DIAGNOSIS)


# calculate number of deaths by region
mort_df <- data %>%
  filter(AGE_ >= 40, FACILITY_LOCATION_CD != " ") %>%
  filter(PUF_VITAL_STATUS == "0") %>%
  group_by(YEAR_OF_DIAGNOSIS, FACILITY_LOCATION_CD) %>%
  summarise(deaths = n(), .groups = "drop")

# join dataset with df_cases
mort_df_ <- df_cases %>%
  left_join(mort_df, by = c("YEAR_OF_DIAGNOSIS", "FACILITY_LOCATION_CD")) %>%
  mutate(
    deaths = ifelse(is.na(deaths), 0, deaths),
    `Mortality Rate` = deaths / cases * 100
  )

# final dataset
mort_df_full <- region_map %>%
  left_join(mort_df_, by = "FACILITY_LOCATION_CD") %>%
  mutate(`Year of Diagnosis` = YEAR_OF_DIAGNOSIS) %>% 
  filter(`Year of Diagnosis` != "2022") # data not available for 2022

# save datasets for maps
saveRDS(plot_df_full, here::here("output", "map_data.rds"))
saveRDS(mort_df_full, here::here("output", "mort_map_data.rds"))

#####

# Forest Plot

# set reference 
df$STAGE <- factor(df$STAGE)

df_surgery <- df %>% 
  filter(RX_SUMM_SURG_PRIM_SITE %in% c("20", "30", "40", "50", "51",
                                      "52", "53", "54", "60", "61", "62"))

# fit proportional hazards model
cox_model <- coxph(Surv(OS, os_censor) ~ STAGE + AGE_ + TUMOR_SIZE_CM + LYMPH_VASCULAR_INVASION, 
                   data = df_surgery)
# clean model results
model_df <- tidy(cox_model, exponentiate = TRUE, conf.int = TRUE) %>% 
  filter(term %in% c("STAGEStage II", "STAGEStage III", "STAGEStage IV"))

model_df$term <- c("Stage II", "Stage III", "Stage IV")

# save data for forest plot
saveRDS(model_df, here::here("output", "survival_results.rds"))



#####

# Heatmap of Post-Operation Treatment

# format data into long
treatment_long <- df_surgery %>%
  select(
    STAGE,
    DX_RAD_STARTED_DAYS,
    DX_CHEMO_STARTED_DAYS,
    DX_HORMONE_STARTED_DAYS,
    DX_IMMUNO_STARTED_DAYS
  ) %>%
  pivot_longer(
    cols = starts_with("DX_"),
    names_to = "treatment",
    values_to = "days_to_start") %>%
  mutate(
    treatment = case_when(
      treatment == "DX_RAD_STARTED_DAYS" ~ "Radiation",
      treatment == "DX_CHEMO_STARTED_DAYS" ~ "Chemotherapy",
      treatment == "DX_HORMONE_STARTED_DAYS" ~ "Hormone Therapy",
      treatment == "DX_IMMUNO_STARTED_DAYS" ~ "Immunotherapy",
      TRUE ~ treatment),
    received = ifelse(days_to_start == "", 0, 1))

# calculate frequency within each age group
treatment_summary <- treatment_long %>%
  group_by(STAGE, treatment) %>%
  summarise(
    n = sum(received, na.rm = TRUE),
    total = n(),
    Percent = n / total * 100,
    .groups = "drop"
  )

# refactor treatment variable
treatment_summary$treatment <- factor(
  treatment_summary$treatment,
  levels = c("Radiation",
             "Chemotherapy",
             "Immunotherapy",
             "Hormone Therapy"
  )
)

# save dataset
saveRDS(treatment_summary, here::here("output", "treatment_summary.rds"))
