setwd('/Users/juusu53/Documents/projects/kipupotilaat/')
source('./code/helper_functions_for_r_analysis.R')

library(tidyverse)
library(ggsignif)
library(rcompanion)
library(ggpubr)

subs <- read.csv('data/all_pain_patients_with_activations_19_10_2020.csv',
                 na.strings = 'NaN')
subs$group <- 'patient'
subs_control <- read.csv('data/matched_controls_with_activations_18_11_2020.csv',
                         na.strings = 'NaN')
subs_control$group <- 'control'

subs_roi <- read.csv('data/all_pain_patients_with_activations_by_roi_01_2021.csv',
                 na.strings = 'NaN')
subs_roi$group <- 'patient'
subs_control_roi <- read.csv('data/matched_controls_with_activations_by_roi_01_2021.csv',
                         na.strings = 'NaN')
subs_control_roi$group <- 'control'

# massage body data into tidy
subs_all <- subs %>%  select(subid, group, sex, age, emotions_0_pos_color:sensitivity_2_pos_color) %>% 
  bind_rows(subs_control %>% select(subid, sex, age, emotions_0_pos_color:group))  
subs_all <- rename_emotions(subs_all)
subs_all <- rename_sensitivity(subs_all)
subs_all <- rename_pain(subs_all)

subs_fixed <- make_total_colouring_columns(subs) %>% rename_emotions()
subs_control_fixed <- make_total_colouring_columns(subs_control) %>% rename_emotions()
subs_all_big <- subs_fixed %>%bind_rows(subs_control_fixed) 

## whole body: total pixels
data_long <- subs_all_big %>% 
  select(subid, sex, group, pain_0_pos_color:sensitivity_2_pos_color)  %>% 
  rename(current = pain_0_pos_color, chronic = pain_1_pos_color,
         tactile = sensitivity_0_pos_color, pain = sensitivity_1_pos_color,
         hedonic = sensitivity_2_pos_color) %>% 
  mutate(subid = factor(subid), group = factor(group, levels=c('patient', 'control'))) %>% 
  rename(group = group)
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

## plot whole body data
plot_all <- data_long %>% pivot_longer(tactile:hedonic, names_to='sensitivity type', values_to='prop_coloured') %>% 
  mutate(`sensitivity type` = factor(`sensitivity type`, levels=c('tactile', 'pain', 'hedonic'))) %>% 
  ggplot(aes(x=`sensitivity type`, y=prop_coloured, col=group)) + 
  geom_boxplot(notch=TRUE, outlier.color='black') +
  ylab('Proportion of whole body') +
  xlab('') + 
  scale_y_continuous(breaks=seq(0,1,0.25))+
  expand_limits(y = 1.1) +
  scale_x_discrete(breaks=c('tactile', 'pain', 'hedonic'), 
                   labels=c('Tactile','Nociceptive',' Hedonic')) + 
  geom_jitter(position=position_jitterdodge(), alpha=0.6) + 
  geom_signif(y_position = c(1.05, 1.05, 1.05), xmin = c(0.8, 1.8, 2.8), xmax = c(1.2, 2.2, 3.2),
              annotation = round(pvals,2), col='black', tip_length=0.0, textsize = 5) + 
  theme_classic() +
  theme(text = element_text(size=20),
        axis.text = element_text(size=20),        
        # plot.margin = margin(0.8,0.1,-0.2,2.4, "cm"))
        axis.title.y = element_text(margin = margin(t = 0, r = 30, b = 0, l = 0)),
        plot.margin = margin(0.8,0.1,-0.2,1.45, "cm"))

## 
# massage ROI-wise data
## 
subs_all_roi <- subs_roi %>%  select(subid, group, sex, age, emotions_0_head_pos_color:sensitivity_2_feet_pos_color) %>% 
  bind_rows(subs_control_roi %>% select(subid, sex, age, emotions_0_head_pos_color:group))  
subs_all_roi <- rename_emotions(subs_all_roi)
subs_all_roi <- rename_sensitivity(subs_all_roi)
subs_all_roi <- rename_pain(subs_all_roi)

colnames(subs_all_roi) = gsub("upper_torso", "upper.torso", colnames(subs_all_roi))
colnames(subs_all_roi) = gsub("lower_torso", "lower.torso", colnames(subs_all_roi))

subs_tidy_roi <- subs_all_roi %>% 
  pivot_longer(sadness_head_pos_color:hedonic_feet_pos_color, names_to="task", values_to="prop_coloured") %>% 
  separate(task, into=c('condition','area','direction',NA), sep='_') %>% 
  pivot_wider(names_from = direction, values_from = prop_coloured)  %>% 
  mutate(area = factor(area, levels=rev(c('head','shoulders', 'arms','hands', 'upper.torso', 'lower.torso', 'legs', 'feet'))),
         group = factor(group, levels=c('patient','control')))

sensitivity_full <- subs_tidy_roi %>% filter(condition %in% c('tactile', 'nociceptive','hedonic')) %>% 
  select(-c(neg, total)) %>% mutate(condition = factor(condition, levels=c('tactile', 'nociceptive', 'hedonic')))

sensitivity_summary <- sensitivity_full %>% group_by(condition, area, group) %>% 
  summarise(mean = mean(pos, na.rm=T), 
            sd = sd(pos, na.rm=T),
            num_obs = sum(!is.na(pos))) %>% 
  mutate(se = sd/sqrt(num_obs))

roi_plot <- sensitivity_summary %>% 
  ggplot(aes(x=area, y=mean, col=group, fill=group, group=group)) + 
  geom_jitter(data=sensitivity_full, aes(x=area, y=pos, colour=group), alpha=0.3, position=position_jitterdodge()) + 
  geom_errorbar(aes(ymin=mean-se, ymax=mean+se), color='black', 
                position=position_dodge(width=0.5), width=.2) +
  geom_point(position = position_dodge(width=0.5), size=2) +
  #geom_line(position=position_dodge(), size=2)+
  ylab('Proportion of ROI coloured') +
  xlab('Body area') +
  facet_wrap(~condition, nrow=1) + 
  theme_classic() +
  theme(text = element_text(size=20),
        axis.text.x = element_text(angle=45, hjust=0.8),
        strip.background = element_blank(),
        strip.text.x = element_blank())

roi_box <- ggplot(data = sensitivity_full, aes(y = pos, x = area, fill = group, col=group)) +
  geom_point(position = position_jitterdodge(jitter.width = .15, dodge.width = 0.6), size = .9, alpha = 0.8) +
  geom_boxplot(width=0.4, outlier.shape = NA, alpha = 0.5, position = position_dodge(width=0.6), notch=TRUE, col='black') +
  labs(y='Proportion of ROI', x='') +
  facet_wrap(~condition, nrow=1) +
  scale_x_discrete(breaks = c('head','shoulders', 'arms','hands', 'upper.torso', 'lower.torso', 'legs', 'feet'), 
                   labels = c('Head','Shoulders', 'Arms', 'Hands', 'Upper torso', 'Lower torso', 'Legs', 'Feet')) +
  theme_classic() +
  theme(text = element_text(size=24),
        plot.margin = margin(-0.6,0.1,0.1,0.15, "cm"),
        axis.text.x = element_text(angle = 45, hjust = 1),
        strip.background = element_blank(),
        strip.text.x = element_blank()) +
  coord_flip()

ggarrange(plot_all, roi_box, 
          #hjust = c(-0.3,-0.5,-0.35), vjust = 1,
          #align = "v", axis = "lr", 
          widths = c(3,1), heights=c(1,1.5),
          ncol = 1, nrow = 2, common.legend = TRUE, legend = 'bottom',
          labels=c('A','B'))

ggsave('/Users/juusu53/Documents/projects/kipupotilaat/figures/sensitivity_comparison_ROI_and_total.pdf',
       width = 12, height = 12)
