rm(list = ls())
library(psych)
library(stats)
library(corrplot)
library(RColorBrewer)
#library(Hmisc)
library(tidyverse)

location <- '/Users/juusu53/Documents/projects/kipupotilaat/data/'
subs <- read_csv(paste(location, 'matched_controls_with_activations_19_10_2020.csv', sep='')) %>% 
  select(age, feels_pain, pain_0_pos_color, pain_1_pos_color,
         sensitivity_0_pos_color, sensitivity_1_pos_color, sensitivity_2_pos_color,
         feels_anxiety, feels_depression, feels_sad, 
         feels_happy, feels_angry, feels_fear,feels_surprise, feels_disgust) %>% 
  rename(current_pain = pain_0_pos_color,
         chronic_pain = pain_1_pos_color,
         tactile_sensitivity = sensitivity_0_pos_color,
         nociceptive_sensitivity = sensitivity_1_pos_color,
         hedonic_sensitivity = sensitivity_2_pos_color)

pain_duration <- read_csv2(paste(location, 'pain_start_helsinki_summer2019.csv', sep=''))
subs_pain <- read_csv(paste(location, 'all_pain_patients_with_activations_19_10_2020.csv', sep='')) %>% 
  select(subid, age, feels_pain, pain_0_pos_color, pain_1_pos_color,
         sensitivity_0_pos_color, sensitivity_1_pos_color, sensitivity_2_pos_color,
         feels_anxiety, feels_depression, feels_sad, 
         feels_happy, feels_angry, feels_fear,feels_surprise, feels_disgust) %>% 
  merge(pain_duration, by="subid", all.x=TRUE) %>% 
  rename(current_pain = pain_0_pos_color,
         chronic_pain = pain_1_pos_color,
         tactile_sensitivity = sensitivity_0_pos_color,
         nociceptive_sensitivity = sensitivity_1_pos_color,
         hedonic_sensitivity = sensitivity_2_pos_color) %>% 
  rename_with(str_replace,
              starts_with('feels'),
              pattern = 'feels',
              replacement = 'rating') %>% 
  select(-subid)

correlations <- corr.test(subs_pain)

color_palette <- brewer.pal(n = 11, name = "RdBu")

pdf('/Users/juusu53/Documents/projects/kipupotilaat/figures/smaller_correlations_pain_patients.pdf', width=10, height=7)
corrplot(correlations$r, p.mat = t(correlations$p), sig.level = .05, insig = "blank", 
         method='circle', type='lower',
         col = color_palette[11:1],tl.col = "black", tl.srt = 45,
         title= 'Pain patients',mar=c(0,0,1,0), diag=FALSE)
dev.off()

correlations2 <- corr.test(subs)
pdf('/Users/juusu53/Documents/projects/kipupotilaat/figures/smaller_correlations_matched_controls.pdf', width=10, height=7)
corrplot(correlations2$r, p.mat = t(correlations2$p), sig.level = .05, insig = "blank", 
         method='circle', type='lower',
         col = color_palette[11:1],tl.col = "black", tl.srt = 45,
         title= 'Matched controls',mar=c(0,0,1,0), diag=FALSE)
dev.off()
