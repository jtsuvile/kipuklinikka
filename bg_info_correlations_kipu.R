rm(list = ls())
library(psych)
library(stats)
library(corrplot)
library(RColorBrewer)
#library(Hmisc)
library(tidyverse)
library(cocor)

location <- '/Users/juusu53/Documents/projects/kipupotilaat/data/'
subs <- read_csv(paste(location, 'matched_controls_with_activations_18_11_2020.csv', sep='')) %>% 
  select(age, feels_pain, pain_0_pos_color, pain_1_pos_color,
         sensitivity_0_pos_color, sensitivity_1_pos_color, sensitivity_2_pos_color,
         feels_anxiety, feels_depression, feels_sad, 
         feels_happy, feels_angry, feels_fear,feels_surprise, feels_disgust) %>% 
  rename(current_pain = pain_0_pos_color,
         chronic_pain = pain_1_pos_color,
         tactile_sensitivity = sensitivity_0_pos_color,
         nociceptive_sensitivity = sensitivity_1_pos_color,
         hedonic_sensitivity = sensitivity_2_pos_color)

pain_duration <- read_csv2(paste(location, 'pain_start_helsinki_summer2019.csv', sep=''))
subs_pain <- read_csv(paste(location, 'all_pain_patients_with_activations_19_10_2020.csv', sep='')) %>% 
  select(subid, age, feels_pain, pain_0_pos_color, pain_1_pos_color,
         sensitivity_0_pos_color, sensitivity_1_pos_color, sensitivity_2_pos_color,
         feels_anxiety, feels_depression, feels_sad, 
         feels_happy, feels_angry, feels_fear,feels_surprise, feels_disgust) %>% 
  merge(pain_duration, by="subid", all.x=TRUE) %>% 
  rename(current_pain = pain_0_pos_color,
         chronic_pain = pain_1_pos_color,
         tactile_sensitivity = sensitivity_0_pos_color,
         nociceptive_sensitivity = sensitivity_1_pos_color,
         hedonic_sensitivity = sensitivity_2_pos_color) %>% 
  rename_with(str_replace,
              starts_with('feels'),
              pattern = 'feels',
              replacement = 'rating') %>% 
  select(-subid)

correlations <- corr.test(subs_pain)

color_palette <- brewer.pal(n = 11, name = "RdBu")

pdf('/Users/juusu53/Documents/projects/kipupotilaat/figures/smaller_correlations_pain_patients_lower.pdf', width=10, height=7)
corrplot(correlations$r, p.mat = t(correlations$p), sig.level = .05, insig = "blank", 
         method='circle', type='lower',
         col = color_palette[11:1],tl.col = "black", tl.srt = 45,
         title= 'Pain patients',mar=c(0,0,1,0), diag=FALSE)
dev.off()

correlations2 <- corr.test(subs)
pdf('/Users/juusu53/Documents/projects/kipupotilaat/figures/smaller_correlations_matched_controls_upper.pdf', width=10, height=7)
# corrplot(correlations2$r, p.mat = t(correlations2$p), sig.level = .05, insig = "blank", 
#          method='circle', type='lower',
#          col = color_palette[11:1],tl.col = "black", tl.srt = 45,
#          title= 'Matched controls',mar=c(0,0,1,0), diag=FALSE)
corrplot(correlations2$r, p.mat = correlations2$p, sig.level = .05, insig = "blank", 
         method='circle', type='upper',
         col = color_palette[11:1],tl.col = "black", tl.srt = 45,
         title= 'Matched controls',mar=c(0,0,1,0), diag=FALSE)

dev.off()

### testing

corrplot(correlations$r, p.mat = correlations$p, sig.level = .05, insig = "blank", 
         method='circle', type='full',
         col = color_palette[11:1],tl.col = "black", tl.srt = 45,
         title= 'Pain patients',mar=c(0,0,1,0), diag=FALSE)

corrplot(correlations2$r, p.mat = correlations2$p, sig.level = .05, insig = "blank", 
         method='circle', type='full',
         col = color_palette[11:1],tl.col = "black", tl.srt = 45,
         title= 'Matched controls',mar=c(0,0,1,0), diag=FALSE)

subs %>% mutate(su)
correlations <- corr.test(subs_pain)
correlations2 <- corr.test(subs)


names_1 <- colnames(correlations$r)
names_2 <- colnames(correlations2$r)
fishers_z <- matrix(, nrow = length(names_2), ncol = length(names_2))
fishers_p <- matrix(, nrow = length(names_2), ncol = length(names_2))

for (i in 1:(length(names_2)-1)){
  for(j in (i+1):length(names_2)){
    print(i)
    print(j)
    res <- cocor.indep.groups(correlations$r[names_1[i],names_1[j]], correlations2$r[names_2[i],names_2[j]],
                              correlations$n[names_1[i],names_1[j]], correlations2$n)
    print(res@fisher1925$p.value)
    fishers_z[i,j] <- res@fisher1925$statistic
    fishers_p[i,j] <- res@fisher1925$p.value
  }
}

pvals <- c(fishers_p)
pvals_corrected <- p.adjust(pvals, method='fdr')
sum(pvals_corrected < 0.05, na.rm=T)
ind_sig <- which(pvals_corrected < 0.05)

tbl <- matrix(, nrow = length(ind_sig), ncol = 2)

for(k in 1:length(ind_sig)){
  ind <- which(fishers_p == pvals[ind_sig[k]], arr.ind=T, useNames=F)
  tbl[k,] = c(names_2[ind[1]],names_2[ind[2]])
  }

write_csv(as.data.frame(tbl), '/Users/juusu53/Documents/projects/kipupotilaat/figures/sig_diff_correlations.csv')

