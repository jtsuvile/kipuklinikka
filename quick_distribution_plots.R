library(tidyverse)
library(ggridges)

location <- '/Users/juusu53/Documents/projects/kipupotilaat/data/'
subs <- read.csv(paste(location, 'all_pain_patients_with_activations_09_2020_threshold_0_007.csv', sep=''))

subs_long <- subs %>% pivot_longer(emotions_0_pos_color:sensitivity_2_pos_color, names_to = 'colouring_task', 
                                   values_to = 'prop_coloured') %>% 
  separate(colouring_task, c("type","number","direction"), extra="drop", remove=FALSE) 

label_names = c('sadness','happiness','anger','surprise','fear','disgust','neutral',
                'acute_pain','chronic_pain', 
                'tactile_sensitivity', 'pain_sensitivity','hedonic_sensitivity')

ggplot(subs_long, aes(x = prop_coloured, y = colouring_task)) +
  geom_density_ridges(aes(fill=direction),
    jittered_points = TRUE,
    position = position_points_jitter(width = 0.005, height = 0),
    point_shape = '|', point_size = 3, point_alpha = 1, alpha = 0.7) +
  scale_fill_manual(labels = c("Inactivations", "Activations"), values = c("royalblue2", "tomato3")) +
  theme_minimal()

