library(tidyverse)
setwd('/Users/juusu53/Documents/projects/kipupotilaat/')
subs <- read.csv('data/all_pain_patients_with_activations_19_10_2020.csv',
                 na.strings = 'NaN')

pain_duration <- read_csv2('./data/pain_start_helsinki_summer2019.csv')
pain_type <- read_csv2('./data/kipuklinikka_kiputyyppi.csv', col_names=FALSE)
colnames(pain_type) <- c('pain_type','pain_comments','subid')

subs_with_info <- subs %>% left_join(pain_type, by='subid') %>% left_join(pain_duration, by='subid') %>% 
  select(-c(X, Unnamed..0))

subs_with_info %>% write_csv2('/Users/juusu53/Documents/projects/kipupotilaat/data/all_pain_patients_with_activations_and_pain_info_19_10_2020.csv')
