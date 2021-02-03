make_total_colouring_columns <- function(data){
  data2 <- data %>% mutate(sadness_total = emotions_0_neg_color + emotions_0_pos_color,
                  happiness_total = emotions_1_neg_color + emotions_1_pos_color,
                  anger_total = emotions_2_neg_color + emotions_2_pos_color, 
                  surprise_total = emotions_3_neg_color + emotions_3_pos_color,
                  fear_total = emotions_4_neg_color + emotions_4_pos_color,
                  disgust_total = emotions_5_neg_color + emotions_5_pos_color, 
                  neutral_total = emotions_6_neg_color + emotions_6_pos_color)
  return(data2)
}

rename_emotions <- function(data){
  new_colnames <- colnames(data) %>% str_replace('emotions_0', 'sadness') %>% 
    str_replace('emotions_1', 'happiness') %>% 
    str_replace('emotions_2', 'anger') %>% 
    str_replace('emotions_3', 'surprise') %>% 
    str_replace('emotions_4', 'fear') %>% 
    str_replace('emotions_5', 'disgust') %>% 
    str_replace('emotions_6', 'neutral')
  colnames(data) <- new_colnames
  return(data)
}

rename_sensitivity <- function(data){
  new_colnames <- colnames(data) %>% str_replace('sensitivity_0', 'tactile') %>% 
    str_replace('sensitivity_1', 'nociceptive') %>% 
    str_replace('sensitivity_2', 'hedonic') 
  colnames(data) <- new_colnames
  return(data)
}

rename_pain <- function(data){
  new_colnames <- colnames(data) %>% str_replace('pain_0', 'currpain') %>% 
    str_replace('pain_1', 'chronpain')
  colnames(data) <- new_colnames
  return(data)
}