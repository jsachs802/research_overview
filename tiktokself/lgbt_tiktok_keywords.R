### Text Analysis of Songs 

library(tidyverse)
library(stringr)
library(tidytext) 
library(tidyr)
library(tm)

df <- user_id_tt_df_priv

df <- df %>% select(music_id, song_title, song_artist, desc)

head(df)

df$desc <- removePunctuation(df$desc)
df$desc <- removeNumbers(df$desc)
df$desc <- tolower(df$desc)
df$desc <- stripWhitespace(df$desc)

vocab <- 'transmasculine|maletofemale|femaletomale|pan|gayteen|crossdresser|lgbtqa|sappho|femme|gayworld|gaylove|gaylife|tboy|tgirl|transman|transwoman|transgirl|transisbeautiful|drag|genderqueer|lgbtcommunity|gayman|pridemonth|lgbtpride|gayboy|gaypride|lgbt|bigender|demiboy|bi|polysexual|gendernonconforming|demisexual|androgynous|lgbtqia|agender|asexual|pride|genderqueer|lesbian|lgbtq|queer|queen|dragqueen|trans|transgender|gaypride|bisexual|wlw|mlm|nblw|nblm|loveislove|genderfluid|gay|pansexual|nonbinary|ftm|mtf|genderqueer'

vocab2 <- 'comingout|coming out'



df2 <- df %>%
  mutate(key_count = stringr::str_count(desc, vocab))

df3 <- df2 %>% group_by(music_id) %>% summarize(key_total = sum(key_count)) %>% arrange(desc(key_total))

df4 <- df2 %>% group_by(music_id) %>% count() %>% arrange(desc(n))

songs <- c("6786738129224075266", "222332331146174464", "5000000001388249189", "6879927119904918274")

songs2 <- c("6744446812653947654", "6736930971020528389", "6765965082246514689", "6717552289336314629", "6738439639826287365", "6758505002894903298")

df5 <- merge(df3, df4, b.x = "music_id", by.y = "music_id")


df5$perc = df5$key_total/df5$n

df5$soi <- 0
df5$soi[df5$music_id %in% songs] <- 1
df5$soi[df5$music_id %in% songs2] <- 2

save(df5, file = "df5.Rda")


## two top tiktok songs released prior to pandemic


df5 <- df5 %>% arrange(desc(key_total))

df5 %>% filter(soi == 2)

nrow(df5 %>% filter(perc >= 0.30))


df5 %>% filter(perc >= 0.30) %>% summarize(total = sum(n))


df_alt <- df %>%
  mutate(key_count = stringr::str_count(desc, vocab))

df_alt3 <- df_alt %>% 
  mutate(coming_out = stringr::str_count(desc, vocab2))

df_alt3 %>% filter(atleast_1 == 1 & coming_out >= 1) %>% group_by(music_id) %>% summarize(avg_keycount = mean(key_count, na.rm = T))

head(df_alt)

df_alt$atleast_1 <- NA
df_alt$atleast_1[df_alt$key_count >= 1] <- 1
df_alt$atleast_1[df_alt$key_count == 0] <- 0


df_alt4 <- df_alt3 %>% group_by(music_id) %>% summarize(key_total = sum(key_count), prop = sum(atleast_1)/length(key_count), n_vids = length(key_count), coming_out = sum(coming_out)) %>% arrange(desc(coming_out))

head(df_alt4)

df_alt2 %>% filter(music_id %in% songs)

songs <- c("6786738129224075266", "222332331146174464", "5000000001388249189", "6879927119904918274")

songs2 <- c("6744446812653947654", "6736930971020528389", "6765965082246514689", "6717552289336314629", "6738439639826287365", "6758505002894903298")


df_alt2$term_to_vid = df_alt2$key_total/df_alt2$n_vids

df_alt2$soi <- NA
df_alt2$soi <- 0
df_alt2$soi[df_alt2$music_id %in% songs] <- 1
df_alt2$soi[df_alt2$music_id %in% songs2] <- 2

df_alt2 %>% filter(music_id %in% songs2)

prop_df <- df_alt2 %>% filter(prop >= 0.3)



df_user <- user_id_tt_df_priv %>% select(user_id, music_id, song_title, song_artist, desc)

df_user %>% filter(music_id %in% prop_df$music_id) %>% group_by(user_id, music_id) %>% count() %>% arrange(desc(n))

df_user %>% group_by(user_id, music_id) %>% count() %>% summarize(n = n, length = length(music_id)) %>% arrange(desc(n))


