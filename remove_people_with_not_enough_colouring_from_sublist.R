library(tidyverse)
data <- read.csv('/Users/juusu53/Documents/projects/kipupotilaat/data/controls/all_healthy_with_activations.csv')
sublist <- read.csv('/Users/juusu53/Documents/projects/kipupotilaat/data/controls/subs.txt', header=FALSE)

failed_qc_subids <- data %>% select(subid, emotions_0_pos_color:sensitivity_2_pos_color) %>% 
  pivot_longer(emotions_0_pos_color:sensitivity_2_pos_color, values_to = "coloured", names_to = "task" ) %>% 
  group_by(subid) %>% summarise(max(coloured)) %>% filter(`max(coloured)` < 0.1) %>% 
  select(subid)

passed_qc_sublist <- sublist %>% filter(!(V1 %in% failed_qc_subids$subid))

fil <- file("/Users/juusu53/Documents/projects/kipupotilaat/data/controls/subjects_failed_colouring_qc.txt", open="w")
write_lines(failed_qc_subids$subid, fil)
close(fil)

fil1 <- file("/Users/juusu53/Documents/projects/kipupotilaat/data/controls/subs_pass_qc.txt", open="w")
write_lines(passed_qc_sublist$V1, fil1)
close(fil1)
