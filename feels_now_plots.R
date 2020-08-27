# rm(list = ls())
library(psych)
library(stats)
library(corrplot)
library(RColorBrewer)
library(tidyverse)

location <- '/Users/juusu53/Documents/projects/kipupotilaat/data/'
subs <- read.csv(paste(location, 'bg_pain_stockholm_with_activations_03_2020.csv', sep=''))

pain_duration <- read.csv(paste(location, 'diagnoses_KI_12_2019_no_empty_cells.csv', sep=''), sep=";", header=FALSE)
colnames(pain_duration) <- c('date','sex','pain_type','num','subid','dob')
subs <- merge(subs, pain_duration, by="subid", all.x=TRUE)

interesting_variables <- c("feels_pain", "feels_depression", "feels_anxiety", "feels_happy", "feels_sad", 
                           "feels_angry", "feels_fear", "feels_surprise", "feels_disgust")

plot_data_long <- subs %>% select('subid','pain_type',interesting_variables) %>% 
  pivot_longer(cols="feels_pain":"feels_disgust", names_to = 'feeling') %>% 
  mutate(feeling = str_remove(feeling, 'feels_'))

plot_data_summary <- plot_data_long %>% group_by(feeling, pain_type) %>% 
  summarise(mean = mean(value), sd = sd(value), se=sd(value)/sqrt(n())) %>% 
  ungroup()

pd <- position_dodge(0.1)

p1 <- ggplot(plot_data_summary, aes(x=feeling, y=mean, color=pain_type, group=pain_type)) + 
  geom_jitter(data=plot_data_long, aes(x=feeling, y=value), alpha=0.3) + 
  geom_errorbar(aes(ymin=mean-se, ymax=mean+se), width=.2, position=pd, color='black') +
  geom_point(size=3, position=pd) + 
  geom_line(position=pd, size=2, aes(color=pain_type)) +
  scale_x_discrete(limits=c('pain', 'happy','fear', 'sad', 'depression','angry','anxiety',
                            'surprise','disgust'),
                   labels=c('pain', 'happiness','fear', 'sadness', 'depression','anger','anxiety',
                            'surprise','disgust')) +
  theme_minimal() +
  theme(text = element_text(size=20),
        axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position='bottom') +
  coord_fixed(ratio=0.5)+
  labs(color = "Group")

pdf('/Users/juusu53/Documents/projects/kipupotilaat/figures/KI_feels_now_by_pain_type.pdf')
p1
dev.off()

anova_res <- aov(value ~ feeling*pain_type, data=plot_data_long)  
summary(anova_res)
