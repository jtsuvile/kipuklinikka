rm(list = ls())
library(psych)
library(stats)
library(corrplot)
library(RColorBrewer)
library(tidyverse)
library(rstatix)

library(raincloudplots)
library(gghalves)

location <- '/Users/juusu53/Documents/projects/kipupotilaat/data/'
subs <- read.csv(paste(location, 'all_pain_patients_with_activations_19_10_2020.csv', sep=''))
subs_control <- read.csv(paste(location, 'matched_controls_with_activations_18_11_2020.csv', sep=''))
subs <- subs %>% select(subid, sex, age, starts_with('feels')) %>% mutate(group='pain')
data <- subs_control %>% select(subid, sex, age, starts_with('feels')) %>% mutate(group='control') %>% 
  rbind(subs)

plot_data_long <- data %>% 
  pivot_longer(cols="feels_pain":"feels_disgust", names_to = 'feeling', values_to='intensity') %>% 
  mutate(feeling = str_remove(feeling, 'feels_'), feeling=factor(feeling)) %>% 
  mutate(group = factor(group, levels=c('pain','control'), labels = c('patient','control')))

plot_data_summary <- plot_data_long %>% group_by(feeling, group) %>% 
  summarise(mean = mean(intensity), sd = sd(intensity), se=sd(intensity)/sqrt(n()), n()) %>% 
  ungroup()

pd <- position_dodge(0.7)

p1 <- ggplot(plot_data_long, aes(x=feeling, y=intensity, color=group, fill=group)) + 
  geom_point(position=position_jitterdodge(jitter.width=0.3, jitter.height = 0.5, dodge.width = 0.7), alpha=0.8) +
  geom_boxplot(width=0.4, outlier.shape = NA, alpha = 0.5, 
               position = position_dodge(width=0.7), notch=TRUE, col='black') +
  scale_x_discrete(limits=rev(c('pain', 'happy','anxiety','depression','sad','fear',
                            'surprise', 'angry','disgust')),
                   labels=rev(c('pain', 'happiness','anxiety','depression','sadness','fear',
                            'surprise','anger','disgust'))) +
  theme_classic() +
  coord_flip() +
  theme(text = element_text(size=20),
        #axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position='bottom') +
  #coord_fixed(ratio=0.5) +
  labs(color = "group", fill = 'group', x = 'Emotion', y = 'Intensity of emotion') 

pdf('/Users/juusu53/Documents/projects/kipupotilaat/figures/helsinki_manuscript_figs/manuscript_figs_feels_now_boxplot.pdf')
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
