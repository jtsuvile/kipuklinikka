rm(list = ls())
library(gsubfn)
library(utf8)

se <- read.csv('/Users/jtsuvile/Documents/projects/kipupotilaat/ammatit_SE_raw.csv', header=F, sep=';',encoding = "UTF-8", fill=T, stringsAsFactors = F)
orig <- read.csv('/Users/jtsuvile/Documents/projects/kipupotilaat/ammatit_FI.csv', header=F, sep= ';', encoding = "UTF-8", stringsAsFactors = F)

se_classes <- orig

for(i in 1:dim(orig)[1]){
  prof_code <- strapplyc(orig$V2[i], "\\D([0-9]+) [:blank:]*", simplify = TRUE)
  if(!length(prof_code[[1]])==0){
    ind_se <- which(se$V1 == prof_code)
    se_classes[i,'V7'] <- se$V2[ind_se]
  }
}
se_classes$V1 <- NULL
se_classes$V9 <- NULL

write.csv(se_classes, '/Users/jtsuvile/Documents/projects/kipupotilaat/ammatit_SE_new.csv',row.names=FALSE, quote = FALSE, sep=';')


iconv(se_classes, "LATIN2", "UTF-8")
