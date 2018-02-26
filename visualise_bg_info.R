rm(list = ls())
location <- '/Users/jtsuvile/Documents/projects/kipupotilaat/data/'
subs <- read.csv('/Users/jtsuvile/Documents/projects/kipupotilaat/data/subs_bg_info.csv')
painless_subs <- subs[subs$pain_current==0&subs$pain_recent==0&subs$chronic_pain==0,]

pdf(paste(location, 'figures/age_distribution_by_frequency.pdf', sep=''))
hist(subs$age[subs$sex == 'female'], freq=TRUE, col=rgb(1,0,0,0.5),
     main='Age distribution by gender in whole sample', xlab='age', 
     xlim=c(10,100), ylim=c(0,500), breaks=20)
hist(subs$age[subs$sex == 'male'], add=T, freq=TRUE, col=rgb(0,0,1,0.5), breaks=20)
dev.off()

pdf(paste(location, 'figures/painless_subs_age_distribution_by_proportion.pdf', sep=''))
hist(painless_subs$age[painless_subs$sex == 'female'], freq=FALSE, col=rgb(1,0,0,0.5),
     main='Age distribution by gender in painless subs', xlab='age', 
     xlim=c(10,100), ylim=c(0,0.10), breaks=10)
hist(painless_subs$age[painless_subs$sex == 'male'], add=T, freq=FALSE, col=rgb(0,0,1,0.5),breaks=10)
dev.off()