rm(list = ls())
library(psych)
library(corrplot)
library(RColorBrewer)
#library(Hmisc)

location <- '/Users/jtsuvile/Documents/projects/kipupotilaat/data/'
subs <- read.csv(paste(location, 'subs_bg_info_with_masked_activations.csv', sep=''))
size_frontbackmask <- 91840 #pixels
emotions <- c('sadness','joy','anger','surprise','fear','disgust','neutral')
pains <- c('acute_pain','chronic_pain')
sensitivity <- c('tactile_sensitivity', 'pain_sensitivity','hedonic_sensitivity')
varnames <- colnames(subs)
for(i in 1:7){
  varnames = gsub(paste("emotions", i-1, sep='_'), emotions[i], varnames)
}
for(j in 1:2){
  varnames = gsub(paste("pain", j-1, sep='_'), pains[j], varnames)
}
for(k in 1:3){
  varnames = gsub(paste("sensitivity", k-1, sep='_'), sensitivity[k], varnames)
}
varnames = gsub("_pos", '_pos_activations', varnames)
varnames = gsub("_neg", '_neg_activations', varnames)

colnames(subs)<- varnames

table(subs$sex)
table(subs$paincurrent)
table(subs$chronicpain)
table(subs$painrecent)
mean(subs$painaverage, na.rm=T)
sd(subs$painaverage, na.rm=T)

mean(subs$chronic_pain_total, na.rm=T)
sd(subs$chronic_pain_total, na.rm=T)
mean(subs$acute_pain_total, na.rm=T)
sd(subs$acute_pain_total, na.rm=T)

mean(subs$sittingactivity, na.rm=T)
sd(subs$sittingactivity, na.rm=T)
mean(subs$physactivity, na.rm=T)
sd(subs$physactivity, na.rm=T)

look_at <- c(3,8:9, 37:47, 49:50, 52:53, 55:56, 58:59,61:62,64:65,69, 72, 75, 78, 81)
varnames[look_at]
smaller_bg = subs[,look_at]
new_order <- c(1:4, 27:31, 5:26)
smaller_bg <- smaller_bg[,new_order]
correlations <- corr.test(smaller_bg)

color_palette <- brewer.pal(n = 11, name = "RdBu")

pdf(paste(location, 'figures/all_kinds_of_correlations.pdf', sep=''), width=10, height=7)
corrplot(correlations$r, p.mat = correlations$p, sig.level = .05, insig = "blank", 
         method='circle', type='lower', col = color_palette[11:1],tl.col = "black", tl.srt = 45,
         title= 'All subjects',mar=c(0,0,1,0), diag=FALSE)
dev.off()

subs_chronic <- subs[subs$chronicpain==1&subs$pain!=0,]
subs_nonchronic <- subs[subs$chronicpain==0&subs$pain!=0,]
subs_nonpain <- subs[subs$chronicpain==0&subs$painrecent==0&subs$pain==0,]

smaller_chronic = subs_chronic[,look_at]
smaller_nonchronic = subs_nonchronic[,look_at]
smaller_nonpain = subs_nonpain[,look_at]

smaller_chronic = smaller_chronic[,new_order]
smaller_nonchronic = smaller_nonchronic[,new_order]
smaller_nonpain = smaller_nonpain[,new_order]

corr_chronic <- corr.test(smaller_chronic)
corr_nonchronic <- corr.test(smaller_nonchronic)
corr_nonpain <- corr.test(smaller_nonpain)

pdf(paste(location, 'figures/all_kinds_of_correlations_chronic_pain_curr_pain.pdf', sep=''), width=10, height=7)
corrplot(corr_chronic$r, p.mat = corr_chronic$p, sig.level = .05, insig = "blank", 
         method='circle', type='lower', col = color_palette[11:1],tl.col = "black", tl.srt = 45,
         title='Subjects with history of chronic pain',mar=c(0,0,1,0), diag=FALSE)
dev.off()

pdf(paste(location, 'figures/all_kinds_of_correlations_nonchronic_curr_pain.pdf', sep=''), width=10, height=7)
corrplot(corr_nonchronic$r, p.mat = corr_nonchronic$p, sig.level = .05, insig = "blank", 
         method='circle', type='lower', col = color_palette[11:1],tl.col = "black", tl.srt = 45,
         title='Subjects with NO history of chronic pain',mar=c(0,0,1,0), diag=FALSE)
dev.off()

pdf(paste(location, 'figures/all_kinds_of_correlations_no_pain.pdf', sep=''), width=10, height=7)
corrplot(corr_nonpain$r, p.mat = corr_nonpain$p, sig.level = .05, insig = "blank", 
         method='circle', type='lower', col = color_palette[11:1],tl.col = "black", tl.srt = 45,
         mar=c(0,0,1,0), diag=FALSE)
dev.off()


t.test(subs[subs$chronicpain==1,'tactile_sensitivity_total'], subs[subs$chronicpain==0,'tactile_sensitivity_total'])
t.test(subs[subs$chronicpain==1,'joy'], subs[subs$chronicpain==0,'joy'])

lm1 <- lm(joy_pos_activations~pain*acute_pain_total+chronic_pain_total, data=smaller_chronic)
relaimpo::calc.relimp(lm1)
lm2 <- lm(joy_pos_activations~pain*acute_pain_total+chronic_pain_total, data=smaller_nonchronic)
relaimpo::calc.relimp(lm2)
lm3 <- lm(tactile_sensitivity_total~age+pain*acute_pain_total+chronic_pain_total, data=smaller_bg)
relaimpo::calc.relimp(lm3)

total_coloured <- smaller_bg[,c(5:9,18:31)]
subs$all_coloured = rowSums(total_coloured)
mini_df <- 
corr.test(subs$pain, subs$all_coloured)
lmP <- lm(all_coloured~pain*age, data=subs)
relaimpo::calc.relimp(lmP)



lm1 <- lm(sadness~pain*age, data=smaller_chronic)
summary(lm1)
relaimpo::calc.relimp(lm1)
lm2 <- lm(sadness~pain*age, data=smaller_nonchronic)
summary(lm2)
relaimpo::calc.relimp(lm2)

lm3 <- lm(pain~sadness+depression+anxiety+anger+fear+disgust, data=smaller_chronic)
summary(lm3)
relaimpo::calc.relimp(lm3)

ac <- aov(fear_pos_activations~pain*age*factor(chronicpain), data=subs)
summary(ac)
subs_new <- subs
subs_new$chronicpain <- factor(subs_new$chronicpain)
lm4 <- lm(joy_pos_activations~pain*age, subset=subs_new$chronicpain==1, data=subs_new)
summary(lm4)
relaimpo::calc.relimp(lm4)