rm(list = ls())
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

emotions <- c('sadness','happiness','anger','surprise','fear','disgust','neutral')
pains <- c('acute_pain','chronic_pain')
sensitivity <- c('tactile_sensitivity', 'pain_sensitivity','hedonic_sensitivity')

look_at_names <- c('age','BMI','work_physical','work_sitting','feels_pain', 'acute_pain_total', 'chronic_pain_total', 'tactile_sensitivity_total', 'pain_sensitivity_total', 
                   'hedonic_sensitivity_total',
                   'feels_anxiety', 'feels_depression', 'feels_sad', 'feels_happy', 'feels_angry', 'feels_fear','feels_surprise',  'feels_disgust',
                   'sadness_pos_activations', 'sadness_neg_activations', 'happiness_pos_activations', 'happiness_neg_activations',
                   'anger_pos_activations', 'anger_neg_activations', 'surprise_pos_activations', 'surprise_neg_activations',
                   'fear_pos_activations', 'fear_neg_activations', 'disgust_pos_activations', 'disgust_neg_activations', 'neutral_pos_activations',
                   'neutral_neg_activations')

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
subs <- subs %>% mutate(BMI=weight/(height/100)^2)

smaller_bg <- subs %>% select(all_of(look_at_names))

# new_order <- c(1:4, 27:31, 5:26)
# smaller_bg <- smaller_bg[,new_order]
correlations <- corr.test(smaller_bg, adjust='fdr')
color_palette <- brewer.pal(n = 11, name = "RdBu")


#NB: corr.test gives p-adjusted values in upper triangle
# since I prefer looking at the lower triangle, need to transpose the p matrix prior to plotting
pdf('/Users/juusu53/Documents/projects/kipupotilaat/figures/correlations_KI_all_patients.pdf', width=10, height=7)
corrplot(correlations$r, p.mat = t(correlations$p), sig.level = .05, insig = "blank", 
         method='circle',  type='lower', col = color_palette[11:1],tl.col = "black", tl.srt = 45,
         title= 'All KI pain patients',mar=c(0,0,1,0), diag=FALSE)
text(28, 25,'only significant (p<0.05) correlations shown \n(FDR corrected)')
dev.off()

fibro <- subs %>%  filter(pain_type=='Fibromyalgi') %>% select(all_of(look_at_names))
lbp <- subs %>%  filter(pain_type=='Lower back') %>% select(all_of(look_at_names))

correlations_fibro <- corr.test(fibro, adjust='fdr')
correlations_lbp <- corr.test(lbp, adjust='fdr')

pdf('/Users/juusu53/Documents/projects/kipupotilaat/figures/correlations_KI_fibromyalgia_patients.pdf', width=10, height=7)
corrplot(correlations_fibro$r, p.mat = t(correlations$p), sig.level = .05, insig = "blank", 
         method='circle', type='lower', col = color_palette[11:1],tl.col = "black", tl.srt = 45,
         title= 'Fibromyalgia patients',mar=c(0,0,1,0), diag=FALSE)
text(28, 25,'only significant (p<0.05) correlations shown \n(FDR corrected)')
dev.off()

pdf('/Users/juusu53/Documents/projects/kipupotilaat/figures/correlations_KI_lbp_patients.pdf', width=10, height=7)
corrplot(correlations_lbp$r, p.mat = t(correlations$p), sig.level = .05, insig = "blank", 
         method='circle', type='lower', col = color_palette[11:1],tl.col = "black", tl.srt = 45,
         title= 'Lower back pain patients',mar=c(0,0,1,0), diag=FALSE)
text(28, 25,'only significant (p<0.05) correlations shown \n(FDR corrected)')
dev.off()

