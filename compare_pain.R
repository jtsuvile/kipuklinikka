setwd('/Users/juusu53/Documents/projects/kipupotilaat/')
source('./code/helper_functions_for_r_analysis.R')

library(tidyverse)
library(ggsignif)
library(rcompanion)

subs <- read.csv('data/all_pain_patients_with_activations_19_10_2020.csv',
                 na.strings = 'NaN')
subs$batch <- 'patient'
subs_control <- read.csv('data/matched_controls_with_activations_18_11_2020.csv',
                         na.strings = 'NaN')
subs_control$batch <- 'control'

subs_fixed <- make_total_colouring_columns(subs) %>% rename_emotions()
subs_control_fixed <- make_total_colouring_columns(subs_control) %>% rename_emotions()
subs_all_big <- subs_fixed %>%bind_rows(subs_control_fixed) 

## total pixels
data_long <- subs_all_big %>% 
  select(subid, sex, batch, pain_0_pos_color:sensitivity_2_pos_color)  %>% 
  rename(current = pain_0_pos_color, chronic = pain_1_pos_color,
         tactile = sensitivity_0_pos_color, pain = sensitivity_1_pos_color,
         hedonic = sensitivity_2_pos_color) %>% 
  mutate(subid = factor(subid), batch = factor(batch)) %>% 
  rename(group = batch)

## pain plot
u_chronic <- wilcox.test(data_long$chronic ~ data_long$group, conf.int=TRUE)
effect_chronic <- wilcoxonR(x = data_long$chronic,
          g = data_long$group)
u_current <- wilcox.test(data_long$current ~ data_long$group, conf.int=TRUE)
effect_current <- wilcoxonR(x = data_long$current,
                            g = data_long$group)

p_pain <- p.adjust(c(u_current$p.value, u_chronic$p.value))

data_long %>% pivot_longer(current:chronic, names_to='pain type', values_to='prop_coloured') %>% 
  mutate(`pain type` = factor(`pain type`, levels=c('current', 'chronic'))) %>% 
  ggplot(aes(x=`pain type`, y=prop_coloured, col=group)) + 
  geom_boxplot(notch=TRUE, outlier.color='black') +
  ylab('proprtion of body coloured') +
  geom_jitter(position=position_jitterdodge(), alpha=0.6) + 
  geom_signif(y_position = c(0.6, 0.6), xmin = c(0.8, 1.8), xmax = c(1.2, 2.2),
              annotation = round(p_pain,2), col='black', tip_length=0.0, textsize = 5) + 
  theme_classic() +
  theme(text = element_text(size=20),
        axis.text = element_text(size=20))
ggsave('/Users/juusu53/Documents/projects/kipupotilaat/figures/pain_extent_helsinki_controls.pdf',
       width = 8, height = 8)

## sensitivity plot
u_tactile <- wilcox.test(data_long$tactile ~ data_long$group, conf.int=TRUE)
effect_tactile <- wilcoxonR(x = data_long$tactile,
                            g = data_long$group)
u_pain <- wilcox.test(data_long$pain ~ data_long$group, conf.int=TRUE)
effect_pain <- wilcoxonR(x = data_long$pain,
                            g = data_long$group)
u_hedonic <- wilcox.test(data_long$hedonic ~ data_long$group)
effect_hedonic <- wilcoxonR(x = data_long$hedonic,
                            g = data_long$group, ci=TRUE)

pvals <- p.adjust(c(u_tactile$p.value, u_pain$p.value, u_hedonic$p.value))

data_long %>% pivot_longer(tactile:hedonic, names_to='sensitivity type', values_to='prop_coloured') %>% 
  mutate(`sensitivity type` = factor(`sensitivity type`, levels=c('tactile', 'pain', 'hedonic'))) %>% 
  ggplot(aes(x=`sensitivity type`, y=prop_coloured, col=group)) + 
  geom_boxplot(notch=TRUE, outlier.color='black') +
  ylab('proprtion of body coloured') +
  geom_jitter(position=position_jitterdodge(), alpha=0.6) + 
  geom_signif(y_position = c(1.1, 1.1, 1.1), xmin = c(0.8, 1.8, 2.8), xmax = c(1.2, 2.2, 3.2),
              annotation = round(pvals,2), col='black', tip_length=0.0, textsize = 5) + 
  theme_classic() +
  theme(text = element_text(size=20),
        axis.text = element_text(size=20))
ggsave('/Users/juusu53/Documents/projects/kipupotilaat/figures/sensitivity_extent_helsinki_controls.pdf',
       width = 8, height = 8)
