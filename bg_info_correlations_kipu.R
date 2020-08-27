rm(list = ls())
library(psych)
library(stats)
library(corrplot)
library(RColorBrewer)
#library(Hmisc)
library(tidyverse)

location <- '/Users/jtsuvile/Documents/projects/kipupotilaat/data/'
subs <- read.csv(paste(location, 'all_healthy_with_activations.csv', sep=''))

pain_duration <- read.csv(paste(location, 'pain_start_helsinki_summer2019.csv', sep=''), sep=";")
subs <- merge(subs, pain_duration, by="subid", all.x=TRUE)

#pain_overlap <- read.csv(paste(location, 'pains_overlap.csv', sep=''), header=TRUE, na.strings = 'NaN')
#size_frontbackmask <- 91840 #pixels
emotions <- c('sadness','happiness','anger','surprise','fear','disgust','neutral')
pains <- c('acute_pain','chronic_pain')
sensitivity <- c('tactile_sensitivity', 'pain_sensitivity','hedonic_sensitivity')

look_at_names <- c('age','work_physical','work_sitting','feels_pain', 'acute_pain_total', 'chronic_pain_total', 'tactile_sensitivity_total', 'pain_sensitivity_total', 
                   'hedonic_sensitivity_total',
                   'feels_anxiety', 'feels_depression', 'feels_sad', 'feels_happy', 'feels_angry', 'feels_fear','feels_surprise',  'feels_disgust',
                   'sadness_pos_activations', 'sadness_neg_activations', 'happiness_pos_activations', 'happiness_neg_activations',
                   'anger_pos_activations', 'anger_neg_activations', 'surprise_pos_activations', 'surprise_neg_activations',
                   'fear_pos_activations', 'fear_neg_activations', 'disgust_pos_activations', 'disgust_neg_activations', 'neutral_pos_activations',
                   'neutral_neg_activations', 'pain_Start')

varnames <- colnames(subs)

varnames = gsub("_pos_color", '_pos_activations', varnames)
varnames = gsub("_neg_color", '_neg_activations', varnames)

for(i in 1:7){
  varnames = gsub(paste("emotions", i-1, sep='_'), emotions[i], varnames)
}
for(j in 1:2){
  varnames = gsub(paste("pain", j-1, sep='_'), pains[j], varnames)
  varnames = gsub(paste( pains[j], 'pos_activations', sep='_'), paste(pains[j], 'total', sep='_'), varnames)
}
for(k in 1:3){
  varnames = gsub(paste("sensitivity", k-1, sep='_'), sensitivity[k], varnames)
  varnames = gsub(paste(sensitivity[k], 'pos_activations', sep='_'), paste(sensitivity[k], 'total', sep='_'), varnames)
}


colnames(subs)<- varnames

look_at <- match(look_at_names, names(subs))
smaller_bg = subs[,look_at]
# new_order <- c(1:4, 27:31, 5:26)
# smaller_bg <- smaller_bg[,new_order]
correlations <- corr.test(smaller_bg)

color_palette <- brewer.pal(n = 11, name = "RdBu")

pdf('/Users/jtsuvile/Documents/projects/kipupotilaat/figures/all_kinds_of_correlations_all_pain_with_duration.pdf', width=10, height=7)
corrplot(correlations$r, p.mat = correlations$p, sig.level = .05, insig = "blank", 
         method='circle', type='lower', col = color_palette[11:1],tl.col = "black", tl.srt = 45,
         title= 'Pain patients',mar=c(0,0,1,0), diag=FALSE)
dev.off()
# 
# subs_chronic <- subs[subs$chronicpain==1&subs$pain!=0,]
# subs_nonchronic <- subs[subs$chronicpain==0&subs$pain!=0,]
# subs_nonpain <- subs[subs$chronicpain==0&subs$painrecent==0&subs$pain==0,]
# 
# smaller_chronic = subs_chronic[,look_at]
# smaller_nonchronic = subs_nonchronic[,look_at]
# smaller_nonpain = subs_nonpain[,look_at]
# 
# smaller_chronic = smaller_chronic[,new_order]
# smaller_nonchronic = smaller_nonchronic[,new_order]
# smaller_nonpain = smaller_nonpain[,new_order]
# 
# corr_chronic <- corr.test(smaller_chronic, method='spearman')
# corr_nonchronic <- corr.test(smaller_nonchronic, method='spearman')
# corr_nonpain <- corr.test(smaller_nonpain, method='spearman')
# 
# # partial correlation between pain intensity, pain extent, and age
# 
# look_at <- c(3,37, 49:50, 52:53, 55:56, 58:59,61:62,64:65,69, 72, 82, 83, 84)
# colnames(subs)[look_at]
# small_corrmat <- corr.test(subs[,look_at])
# par_r <- partial.r(subs[,look_at], c(2,3:19), 1)
# 
# pdf(paste(location, 'figures/all_kinds_of_correlations_chronic_pain_curr_pain.pdf', sep=''), width=10, height=7)
# corrplot(corr_chronic$r, p.mat = corr_chronic$p, sig.level = .05, insig = "blank", 
#          method='circle', type='lower', col = color_palette[11:1],tl.col = "black", tl.srt = 45,
#          title='Subjects with history of chronic pain',mar=c(0,0,1,0), diag=FALSE)
# dev.off()
# 
# pdf(paste(location, 'figures/all_kinds_of_correlations_nonchronic_curr_pain.pdf', sep=''), width=10, height=7)
# corrplot(corr_nonchronic$r, p.mat = corr_nonchronic$p, sig.level = .05, insig = "blank", 
#          method='circle', type='lower', col = color_palette[11:1],tl.col = "black", tl.srt = 45,
#          title='Subjects with NO history of chronic pain',mar=c(0,0,1,0), diag=FALSE)
# dev.off()
# 
# pdf(paste(location, 'figures/all_kinds_of_correlations_no_pain.pdf', sep=''), width=10, height=7)
# corrplot(corr_nonpain$r, p.mat = corr_nonpain$p, sig.level = .05, insig = "blank", 
#          method='circle', type='lower', col = color_palette[11:1],tl.col = "black", tl.srt = 45,
#          mar=c(0,0,1,0), diag=FALSE)
# dev.off()
# 
# 
# t.test(subs[subs$chronicpain==1,'tactile_sensitivity_total'], subs[subs$chronicpain==0,'tactile_sensitivity_total'])
# t.test(subs[subs$chronicpain==1,'joy'], subs[subs$chronicpain==0,'joy'])
# 
# lm1 <- lm(joy_pos_activations~pain*acute_pain_total+chronic_pain_total, data=smaller_chronic)
# relaimpo::calc.relimp(lm1)
# lm2 <- lm(joy_pos_activations~pain*acute_pain_total+chronic_pain_total, data=smaller_nonchronic)
# relaimpo::calc.relimp(lm2)
# lm3 <- lm(tactile_sensitivity_total~age+pain*acute_pain_total+chronic_pain_total, data=smaller_bg)
# relaimpo::calc.relimp(lm3)
# 
# total_coloured <- smaller_bg[,c(5:9,18:31)]
# subs$all_coloured = rowSums(total_coloured)
# mini_df <- 
# corr.test(subs$pain, subs$all_coloured)
# lmP <- lm(all_coloured~pain*age, data=subs)
# relaimpo::calc.relimp(lmP)
# 
# 
# 
# lm1 <- lm(sadness~pain*age, data=smaller_chronic)
# summary(lm1)
# relaimpo::calc.relimp(lm1)
# lm2 <- lm(sadness~pain*age, data=smaller_nonchronic)
# summary(lm2)
# relaimpo::calc.relimp(lm2)
# 
# lm3 <- lm(pain~sadness+depression+anxiety+anger+fear+disgust, data=smaller_chronic)
# summary(lm3)
# relaimpo::calc.relimp(lm3)
# 
# ac <- aov(fear_pos_activations~pain*age*factor(chronicpain), data=subs)
# summary(ac)
# subs_new <- subs
# subs_new$chronicpain <- factor(subs_new$chronicpain)
# lm4 <- lm(joy_pos_activations~pain*age, subset=subs_new$chronicpain==1, data=subs_new)
# summary(lm4)
# relaimpo::calc.relimp(lm4)
# 
# # For the presentation at CERE
# look_at <- c(37:45, 69, 72)
# colnames(subs)[look_at]
# smaller_bg_for_CERE = subs[,look_at]
# new_order <- c(1, 10:11, 4:9, 2:3)
# smaller_bg_for_CERE <- smaller_bg_for_CERE[,new_order]
# correlations <- corr.test(smaller_bg_for_CERE, method='spearman')
# 
# color_palette <- brewer.pal(n = 15, name = "RdBu")
# 
# pdf(paste(location, 'figures/corrs_for_pres.pdf', sep=''), width=10, height=7)
# corrplot(correlations$r, p.mat = correlations$p, sig.level = .05, insig = "blank", 
#          method='circle', type='lower', col = color_palette[11:1],tl.col = "black", tl.srt = 45,
#          title= ' ',mar=c(0,0,1,0), diag=TRUE)
# dev.off()
# 
# # partial correlation between pain intensity, depression, anxiety
# #par_corr <- partial.r(smaller_bg_for_CERE, c(1:3,6:11), c(4,5))
# par_corr <- partial.r(correlations$r, c(1:9), c(10,11))
# par_p <- corr.p(par_corr, n=2054) # NB: corr.p may be applied to the results of partial.r if n is set to n - s (where s is the number of variables partialed out) Fisher, 1924.
# 
# pdf(paste(location, 'figures/corrs_depression_anxiety_partialed_out.pdf', sep=''), width=10, height=7)
# corrplot(par_p$r, p.mat = par_p$p, sig.level = .05, insig = "blank", 
#          method='circle', type='lower', col = color_palette[11:1],tl.col = "black", tl.srt = 45,
#          title= ' ',mar=c(0,0,1,0), diag=TRUE)
# dev.off()
# 
# ggplot(subs, aes(x=subs$pain, y=subs$sadness_neg_activations, color=subs$chronicpain))+
#   geom_jitter(alpha=0.2)
