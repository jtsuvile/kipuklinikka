setwd('/Users/juusu53/Documents/projects/kipupotilaat/')
source('./code/helper_functions_for_r_analysis.R')
library(psych)
library(RColorBrewer)
library(tidyverse)

subs <- read.csv('data/all_pain_patients_with_activations_19_10_2020.csv',
                 na.strings = 'NaN')
subs$batch <- 'patient'
subs_control <- read.csv('data/matched_controls_with_activations_19_10_2020.csv',
                         na.strings = 'NaN')
subs_control$batch <- 'control'
## NB: stopgap measure until I fix the data preprocessing for the controls who don't 
## have colour in to leave empty in the interface!
subs_control <- subs_control %>% mutate(across(ends_with("color"), ~replace_na(., 0)))

subs_fixed <- make_total_colouring_columns(subs) %>% rename_emotions()
subs_control_fixed <- make_total_colouring_columns(subs_control) %>% rename_emotions()
subs_all_big <- subs_fixed %>%bind_rows(subs_control_fixed) 

## total pixels
data_long <- subs_all_big %>% 
  select(subid, sex, batch, sadness_pos_color:neutral_total) %>% select(-contains("pain")) %>% select(-contains("sensitivity")) %>% 
  pivot_longer(sadness_pos_color:neutral_total, names_to = "emotion", values_to="prop_coloured") %>% 
  separate(emotion, into=c("emotion", "type", NA)) %>% pivot_wider(names_from=type, values_from=prop_coloured) %>% 
  mutate(emotion = factor(emotion), subid = factor(subid), batch = factor(batch))

# all coloured
basic_anova <- aov(total ~ batch * emotion, data = data_long)
summary(basic_anova)

summarized_total <- data_long %>% group_by(emotion, batch) %>% 
  summarise(coloured = mean(total, na.rm=T), sd = sd(total, na.rm=T), n = n(), na_nums= sum(is.na(total))) %>% 
  mutate(se = sd/sqrt(n))

# positive activations
basic_anova_pos <- aov(pos~ batch * emotion, data = data_long)
summary(basic_anova_pos)

summarized_pos <- data_long %>% group_by(emotion, batch) %>% 
  summarise(coloured = mean(pos, na.rm=T), sd = sd(pos, na.rm=T), n = n(), na_nums= sum(is.na(pos))) %>% 
  mutate(se = sd/sqrt(n))

# negative (inactivations)
basic_anova_neg <- aov(neg~ batch * emotion, data = data_long)
summary(basic_anova_neg)

summarized_neg <- data_long %>% group_by(emotion, batch) %>% 
  summarise(coloured = mean(neg, na.rm=T), sd = sd(neg, na.rm=T), n = n(), na_nums= sum(is.na(neg))) %>% 
  mutate(se = sd/sqrt(n))

## PLOT
pd <- position_dodge(0.1)
p <- ggplot(data=summarized_total, aes(x=emotion, y=coloured, colour=batch, group=batch)) +
  geom_jitter(position = pd, alpha=0.3) +
  geom_errorbar(aes(ymin=coloured-se, ymax=coloured+se), color='black',width=.2, position=pd) +
  geom_point(position=pd, size=2) +
  geom_line(position=pd, size=2) +
  #scale_x_discrete(limits=c('fear_total','happiness_total','sadness_total',
  #                          'anger_total','disgust_total','surprise_total','neutral_total'),
  #                 labels=c('fear','happiness','sadness', 'anger','disgust','surprise','neutral'))+
  theme_minimal() +
  theme(text = element_text(size=16),
    axis.text.x = element_text(angle = 45, hjust = 1))+
  coord_fixed(ratio=7)+
  labs(color = "Group", y='Proportion coloured')

p

##
## positive pixels



# ggline(data_long, x = "emotion", y = "coloured", color = "batch",
#        add = c("mean_se", "dotplot"),
#        palette = c("#00AFBB", "#E7B800"))


p1 <- ggplot(data=summarized_pos, aes(x=emotion, y=coloured, colour=batch, group=batch)) +
  geom_jitter(data=data_long_pos, aes(x=emotion, y=coloured, colour=batch), alpha=0.3) +
  geom_errorbar(aes(ymin=coloured-se, ymax=coloured+se), color='black',width=.2, position=pd) +
  geom_point(position=pd, size=2) +
  geom_line(position=pd, size=2) +
  scale_x_discrete(limits=c('emotions_4_pos_color','emotions_1_pos_color','emotions_0_pos_color',
                            'emotions_2_pos_color','emotions_5_pos_color','emotions_3_pos_color',
                            'emotions_6_pos_color'), 
                   labels=c('fear','happiness','sadness', 'anger','disgust','surprise','neutral'))+
  theme_minimal() +
  theme(text = element_text(size=16),
        axis.text.x = element_text(angle = 45, hjust = 1),
        axis.title.y = element_blank())+
  coord_fixed(ratio=7)+
  labs(color = "Group")

p1

## negative pixels

p2 <- ggplot(data=summarized_neg, aes(x=emotion, y=coloured, colour=batch, group=batch)) +
  geom_jitter(alpha=0.3, position=pd) +
  geom_errorbar(aes(ymin=coloured-se, ymax=coloured+se), color='black',width=.2, position=pd) +
  geom_point(position=pd, size=2) +
  geom_line(position=pd, size=2) +
  scale_x_discrete(limits=c('emotions_4_neg_color','emotions_1_neg_color','emotions_0_neg_color',
                            'emotions_2_neg_color','emotions_5_neg_color','emotions_3_neg_color',
                            'emotions_6_neg_color'), 
                   labels=c('fear','happiness','sadness', 'anger','disgust','surprise','neutral'))+
  theme_minimal() +
  theme(text = element_text(size=16),
    axis.text.x = element_text(angle = 45, hjust = 1),
    axis.title.y = element_blank()) +
  coord_fixed(ratio=7) +
  labs(color = "Group")

p2


ggarrange(p, p1, p2, 
          labels = c("any coloured pixels", "activations", "deactivations"), font.label = c(size = 20),
          hjust = c(-0.3,-0.5,-0.35), vjust = 1,
          ncol = 3, nrow = 1, common.legend = TRUE) %>%
  ggexport(filename = '/Users/jtsuvile/Documents/projects/kipupotilaat/figures/n_colored_pixels_patients_and_controls.png',
           width = 1300, height = 500, pointsize = 30)

# ##
# 
# t.test(subs$sadness_total, subs_control$sadness_total) # ns
# t.test(subs$happiness_total, subs_control$happiness_total) # *
# t.test(subs$anger_total, subs_control$anger_total) # ns
# t.test(subs$surprise_total, subs_control$surprise_total) # *
# t.test(subs$fear_total, subs_control$fear_total) # ***
# t.test(subs$disgust_total, subs_control$disgust_total) # *
# t.test(subs$neutral_total, subs_control$neutral_total) # ns
# 
# t.test(subs$pain_0_pos_color, subs_control$pain_0_pos_color) # ***
# t.test(subs$pain_1_pos_color, subs_control$pain_1_pos_color) # ***
# 
# t.test(subs$sensitivity_0_pos_color, subs_control$sensitivity_0_pos_color) # ns
# t.test(subs$sensitivity_1_pos_color, subs_control$sensitivity_1_pos_color) # ***
# t.test(subs$sensitivity_2_pos_color, subs_control$sensitivity_2_pos_color) # ns
# 
# # kipu vs crps
# t.test(subs[subs$groups == 'CRPS', 'sadness_total'], subs[subs$groups != 'CRPS', 'sadness_total']) # ns
# t.test(subs[subs$groups == 'CRPS', 'happiness_total'], subs[subs$groups != 'CRPS', 'happiness_total']) # ns
# t.test(subs[subs$groups == 'CRPS', 'anger_total'], subs[subs$groups != 'CRPS', 'anger_total']) # ns
# t.test(subs[subs$groups == 'CRPS', 'surprise_total'], subs[subs$groups != 'CRPS', 'surprise_total']) # ns
# t.test(subs[subs$groups == 'CRPS', 'fear_total'], subs[subs$groups != 'CRPS', 'fear_total']) # **
# t.test(subs[subs$groups == 'CRPS', 'disgust_total'], subs[subs$groups != 'CRPS', 'disgust_total']) # **
# t.test(subs[subs$groups == 'CRPS', 'sadness_total'], subs[subs$groups != 'CRPS', 'sadness_total']) # ns
# 
# t.test(subs[subs$groups == 'CRPS', 'sensitivity_0_pos_color'], subs[subs$groups != 'CRPS', 'sensitivity_0_pos_color']) # ns
# t.test(subs[subs$groups == 'CRPS', 'sensitivity_1_pos_color'], subs[subs$groups != 'CRPS', 'sensitivity_1_pos_color']) # ns
# t.test(subs[subs$groups == 'CRPS', 'sensitivity_2_pos_color'], subs[subs$groups != 'CRPS', 'sensitivity_2_pos_color']) # ns
# 
# emotions <- c('sadness','happiness','anger','surprise','fear','disgust','neutral')
# pains <- c('current_pain','chronic_pain')
# sensitivity <- c('tactile_sensitivity', 'pain_sensitivity','hedonic_sensitivity')