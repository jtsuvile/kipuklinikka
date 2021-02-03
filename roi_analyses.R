library(tidyverse)
library(PupillometryR)
setwd('/Users/juusu53/Documents/projects/kipupotilaat/')
source('/Users/juusu53/Documents/projects/kipupotilaat/code/helper_functions_for_r_analysis.R')

subs <- read.csv('data/all_pain_patients_with_activations_by_roi_10_2020.csv',
                 na.strings = 'NaN')
subs$group <- 'patient'
subs_control <- read.csv('data/matched_controls_with_activations_by_roi_11_2020.csv',
                         na.strings = 'NaN')
subs_control$group <- 'control'

#massage data into tidy
subs_all <- subs %>%  select(subid, group, sex, age, emotions_0_head_pos_color:sensitivity_2_feet_pos_color) %>% 
  bind_rows(subs_control %>% select(subid, sex, age, emotions_0_head_pos_color:group))  
subs_all <- rename_emotions(subs_all)
subs_all <- rename_sensitivity(subs_all)
subs_all <- rename_pain(subs_all)

subs_tidy <- subs_all %>% pivot_longer(sadness_head_pos_color:hedonic_feet_pos_color, names_to="task", values_to="prop_coloured") %>% 
  separate(task, into=c('condition','area','direction',NA)) %>% 
  pivot_wider(names_from = direction, values_from = prop_coloured)  %>% 
  mutate(area = factor(area, levels=c('head','arms','hands','torso','crotch','legs','feet')))
  
pain_full <- subs_tidy %>%  filter(condition %in% c('currpain', 'chronpain')) %>% 
  mutate(condition = factor(condition, levels=c('currpain','chronpain'), labels = c('current', 'chronic'))) %>% 
  select(-c(neg, total))

pain_summary <- pain_full %>% group_by(condition, area, group) %>% summarise(mean = mean(pos, na.rm=T), 
                                                                                           sd = sd(pos, na.rm=T),
                                                                                           num_obs = sum(!is.na(pos))) %>% 
  mutate(se = sd/sqrt(num_obs))
pd = position_dodge(width=0.4)

pain_summary %>% 
  ggplot(aes(x=area, y=mean, col=group, fill=group, group=group)) + 
  geom_jitter(data=pain_full, aes(x=area, y=pos, colour=group), alpha=0.3, position=position_jitterdodge()) + 
  geom_point(position = pd, size=3) +
  geom_line(position=pd, size=2)+
  geom_errorbar(aes(ymin=mean-se, ymax=mean+se), color='black', 
                position=pd, width=.2) +
  ylab('Proportion of body marked as activation or deactivation') +
  xlab('Emotion') +
  facet_wrap(~condition, nrow=1) + 
  theme_minimal() + 
  theme(text = element_text(size=20),
        axis.text.x = element_text(angle=45, hjust=0.8))

ggsave('/Users/juusu53/Documents/projects/kipupotilaat/figures/pain_ROI_helsinki_controls_facet_pain.pdf',
       width = 8, height = 8)

#visualise sensitivity
sensitivity_full <- subs_tidy %>% filter(condition %in% c('tactile', 'nociceptive','hedonic')) %>% 
  select(-c(neg, total))

sensitivity_summary <- sensitivity_full %>% group_by(condition, area, group) %>% summarise(mean = mean(pos, na.rm=T), 
                                                                             sd = sd(pos, na.rm=T),
                                                                             num_obs = sum(!is.na(pos))) %>% 
  mutate(se = sd/sqrt(num_obs))

sensitivity_summary %>% 
  ggplot(aes(x=condition, y=mean, col=group, fill=group, group=group)) + 
  geom_jitter(data=sensitivity_full, aes(x=condition, y=pos, colour=group), alpha=0.3, position=position_jitterdodge()) + 
  geom_errorbar(aes(ymin=mean-se, ymax=mean+se), color='black', 
                position=position_dodge(), width=.2) +
  geom_point(position = position_dodge(), size=2) +
  geom_line(position=position_dodge(), size=2)+
  ylab('Proportion of body marked as activation or deactivation') +
  xlab('Emotion') +
  facet_wrap(~area, nrow=2) + 
  theme_minimal() + 
  theme(text = element_text(size=20),
        axis.text.x = element_text(angle=45, hjust=0.8))
ggsave('/Users/juusu53/Documents/projects/kipupotilaat/figures/sensitivity_ROI_helsinki_controls_facet_area.png',
       width = 16, height = 8, dpi=300)

sensitivity_summary %>% 
  ggplot(aes(x=area, y=mean, col=group, fill=group, group=group)) + 
  geom_jitter(data=sensitivity_full, aes(x=area, y=pos, colour=group), alpha=0.3, position=position_jitterdodge()) + 
  geom_errorbar(aes(ymin=mean-se, ymax=mean+se), color='black', 
                position=position_dodge(), width=.2) +
  geom_point(position = position_dodge(), size=2) +
  geom_line(position=position_dodge(), size=2)+
  ylab('Proportion of body marked as activation or deactivation') +
  xlab('Emotion') +
  facet_wrap(~condition, nrow=1) + 
  theme_minimal() + 
  theme(text = element_text(size=20),
        axis.text.x = element_text(angle=45, hjust=0.8))
ggsave('/Users/juusu53/Documents/projects/kipupotilaat/figures/sensitivity_ROI_helsinki_controls_facet_sensitivity.png',
       width = 16, height = 8, dpi=300)

# weird facet grid attempt
sensitivity_summary %>% 
  ggplot(aes(x=group, y=mean, col=group, fill=group, group=group)) + 
  geom_jitter(data=sensitivity_full, aes(x=group, y=pos, colour=group), alpha=0.3, position=position_jitterdodge()) + 
  geom_errorbar(aes(ymin=mean-se, ymax=mean+se), color='black', 
                position=position_dodge(), width=.2) +
  geom_point(position = position_dodge(), size=2) +
  geom_line(position=position_dodge(), size=2)+
  ylab('Proportion of body marked as activation or deactivation') +
  xlab('Emotion') +
  facet_grid(condition ~ area) + 
  theme_minimal() + 
  theme(text = element_text(size=20),
        axis.text.x = element_text(angle=45, hjust=0.8))

## visualise emotions
emo_full <- subs_tidy %>% filter(condition %in% c('sadness', 'happiness', 'anger', 'surprise', 'fear','disgust','neutral')) %>% 
  mutate(condition = factor(condition, levels=c('sadness', 'happiness', 'anger', 'surprise', 'fear','disgust','neutral'))) 

emo_summary <- emo_full %>% group_by(condition, area, group) %>% summarise(mean_pos = mean(pos, na.rm=T), 
                                                                    sd_pos = sd(pos, na.rm=T),
                                                                    mean_neg = mean(neg, na.rm=T),
                                                                    sd_neg = sd(neg, na.rm=T),
                                                                    mean_total = mean(total, na.rm=T),
                                                                    sd_total = sd(total, na.rm=T),
                                                                    num_obs = sum(!is.na(total))) %>% 
  mutate(se_pos = sd_pos/sqrt(num_obs),
         se_neg = sd_neg/sqrt(num_obs),
         se_total = sd_total/sqrt(num_obs))

emo_summary %>% 
  ggplot(aes(x=area, y=mean_total, col=group, fill=group, group=group)) + 
  geom_jitter(data=emo_full, aes(x=area, y=total, colour=group), alpha=0.3, position=position_jitterdodge()) + 
  geom_errorbar(aes(ymin=mean_total-se_total, ymax=mean_total+se_total), color='black', 
                position=position_dodge(), width=.2) +
  geom_point(position = position_dodge(), size=2) +
  geom_line(position=position_dodge(), size=2)+
  ylab('Proportion of body marked as activation or deactivation') +
  xlab('Emotion') +
  facet_wrap(~condition, nrow=2) + 
  theme_minimal() + 
  theme(text = element_text(size=20),
        axis.text.x = element_text(angle=45, hjust=0.8))
ggsave('/Users/juusu53/Documents/projects/kipupotilaat/figures/emotion_ROI_helsinki_controls_facet_emotion.png',
       width = 16, height = 8, dpi=300)

emo_summary %>% 
  ggplot(aes(x=condition, y=mean_total, col=group, fill=group, group=group)) + 
  geom_jitter(data=emo_full, aes(x=condition, y=total, colour=group), alpha=0.3, position=position_jitterdodge()) + 
  geom_errorbar(aes(ymin=mean_total-se_total, ymax=mean_total+se_total), color='black', 
                position=position_dodge(), width=.2) +
  geom_point(position = position_dodge(), size=2) +
  geom_line(position=position_dodge(), size=2)+
  ylab('Proportion of body marked as activation or deactivation') +
  xlab('Emotion') +
  facet_wrap(~area, nrow=2) + 
  theme_minimal() + 
  theme(text = element_text(size=20),
        axis.text.x = element_text(angle=45, hjust=0.8))
ggsave('/Users/juusu53/Documents/projects/kipupotilaat/figures/emotion_ROI_helsinki_controls_facet_area.png',
       width = 16, height = 8, dpi=300)

## attempt at raincloudplot
# subs_tidy %>% filter(condition %in% c('currpain', 'chronpain')) %>% 
#   ggplot(aes(x=condition, y = pos, fill=group)) +
#   geom_flat_violin(position = position_nudge(x = .2, y = 0), 
#                    adjust = 1.5, trim = TRUE, alpha = .5, colour = NA) + 
#   geom_point(aes(x = condition, y = pos, colour = group),
#              position = position_jitterdodge(jitter.width = .1, dodge.width = 0.), size = 1, shape = 20) +
#   geom_boxplot(position= position_dodge(width=0.3), outlier.shape = NA, alpha = .5, 
#                width = .25, colour = "black") +
#   facet_wrap(~area) +
#   theme_minimal() +
#   theme(text = element_text(size=20))