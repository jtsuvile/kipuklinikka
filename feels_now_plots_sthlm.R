#rm(list = ls())
library(psych)
library(stats)
library(corrplot)
library(RColorBrewer)
library(tidyverse)
library(rstatix)

location <- '/Users/juusu53/Documents/projects/kipupotilaat/data/'
subs <- read.csv(paste(location, 'bg_pain_stockholm_with_activations_12_2020.csv', sep=''))
subs_diagnoses <- read_csv2(paste(location, 'diagnoses_KI_12_2019_no_empty_cells.csv', sep=''), 
                            col_names =FALSE) %>% rename(subid = X5, diagnosis = X3, sex_2 = X2) %>% 
  select(subid, diagnosis, sex_2)

subs <- subs %>% left_join(subs_diagnoses)

# make sure the sexes from both data sources match
subs %>% filter(!is.na(sex_2)) %>% select(sex, sex_2)

subs_control <- read.csv(paste(location, 'all_healthy_with_activations_29_10_2020.csv', sep=''))

subs2 <- subs %>% select(subid, sex, age, starts_with('feels')) %>% mutate(group='pain')
data <- subs_control %>% select(subid, sex, age, starts_with('feels')) %>% mutate(group='control') %>% 
  rbind(subs2)

plot_data_long <- data %>% 
  pivot_longer(cols="feels_pain":"feels_disgust", names_to = 'feeling', values_to='intensity') %>% 
  mutate(feeling = str_remove(feeling, 'feels_'))

plot_data_summary <- plot_data_long %>% group_by(feeling, group) %>% 
  summarise(mean = mean(intensity), sd = sd(intensity), se=sd(intensity)/sqrt(n()), n()) %>% 
  ungroup()

pd <- position_dodge(0.1)

p1 <- ggplot(plot_data_summary, aes(x=feeling, y=mean, color=group, group=group)) + 
  geom_jitter(data=plot_data_long, aes(x=feeling, y=intensity), alpha=0.3) + 
  geom_errorbar(aes(ymin=mean-se, ymax=mean+se), width=.2, position=pd, color='black') +
  geom_point(size=3, position=pd) + 
  geom_line(position=pd, size=2, aes(color=group)) +
  scale_x_discrete(limits=c('pain', 'happy','anxiety','depression','sad','fear',
                            'surprise', 'angry','disgust'),
                   labels=c('pain', 'happiness','anxiety','depression','sadness','fear',
                            'surprise','anger','disgust')) +
  theme_minimal() +
  theme(text = element_text(size=20),
        axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position='bottom') +
  #coord_fixed(ratio=0.5)+
  labs(color = "Group")

pdf('/Users/juusu53/Documents/projects/kipupotilaat/figures/feels_now_stockholm_and_all_controls.pdf')
p1
dev.off()

anova_res <- aov(intensity ~ group * feeling, data=plot_data_long)  
summary(anova_res)

plot_data_long %>% group_by(feeling, group) %>%
  shapiro_test(intensity) %>% ungroup()
# very much not normally distributed

special_anova <- bwtrim(intensity ~ group * feeling, id=subid, data = plot_data_long)
special_anova

summary_to_report_1 <- plot_data_long %>% group_by(feeling) %>% summarise(mean = mean(intensity), sd = sd(intensity), se=sd(intensity)/sqrt(n()), n())
summary_to_report_2 <- plot_data_long %>% group_by(group) %>% summarise(mean = mean(intensity), sd = sd(intensity), se=sd(intensity)/sqrt(n()), n())
