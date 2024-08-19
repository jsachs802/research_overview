### TikTok Song Validations 

library(tidyverse)

df <- user_id_tt_df_priv

df2 <- df %>% filter(music_id == "6786738129224075266" | music_id == "222332331146174464" | music_id == "5000000001388249189" | music_id == "6879927119904918274")

min_n <- df2 %>% filter(date <= "2020-03-01") %>% group_by(music_id) %>% count()

max_n <- df2 %>% filter(date > "2020-03-01") %>% group_by(music_id) %>% count() %>% mutate(max_n = n)

df_gen <- df2 %>% group_by(music_id) %>% summarize(date_min = min(date), date_max = max(date))

total <- df2 %>% group_by(music_id) %>% count()

df_gen$min_n <- NA
df_gen$min_n <- c(36, 18, 0, 0)

df_gen$max_n <- NA
df_gen$max_n <- max_n$max_n

df_gen$total <- NA
df_gen$total <- total$n
  

df_gen <- df_gen %>% select(music_id, min_n, date_min, max_n, date_max, total)

df_gen
  
gender_songs <- c("6786738129224075266","222332331146174464", "5000000001388249189", "6879927119904918274")

df %>% filter(date > "2020-03-01") %>% 
  group_by(music_id) %>% 
  count() %>% 
  ungroup() %>% 
  summarize(mean_n_post = mean(n, na.rm = T), 
            med_n_post = median(n, na.rm = T), 
            sd_n_post = sd(n, na.rm = T), 
            total_post = sum(n))

