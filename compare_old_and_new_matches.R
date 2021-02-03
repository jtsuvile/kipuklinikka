library(tidyverse)
controls_old <- read_csv('/Users/juusu53/Documents/projects/kipupotilaat/data/age_and_gender_matched_subs_pain_helsinki_after_qc.csv')
controls_new <- read_csv('/Users/juusu53/Documents/projects/kipupotilaat/data/age_and_gender_matched_subs_pain_helsinki_18_11_2020.csv')

setdiff(controls_new$control_id, controls_old$control_id)

665343 %in% controls_new$control_id

# Looks like it works now!
