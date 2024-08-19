library(tidyverse)
library(stringr)
library(tidytext) 
library(tidyr)
library(tm)


df_user <- user_id_tt_df_priv %>% select(user_id, music_id, date, song_title, song_artist, desc)

df_user %>% filter(music_id %in% confirmed | music_id %in% songs) %>% group_by(music_id) %>% summarize(min = min(date), max = max(date))

## Clean text data
df_user$desc <- removePunctuation(df_user$desc)
df_user$desc <- removeNumbers(df_user$desc)
df_user$desc <- tolower(df_user$desc)
df_user$desc <- stripWhitespace(df_user$desc)

## LGBT keywords
vocab <- 'transmasculine|maletofemale|femaletomale|pan|gayteen|crossdresser|lgbtqa|sappho|femme|gayworld|gaylove|gaylife|tboy|tgirl|transman|transwoman|transgirl|transisbeautiful|drag|genderqueer|lgbtcommunity|gayman|pridemonth|lgbtpride|gayboy|gaypride|lgbt|bigender|demiboy|bi|polysexual|gendernonconforming|demisexual|androgynous|lgbtqia|agender|asexual|pride|genderqueer|lesbian|lgbtq|queer|queen|dragqueen|trans|transgender|gaypride|bisexual|wlw|mlm|nblw|nblm|loveislove|genderfluid|gay|pansexual|nonbinary|ftm|mtf|genderqueer'

## Specific "coming out" 
vocab2 <- 'comingout|coming out'

## keyword count in each observation
df_user <- df_user %>%
  mutate(key_count = stringr::str_count(desc, vocab))
## count of coming out terms in each observation
df_user <- df_user %>% 
  mutate(coming_out = stringr::str_count(desc, vocab2))

## assign a one to observations with at least one keyword
df_user$atleast_1 <- NA
df_user$atleast_1[df_user$key_count >= 1] <- 1
df_user$atleast_1[df_user$key_count == 0] <- 0

## change blank values to "No Music ID"
df_user$music_id[df_user$music_id == ""] <- "No Music ID"

songs <- c("6786738129224075266", "222332331146174464", "5000000001388249189", "6879927119904918274") # original "coming out" songs 
songs2 <- c("6744446812653947654", "6736930971020528389", "6765965082246514689", "6717552289336314629", "6738439639826287365", "6758505002894903298") # original "pop" songs
confirmed <- c("6791497454257736453","6697465722806733574", "6692812678622169862", "6723081407045831426")

## create dataframe with sum of key words, proportion of videos with at least one keyword, number of videos, number of distinct users, and proportion of videos posted by distinct users, all by Music ID
df_user_stats <- df_user %>% group_by(song_title, music_id) %>% summarize(key_total = sum(key_count), prop = sum(atleast_1)/length(key_count), n_vids = length(key_count), distinct_users = length(unique(user_id)), avg_vids_per_user = n_vids/distinct_users)


## Create variable that identifies original song types
df_user_stats$soi <- NA
df_user_stats$soi <- 0
df_user_stats$soi[df_user_stats$music_id %in% songs] <- 1
df_user_stats$soi[df_user_stats$music_id %in% songs2] <- 2
df_user_stats$soi[df_user_stats$music_id %in% confirmed] <- 3
# make variable discrete
df_user_stats$soi <- as.factor(df_user_stats$soi)

df_user_stats %>% filter(soi == 3)

# function allows number of vids threshold to be easily changed and percentiles to be re-calculated
n_vid_plot_fn <- function(data, n){
  
  data <- data %>% filter(n_vids >= n)
  
  data$percentile_distinct <- NA
  data$percentile_distinct <- ecdf(1/data$avg_vids_per_user)(1/data$avg_vids_per_user)
  
  ## Create percentiles variable for prop (proportion of videos with at least one keyword) -- higher percentile is better
  data$percentile_prop <- NA
  data$percentile_prop <- ecdf(data$prop)(data$prop)
  
  polygon = data_frame(x = c(0.75, 1, 1, 0.75), y = c(0.75, 0.75, 1, 1))
  
  return(ggplot(data, mapping = aes(x = percentile_distinct, y = percentile_prop, color = soi)) + 
           geom_point(position = "jitter", alpha = 1/2) + 
           geom_polygon(polygon, mapping = aes(x = x, y = y, color = "black"), alpha = 1/100) + 
           scale_color_manual(values = c("gray","red", "blue", "black")))
}


n_vid_df_fn <- function(data, n){
  
  data <- data %>% filter(n_vids >= n)
  
  data$percentile_distinct <- NA
  data$percentile_distinct <- ecdf(1/data$avg_vids_per_user)(1/data$avg_vids_per_user)
  
  ## Create percentiles variable for prop (proportion of videos with at least one keyword) -- higher percentile is better
  data$percentile_prop <- NA
  data$percentile_prop <- ecdf(data$prop)(data$prop)
  
  polygon = data_frame(x = c(0.75, 1, 1, 0.75), y = c(0.75, 0.75, 1, 1))
  
  return(data)
}


# create data at designated n_vid threshold 
df <- n_vid_df_fn(data = df_user_stats, n=30)

# create plot at designated n_vid threshold
n_vid_plot_fn(data = df_user_stats, n=30)


view(df %>% filter(percentile_prop >= 0.99 & percentile_distinct >= 0.75) %>% mutate(score = percentile_distinct*percentile_prop) %>% arrange(desc(score)))


view(df %>% filter(soi == 1 | soi == 3))





