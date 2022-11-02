library(tidyverse)
library(ggplot2)

# read in the data
df_p90_p10 = read_csv("./data/p90-vs-p10-logs.csv")

# rename the columns
df_p90_p10 = df_p90_p10 %>% rename(
  "country" = "Entity",
  "code" = "Code",
  "year" = "Year",
  "p90" = "P90",
  "p10" = "P10",
  "population" = "Population (historical estimates)",
  "continent" = "Continent"
)