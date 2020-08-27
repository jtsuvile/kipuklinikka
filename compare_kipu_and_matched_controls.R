rm(list = ls())
library(psych)
library(stats)
library(corrplot)
library(RColorBrewer)
#library(Hmisc)
library(tidyverse)
library(dplyr)
library(tidyr)
library(ggplot2)
library(ggpubr)

location <- '/Users/jtsuvile/Documents/projects/kipupotilaat/data/'
subs <- read.csv(paste(location, 'all_pain_patients_with_activations.csv', sep=''))
subs$batch <- 'patient'
subs_control <- read.csv(paste(location, 'matched_controls_with_activations.csv', sep=''))
subs_control$batch <- 'control'

#pain_overlap <- read.csv(paste(location, 'pains_overlap.csv', sep=''), header=TRUE, na.strings = 'NaN')
#size_frontbackmask <- 91840 #pixels
emotions <- c('sadness','happiness','anger','surprise','fear','disgust','neutral')
pains <- c('acute_pain','chronic_pain')
sensitivity <- c('tactile_sensitivity', 'pain_sensitivity','hedonic_sensitivity')

subs$sadness_total <- subs$emotions_0_neg_color + subs$emotions_0_pos_color
subs_control$sadness_total <- subs_control$emotions_0_neg_color + subs_control$emotions_0_pos_color

subs$happiness_total <- subs$emotions_1_neg_color + subs$emotions_1_pos_color
subs_control$happiness_total <- subs_control$emotions_1_neg_color + subs_control$emotions_1_pos_color

subs$anger_total <- subs$emotions_2_neg_color + subs$emotions_2_pos_color
subs_control$anger_total <- subs_control$emotions_2_neg_color + subs_control$emotions_2_pos_color

subs$surprise_total <- subs$emotions_3_neg_color + subs$emotions_3_pos_color
subs_control$surprise_total <- subs_control$emotions_3_neg_color + subs_control$emotions_3_pos_color

subs$fear_total <- subs$emotions_4_neg_color + subs$emotions_4_pos_color
subs_control$fear_total <- subs_control$emotions_4_neg_color + subs_control$emotions_4_pos_color

subs$disgust_total <- subs$emotions_5_neg_color + subs$emotions_5_pos_color
subs_control$disgust_total <- subs_control$emotions_5_neg_color + subs_control$emotions_5_pos_color

subs$neutral_total <- subs$emotions_6_neg_color + subs$emotions_6_pos_color
subs_control$neutral_total <- subs_control$emotions_6_neg_color + subs_control$emotions_6_pos_color

## total pixels
subs_all_big <- bind_rows(subs, subs_control)
subs_all <- subs_all_big[c('subid','sex','batch', 'sadness_total','happiness_total','anger_total','surprise_total','fear_total','disgust_total','neutral_total')]
subs_all$subid <- factor(subs_all$subid)
data_long <- gather(subs_all, emotion, coloured, sadness_total:neutral_total, factor_key=TRUE)

basic_anova <- aov(coloured ~ batch * emotion, data = data_long)
summary(basic_anova)

ggline(data_long, x = "emotion", y = "coloured", color = "batch",
       add = c("mean_se", "dotplot"),
       palette = c("#00AFBB", "#E7B800"))

summarized <- summarySE(data_long, measurevar='coloured', groupvars=c('emotion','batch'))
pd <- position_dodge(0.1)

p <- ggplot(data=summarized, aes(x=emotion, y=coloured, colour=batch, group=batch)) +
  geom_jitter(data=data_long, aes(x=emotion, y=coloured, colour=batch), alpha=0.3) +
  geom_errorbar(aes(ymin=coloured-se, ymax=coloured+se), color='black',width=.2, position=pd) +
  geom_point(position=pd, size=2) +
  geom_line(position=pd, size=2) +
  scale_x_discrete(limits=c('fear_total','happiness_total','sadness_total',
                            'anger_total','disgust_total','surprise_total','neutral_total'),
                   labels=c('fear','happiness','sadness', 'anger','disgust','surprise','neutral'))+
  theme_minimal() +
  theme(text = element_text(size=16),
    axis.text.x = element_text(angle = 45, hjust = 1))+
  coord_fixed(ratio=7)+
  labs(color = "Group", y='Proportion coloured')

p

##
## positive pixels
subs_all_big <- bind_rows(subs, subs_control)
subs_all_pos <- subs_all_big[c('subid', 'sex', 'batch', 'emotions_0_pos_color', 'emotions_1_pos_color', 
                           'emotions_2_pos_color', 'emotions_3_pos_color', 'emotions_4_pos_color', 
                           'emotions_5_pos_color','emotions_6_pos_color')]

subs_all_pos$subid <- factor(subs_all_pos$subid)
data_long_pos <- gather(subs_all_pos, emotion, coloured, emotions_0_pos_color:emotions_6_pos_color, factor_key=TRUE)

basic_anova_pos <- aov(coloured ~ batch * emotion, data = data_long_pos)
summary(basic_anova_pos)

# ggline(data_long, x = "emotion", y = "coloured", color = "batch",
#        add = c("mean_se", "dotplot"),
#        palette = c("#00AFBB", "#E7B800"))

summarized_pos <- summarySE(data_long_pos, measurevar='coloured', groupvars=c('emotion','batch'))
pd <- position_dodge(0.1)

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
subs_all_big <- bind_rows(subs, subs_control)
subs_all_neg <- subs_all_big[c('subid', 'sex', 'batch', 'emotions_0_neg_color', 'emotions_1_neg_color', 
                           'emotions_2_neg_color', 'emotions_3_neg_color', 'emotions_4_neg_color', 
                           'emotions_5_neg_color','emotions_6_neg_color')]

subs_all_neg$subid <- factor(subs_all_neg$subid)
data_long_neg <- gather(subs_all_neg, emotion, coloured, emotions_0_neg_color:emotions_6_neg_color, factor_key=TRUE)

basic_anova_neg <- aov(coloured ~ batch * emotion, data = data_long_neg)
summary(basic_anova_neg)

# ggline(data_long, x = "emotion", y = "coloured", color = "batch",
#        add = c("mean_se", "dotplot"),
#        palette = c("#00AFBB", "#E7B800"))

summarized_neg <- summarySE(data_long_neg, measurevar='coloured', groupvars=c('emotion','batch'))
pd <- position_dodge(0.1)

p2 <- ggplot(data=summarized_neg, aes(x=emotion, y=coloured, colour=batch, group=batch)) +
  geom_jitter(data=data_long_neg, aes(x=emotion, y=coloured, colour=batch), alpha=0.3) +
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


##

t.test(subs$sadness_total, subs_control$sadness_total) # ns
t.test(subs$happiness_total, subs_control$happiness_total) # *
t.test(subs$anger_total, subs_control$anger_total) # ns
t.test(subs$surprise_total, subs_control$surprise_total) # *
t.test(subs$fear_total, subs_control$fear_total) # ***
t.test(subs$disgust_total, subs_control$disgust_total) # *
t.test(subs$neutral_total, subs_control$neutral_total) # ns

t.test(subs$pain_0_pos_color, subs_control$pain_0_pos_color) # ***
t.test(subs$pain_1_pos_color, subs_control$pain_1_pos_color) # ***

t.test(subs$sensitivity_0_pos_color, subs_control$sensitivity_0_pos_color) # ns
t.test(subs$sensitivity_1_pos_color, subs_control$sensitivity_1_pos_color) # ***
t.test(subs$sensitivity_2_pos_color, subs_control$sensitivity_2_pos_color) # ns

# kipu vs crps
t.test(subs[subs$groups == 'CRPS', 'sadness_total'], subs[subs$groups != 'CRPS', 'sadness_total']) # ns
t.test(subs[subs$groups == 'CRPS', 'happiness_total'], subs[subs$groups != 'CRPS', 'happiness_total']) # ns
t.test(subs[subs$groups == 'CRPS', 'anger_total'], subs[subs$groups != 'CRPS', 'anger_total']) # ns
t.test(subs[subs$groups == 'CRPS', 'surprise_total'], subs[subs$groups != 'CRPS', 'surprise_total']) # ns
t.test(subs[subs$groups == 'CRPS', 'fear_total'], subs[subs$groups != 'CRPS', 'fear_total']) # **
t.test(subs[subs$groups == 'CRPS', 'disgust_total'], subs[subs$groups != 'CRPS', 'disgust_total']) # **
t.test(subs[subs$groups == 'CRPS', 'sadness_total'], subs[subs$groups != 'CRPS', 'sadness_total']) # ns

t.test(subs[subs$groups == 'CRPS', 'sensitivity_0_pos_color'], subs[subs$groups != 'CRPS', 'sensitivity_0_pos_color']) # ns
t.test(subs[subs$groups == 'CRPS', 'sensitivity_1_pos_color'], subs[subs$groups != 'CRPS', 'sensitivity_1_pos_color']) # ns
t.test(subs[subs$groups == 'CRPS', 'sensitivity_2_pos_color'], subs[subs$groups != 'CRPS', 'sensitivity_2_pos_color']) # ns



## helper
summarySE <- function(data=NULL, measurevar, groupvars=NULL, na.rm=FALSE,
                      conf.interval=.95, .drop=TRUE) {
  library(plyr)
  
  # New version of length which can handle NA's: if na.rm==T, don't count them
  length2 <- function (x, na.rm=FALSE) {
    if (na.rm) sum(!is.na(x))
    else       length(x)
  }
  
  # This does the summary. For each group's data frame, return a vector with
  # N, mean, and sd
  datac <- ddply(data, groupvars, .drop=.drop,
                 .fun = function(xx, col) {
                   c(N    = length2(xx[[col]], na.rm=na.rm),
                     mean = mean   (xx[[col]], na.rm=na.rm),
                     sd   = sd     (xx[[col]], na.rm=na.rm)
                   )
                 },
                 measurevar
  )
  
  # Rename the "mean" column    
  datac <- rename(datac, c("mean" = measurevar))
  
  datac$se <- datac$sd / sqrt(datac$N)  # Calculate standard error of the mean
  
  # Confidence interval multiplier for standard error
  # Calculate t-statistic for confidence interval: 
  # e.g., if conf.interval is .95, use .975 (above/below), and use df=N-1
  ciMult <- qt(conf.interval/2 + .5, datac$N-1)
  datac$ci <- datac$se * ciMult
  
  return(datac)
}
