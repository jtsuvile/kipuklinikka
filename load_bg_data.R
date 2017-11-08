rm(list = ls())
library(plyr)
location <- '/Users/jtsuvile/Documents/projects/kipupotilaat/data/'
bgfiles <- c('data.txt','pain_info.txt','BPI_1.txt', 'BPI_2.txt', 'current_feelings.txt') 
profes <- read.csv2('/Users/jtsuvile/Documents/projects/kipupotilaat/code/ammattien_koodit.csv',
                    row.names=NULL, fill=TRUE, col.names=c('code', 'name'), stringsAsFactors = FALSE)

# The background files have following fields:
## data.txt 
# 'sex','age','weight','height','hand','education',
# how much of your work includes 'phys_activity', 'sitting_activity',
# 'profession',
# have you visited: 'psychologist','psychiatrist','neurologist'
## pain_info.txt
# Are you feeling : 'pain_now','pain_recent','chronic_pain',
# do you have following repeated pain conditions? : 'migraine','headache','stomach','backneck','limb','periods', 
# how often do you take following meds?: 'regular_painkillers', 'prescription_painkillers','other_CNS_meds'
## BPI_1.txt 
# describe pain in last 24 hours : 'pain_worst','pain_least','pain_average','pain_now','painkillers_help'
## BPI_2.txt 
# how much pain has impacted : 'general_functioning','mood','walking','working','relationships','sleep','enjoying_life'
## current_feelings.txt
# Right now, how much do you feel: 'pain','depression','anxiety','joy','sadness','anger','fear','surprise','disgust'
 # get subject id's
subs <- read.csv(paste(location, 'mat-files/list.txt', sep=''), header=FALSE)
colnames(subs) <- 'subid'


subs[,c('sex','age','weight','height','hand','education',
        'phys_activity','sitting_activity','profession','psychologist','psychiatrist','neurologist',
        'pain_current','pain_recent','chronic_pain','migraine','headache','stomachache','backneck','limb','periods',
        'regular_painkillers', 'prescription_painkillers','other_CNS_meds',
        'pain_worst','pain_least','pain_average','pain_now','painkillers_help',
        'general_functioning','mood','walking','working','relationships','sleep','enjoying_life',
        'pain','depression','anxiety','joy','sadness','anger','fear','surprise','disgust')] <- NA
class(subs$profession) <- 'character'

for(sub in subs$subid){
  # suppress warnings because our online system ends lines with separator (comma) and R is not happy about it
  subdata = suppressWarnings(read.table(paste(location, 'subjects/', sub, '/data.txt', sep=''), header=FALSE, sep=',', strip.white = TRUE, stringsAsFactors = FALSE))
  # always use last (=most recent) line, in case subject has edited something
  subs[subs$subid==sub,2:13] <- tail(subdata,1)[1:12]
  paindata = suppressWarnings(read.table(paste(location, 'subjects/', sub, '/pain_info.txt', sep=''), header=FALSE, sep=',', strip.white = TRUE, stringsAsFactors = FALSE))
  subs[subs$subid==sub,14:25] <- tail(paindata,1)[1:12]
  if(file.exists(paste(location, 'subjects/', sub, '/BPI_1.txt', sep=''))){
    bpi_1 = suppressWarnings(read.table(paste(location, 'subjects/', sub, '/BPI_1.txt', sep=''), header=FALSE, sep=',', strip.white = TRUE, stringsAsFactors = FALSE))
    subs[subs$subid==sub,26:30] <- tail(bpi_1,1)[1:5]
  }
  if(file.exists(paste(location, 'subjects/', sub, '/BPI_2.txt', sep=''))){
    bpi_2 = suppressWarnings(read.table(paste(location, 'subjects/', sub, '/BPI_2.txt', sep=''), header=FALSE, sep=',', strip.white = TRUE, stringsAsFactors = FALSE))
    subs[subs$subid==sub,31:37] <- tail(bpi_2,1)[1:7]
  }
  feelingsdata = suppressWarnings(read.table(paste(location, 'subjects/', sub, '/current_feelings.txt', sep=''), header=FALSE, sep=',', strip.white = TRUE, stringsAsFactors = FALSE))
  subs[subs$subid==sub,38:46] <- tail(feelingsdata,1)[1:9]
}

#add factors for a more understandable table
subs$sex <- factor(subs$sex, levels=c(0,1,3), labels = c('male','female','other'))
subs$hand <- factor(subs$hand, levels=c(0,1), labels = c('left','right'))
subs$education <- factor(subs$education, levels=c(1,2,3,4), labels=c('peruskoulu','ammattikoulu','ammattikorkea','yliopisto'))
subs$regular_painkillers <- factor(subs$regular_painkillers, levels=c(1,2,3,4,5), labels=c('daily','weekly','montly','not_even_montly','never'))
subs$prescription_painkillers <- factor(subs$prescription_painkillers, levels=c(1,2,3,4,5), labels=c('daily','weekly','montly','not_even_montly','never'))
subs$other_CNS_meds <- factor(subs$other_CNS_meds, levels=c(1,2,3,4,5), labels=c('daily','weekly','montly','not_even_montly','never'))
subs$migraine <- factor(subs$migraine, levels=c(0,1,3), labels=c('no', 'yes', 'not_recently'))
subs$headache <- factor(subs$headache, levels=c(0,1,3), labels=c('no', 'yes', 'not_recently'))
subs$stomachache <- factor(subs$stomachache, levels=c(0,1,3), labels=c('no', 'yes', 'not_recently'))
subs$backneck <- factor(subs$backneck, levels=c(0,1,3), labels=c('no', 'yes', 'not_recently'))
subs$limb <- factor(subs$limb, levels=c(0,1,3), labels=c('no', 'yes', 'not_recently'))
subs$periods <- factor(subs$periods, levels=c(0,1,3), labels=c('no', 'yes', 'not_recently'))

# replace work codes with human-readable text
profes <- profes[!(profes$name==''), ]
subs$ammatti <- mapvalues(subs$profession, profes$code, profes$name, warn_missing = FALSE)

write.csv(subs, paste(location,'subs_bg_info.csv'))
