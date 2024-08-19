library(tidyverse)
library(stringr)

head(tiktok_user_df2)
head(user_id_tt_df_priv)

lgbt_songs <- c("6786738129224075266", "222332331146174464", "5000000001388249189", "6879927119904918274")


# LGBT Songs
user_id_tt_df_priv %>% filter(music_id == "6786738129224075266") %>% group_by(music_id) %>% count() # Hayloft 
user_id_tt_df_priv %>% filter(music_id == "222332331146174464") %>% group_by(music_id) %>% count() # Sweater Weather
user_id_tt_df_priv %>% filter(music_id == "5000000001388249189") %>% group_by(music_id) %>% count() # Girls
user_id_tt_df_priv %>% filter(music_id == "6879927119904918274") %>% group_by(music_id) %>% count() # Lucy 

# Low User LGBT Songs 
user_id_tt_df_priv2 %>% filter(music_id == "6786738129224075266") %>% group_by(music_id) %>% count() # Hayloft 
user_id_tt_df_priv2 %>% filter(music_id == "222332331146174464") %>% group_by(music_id) %>% count() # Sweater Weather
user_id_tt_df_priv2 %>% filter(music_id == "5000000001388249189") %>% group_by(music_id) %>% count() # Girls
user_id_tt_df_priv2 %>% filter(music_id == "6879927119904918274") %>% group_by(music_id) %>% count() # Lucy 

# LGBT Density Plots
user_id_tt_df_priv %>% filter(music_id == "6786738129224075266") %>% ggplot(mapping = aes(x = date)) + geom_density() # Hayloft 
user_id_tt_df_priv %>% filter(music_id == "222332331146174464") %>% ggplot(mapping = aes(x = date)) + geom_density() # Sweater Weather
user_id_tt_df_priv %>% filter(music_id == "5000000001388249189") %>% ggplot(mapping = aes(x = date)) + geom_density() # Girls
user_id_tt_df_priv %>% filter(music_id == "6879927119904918274") %>% ggplot(mapping = aes(x = date)) + geom_density() # Lucy 

# Pop Songs
user_id_tt_df_priv %>% filter(music_id == "6765965082246514689") %>% group_by(music_id) %>% count() # Blinding Lights
user_id_tt_df_priv %>% filter(music_id == "6717552289336314629") %>% group_by(music_id) %>% count() # Dance Monkey 
user_id_tt_df_priv %>% filter(music_id == "6738439639826287365") %>% group_by(music_id) %>% count() # Roses
user_id_tt_df_priv %>% filter(music_id == "6758505002894903298") %>% group_by(music_id) %>% count() # Before you go

# Pop Density Plots
user_id_tt_df_priv %>% filter(music_id == "6765965082246514689") %>% ggplot(mapping = aes(x = date)) + geom_density() # Blinding Lights
user_id_tt_df_priv %>% filter(music_id == "6717552289336314629") %>% ggplot(mapping = aes(x = date)) + geom_density() # Dance Monkey 
user_id_tt_df_priv %>% filter(music_id == "6738439639826287365") %>% ggplot(mapping = aes(x = date)) + geom_density() # Roses
user_id_tt_df_priv %>% filter(music_id == "6758505002894903298") %>% ggplot(mapping = aes(x = date)) + geom_density() # Before you go

# TikTok Popular Songs 
user_id_tt_df_priv %>% filter(music_id == "6744446812653947654") %>% group_by(music_id) %>% count() # Lottery
user_id_tt_df_priv %>% filter(music_id == "6736930971020528389") %>% group_by(music_id) %>% count() # Relationship

# TikTok Desnity Plots 
user_id_tt_df_priv %>% filter(music_id == "6744446812653947654") %>% ggplot(mapping = aes(x = date)) + geom_density() # Lottery
user_id_tt_df_priv %>% filter(music_id == "6736930971020528389") %>% ggplot(mapping = aes(x = date)) + geom_density() # Relationship


## All TikToks Density Plot 
user_id_tt_df_priv %>% ggplot(mapping = aes(x = date)) + geom_density()


## All TikToks between April 1, 2020 and March 1, 2021
user_id_tt_df_priv %>% filter(date >= "2020-04-01" & date <= "2021-03-01") %>% ggplot(mapping = aes(x = date)) + geom_freqpoly()


user_id_tt_df_priv %>% group_by(date) %>% arrange(desc(date))


user_id_tt_df_priv %>% filter(music_id == "6847647314127932166") %>% group_by(music_id) %>% count() # 


user_id_tt_df_priv %>% group_by(tiktok_id, date) %>% count() %>% arrange(desc(date))

user_id_tt_df_priv$id_length <- NA

user_id_tt_df_priv$id_length <- unlist(map(user_id_tt_df_priv$tiktok_id, str_length))

view(user_id_tt_df_priv %>% group_by(id_length, date) %>% count() %>% arrange((date)))

user_vids <- user_id_tt_df_priv %>% group_by(user_id) %>% count() %>% arrange(desc(n))

low_user_vids <- user_vids %>% filter(n < 1500)

low_users <- low_user_vids$user_id


user_id_tt_df_priv2 <- user_id_tt_df_priv[user_id_tt_df_priv$user_id %in% low_users, ]

user_df <- user_id_tt_df_priv2[user_id_tt_df_priv2$music_id %in% lgbt_songs, ]

user_df %>% group_by(user_id) %>% count()


