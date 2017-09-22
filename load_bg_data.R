rm(list = ls())
location <- '/Users/jtsuvile/Documents/projects/kipupotilaat/data/'
 
 # get subject id's
subs <- read.csv(paste(location, 'mat-files/list.txt', sep=''), header=FALSE)
colnames(subs) <- 'subid'
subs[,c('sex','age','weight','height','hand','education','phys_activity','sitting_activity','profession','psychologist','psychiatrist','neurologist')] <- NA
class(subs$profession) <- 'character'
for(sub in subs$subid){
  #suppress warnings because our online system ends lines with separator (comma) and R is not happy about it
  subdata = suppressWarnings(read.table(paste(location, 'subjects/', sub, '/data.txt', sep=''), header=FALSE, sep=',', strip.white = TRUE, stringsAsFactors = FALSE))
  subs[subs$subid==sub,2:13] <- subdata[1:12]
}
