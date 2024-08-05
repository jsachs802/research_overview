
## The TRUMP EFFECT ##

## Libraries
library(quanteda)
library(conText)
library(tidyverse)

## -------
## Prepare
## -------

## Pre-treatment Twitter data
load("~/Dropbox/sachs_karell_paper/trump_twitter/Trump Tweets/Data/trump_follower_tweets_11_21.Rda")

## Post-treatment Twitter data 
setwd("~/Dropbox/sachs_karell_paper/trump_twitter/Trump Tweets/Data/Updates")
fn <- list.files()
load(fn[1])
udf <- update
for(i in 2:length(fn)){
  load(fn[i])
  udf <- bind_rows(udf, update)
}
# complete data
mdf1 <- bind_rows(tweets_before, udf) %>% 
  # remove duplicate tweets
  filter(!duplicated(tweet_id)) %>%
  # adjust for timezone (UTC to EST)
  mutate(created_at2 = lubridate::ymd_hms(created_at, tz = "UTC"),
         time = lubridate::with_tz(created_at2, tzone = "EST")) %>%
  filter(!is.na(created_at2)) %>%
  # treatment indicator
  mutate(reinstatement = NA,
         reinstatement = ifelse(time >= "2022-11-18 19:47:00", 1 ,0)) %>%
  # placebo treatment
  mutate(control = NA,
         control = ifelse(time >= "2022-11-17 19:47:00", 1, 0))
# retain users who tweets before treatment
pre_users <- mdf1 %>% 
  mutate(preexistance = ifelse(time < "2022-11-18 19:47:00", 1, 0)) %>% 
  group_by(user_id) %>%
  summarise(preexistance_sum = sum(preexistance)) %>%
  filter(!preexistance_sum < 1)
mdf1 <- mdf1[mdf1$user_id %in% pre_users$user_id,]

## Load pre-trained embedding space for conText
glove <- readRDS("~/Dropbox/social_media_violence/effort_2/data/parler_video_and_comment_data/glove.rds")

## Load locally trained transformation matrix
transform <- readRDS(file = "~/Dropbox/social_media_violence/effort_2/data/parler_video_and_comment_data/khodakA.rds")


## -------
## Part 1: Is there evidence of an immediate effect?
## -------

### Create panel and summary stats

## Panel dataset
tmp_df <- mdf1 %>% filter(time > "2022-10-29 00:00:00" & time < "2022-11-20 19:47:00")
tmp1 <- tmp_df %>% filter(reinstatement == 0)
pre_users <- unique(tmp1$user_id)
tmp2 <- tmp_df %>% filter(reinstatement == 1) %>% filter(user_id %in% pre_users)
post_users <- unique(tmp2$user_id)
df_ub <- tmp_df %>% filter(user_id %in% post_users)

## Statistics
# total number of tweets?
length(unique(df_ub$tweet_id))
# tweets after treatment?
tmp1 <- df_ub %>% filter(reinstatement == 1) 
length(unique(tmp1$tweet_id))
# how many unique users?
length(unique(df_ub$user_id))
# users' mean number of tweets total
tmp1 <- df_ub %>% group_by(user_id) %>% summarize(num = n()) %>% ungroup()
mean(tmp1$num)
sd(tmp1$num)
# users' mean number of tweets after treatment
tmp1 <- df_ub %>% filter(reinstatement == 1) %>% group_by(user_id) %>% summarize(num = n()) %>% ungroup()
mean(tmp1$num)
sd(tmp1$num)

## List of terms
trms <- list()
trms[[1]] <- "c(\"trans\", \"trans\", \"transgender\", \"gay\", \"gays\", \"homo\", \"homosexual\", \"lesbian\", \"bisexual\", \"queer\")"
trms[[2]] <- "c(\"women\", \"women\")"
trms[[3]] <- "c(\"black\", \"blacks\")"
trms[[4]] <- "c(\"jew\", \"jews\", \"jewish\")"
trms[[5]] <- "c(\"undocumented migrant\", \"undocumented migrants\", \"undocumented\", \"migrants\", \"migrant\", \"illegals\", \"illegal alien\", \"illegal aliens\")"
trms[[6]] <- "c(\"election\", \"steal\", \"biden\", \"stop the steal\", \"stolen\")"
trms[[7]] <- "c(\"vaccine\", \"covid\", \"corona\", \"coronovirus\", \"fauci\", \"vax\", \"mandate\")"

## Treatments
treats <- c("reinstatement", "control")

### Embedding regression

## Which analysis?
mdf <- df_ub

## Covariate dataset
covars_df <- mdf %>% select(-full_text)

## Preprocess
# turn into corpus object
corp <- quanteda::corpus(mdf$full_text, docvars = covars_df)
# tokenize corpus removing unnecessary (i.e. semantically uninformative) elements
toks <- tokens(corp, remove_separators = TRUE, padding = FALSE, remove_symbols = TRUE, remove_numbers = TRUE, remove_punct = TRUE) # 
# clean out stopwords and words with 2 or fewer characters
toks_nostop <- tokens_select(toks, pattern = stopwords("en"), selection = "remove", min_nchar = 2)
# only use features that appear at least 3 times in the corpus
feats <- dfm(toks_nostop, tolower = TRUE, verbose = FALSE) %>% dfm_trim(min_termfreq = 1) %>% featnames()
# leave the pads so that non-adjacent words will not become adjacent
toks <- tokens_select(toks_nostop, feats, padding = TRUE)

## Create results dataframe
res_df <- tibble(terms = NA, variable = NA, estimate = NA, se = NA, pvalue = NA, sig05 = NA, sig01 = NA, sig001 = NA, features = NA, docs = NA)

## Loopy loop

## Treatments
for(j in 1:2){
  
## Terms
for(i in 1:length(trms)){
  
## Regression
m1 <- conText(formula = reformulate(treats[2], trms[[4]]), # reformulate(treats[j], trms[[i]]),
          data = toks, 
          pre_trained = glove, 
          transform = TRUE, 
          transform_matrix = transform, 
          bootstrap = TRUE, 
          num_bootstraps = 999, 
          stratify = TRUE, 
          permute = TRUE, 
          num_permutations = 999, 
          window = 6, 
          case_insensitive = TRUE, 
          verbose = TRUE)

## Results dataframe
tmp_df <- tibble(terms = i,
                 variable = m1@normed_coefficients$coefficient, 
                 estimate = m1@normed_coefficients$normed.estimate, 
                 se = m1@normed_coefficients$std.error, 
                 pvalue = m1@normed_coefficients$p.value) %>% 
  mutate(sig05 = ifelse(pvalue < 0.05, "Yes", "No"),
         sig01 = ifelse(pvalue < 0.01, "Yes", "No"),
         sig001 = ifelse(pvalue < 0.001, "Yes", "No"),
         features = length(m1@features))
tmp_df$docs = NA # 61 # change this
res_df <- bind_rows(res_df, tmp_df) %>% drop_na(estimate) %>% glimpse()

## Report
print(i)
}

## Report
print(j)

}

## Save
immediate_effect_df2 <- res_df
save(immediate_effect_df2 , file = "~/Dropbox/sachs_karell_paper/trump_twitter/results/twitter_results_v2.Rdata")

## Plot df
plot_df <- res_df %>% 
  mutate(terms = factor(terms),
         variable = ifelse(variable == "control", "Control", "Reinstatement"),
         sig = factor(sig01, levels = c("Yes", "No")))

## Plot
ggplot(plot_df) +
  geom_point(aes(x = estimate, y = terms, shape = variable, alpha = sig), 
             size = 2.75, position = position_dodge(width = -0.5), color = "#0f4d92") +
  geom_linerange(aes(y = terms, xmin = estimate - 1.96*se, xmax = estimate + 1.96*se, group = variable, alpha = sig), 
                 linewidth = 1, position = position_dodge(width = -0.5), color = "#0f4d92") +
  scale_y_discrete(limits = rev) +
  scale_alpha_discrete(range = c(1, 0.3)) +
  theme_bw() +
  theme(#panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.minor.y = element_blank(),
    strip.text = element_text(size = 12),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 11),
    legend.text = element_text(size = 11),
    legend.title = element_text(size = 12)) +
  labs(y = "", x = "Normed estimate", alpha = "Empirical\np-value < 0.05", shape = "Treatment\ncondition", color = "")


## -------
## Part 2: What is the change?
## -------

## Which keywords?
# terms = c("black", "blacks")
terms = c("jew", "jews", "jewish")

## Get context
mdf <- df_ub
# prepare documents
docs <- mdf %>% 
  filter(reinstatement == 1) %>%
  mutate(text = tolower(full_text)) 
# get context
cntxt <- get_context(x = docs$text, target = terms, window = 800L)
# get most protypical context
print(p_conxt <- prototypical_context(cntxt$context, 
                                      pre_trained = glove, 
                                      transform = TRUE, 
                                      transform_matrix = transform, 
                                      N = 20, 
                                      norm = "l2"))

## Find original
tmp1 <- df_ub[grepl("fascism", df_ub$full_text),]
tmp1$full_text

# ## Get nearest neighbors for interpretation
# word_nns <- find_nns(
#   # target_embedding = m1["reinstatement",],
#   target_embedding = m1["(Intercept)",], # referent group
#   pre_trained = glove,
#   N = 10)
# word_nns

word_nns_jew_ <- word_nns


## -------
## Part 3: How long is the effect?
## -------

## Statistics
tmp_mdf <- mdf1 %>% filter(time > "2022-10-29 00:00:00" & time < "2023-01-01 00:00:00")
# total number of tweets?
length(unique(tmp_mdf$tweet_id))
# tweets after treatment?
tmp1 <- tmp_mdf %>% filter(reinstatement == 1) 
length(unique(tmp1$tweet_id))
# how many unique users?
length(unique(tmp_mdf$user_id))
# users' mean number of tweets total
tmp1 <- tmp_mdf %>% group_by(user_id) %>% summarize(num = n()) %>% ungroup()
mean(tmp1$num)
sd(tmp1$num)
# users' mean number of tweets after treatment
tmp1 <- tmp_mdf %>% filter(reinstatement == 1) %>% group_by(user_id) %>% summarize(num = n()) %>% ungroup()
mean(tmp1$num)
sd(tmp1$num)

## Hard time stop
mdf2 <- mdf1 %>% filter(time > "2022-10-29 00:00:00" & time < "2022-11-18 19:47:00")

## Day vector
vec <- seq(3, 31, by = 2)

## Create results dataframe
res_df <- tibble(terms = NA, variable = NA, estimate = NA, se = NA, pvalue = NA, sig = NA, features = NA, outcome_endtime = NA)

for(i in 13:length(vec)){
  
  ## Treatment windows
  d = vec[i]
  time1 <- paste0("2022-12-", d-2, " 19:47:00")
  time2 <- paste0("2022-12-", d, " 19:47:00")
  
  ## Panel dataset
  tmp_df <- mdf1 %>% filter(time >= time1 & time < time2) %>% bind_rows(mdf2)
  tmp1 <- tmp_df %>% filter(reinstatement == 0)
  pre_users <- unique(tmp1$user_id)
  tmp2 <- tmp_df %>% filter(reinstatement == 1) %>% filter(user_id %in% pre_users)
  post_users <- unique(tmp2$user_id)
  panel_tmp <- tmp_df %>% filter(user_id %in% post_users)
  
  ## Covariate dataset
  covars_df <- panel_tmp %>% select(-full_text)
  
  ## Preprocess
  # turn into corpus object
  corp <- quanteda::corpus(panel_tmp$full_text, docvars = covars_df)
  # tokenize corpus removing unnecessary (i.e. semantically uninformative) elements
  toks <- tokens(corp, remove_punct = TRUE, remove_symbols = TRUE, remove_numbers = TRUE, remove_separators = TRUE)
  # clean out stopwords and words with 2 or fewer characters
  toks_nostop <- tokens_select(toks, pattern = stopwords("en"), selection = "remove", min_nchar = 3)
  # only use features that appear at least 3 times in the corpus
  feats <- dfm(toks_nostop, tolower = TRUE, verbose = FALSE) %>% dfm_trim(min_termfreq = 3) %>% featnames()
  # leave the pads so that non-adjacent words will not become adjacent
  toks <- tokens_select(toks_nostop, feats, padding = TRUE)
  
  ## Regression
  m1 <- 
    conText(formula = 
              c(black, blacks) ~
              # c(jew, jews, jewish) ~
              reinstatement,
            data = toks, 
            pre_trained = glove, 
            transform = TRUE, 
            transform_matrix = transform, 
            bootstrap = TRUE, 
            num_bootstraps = 999, 
            stratify = TRUE, 
            permute = TRUE, 
            num_permutations = 999, 
            window = 6, 
            case_insensitive = TRUE, 
            verbose = TRUE)
  
  ## Results dataframe
  tmp_df <- tibble(terms = "Blacks",
                   variable = m1@normed_coefficients$coefficient, 
                   estimate = m1@normed_coefficients$normed.estimate, 
                   se = m1@normed_coefficients$std.error, 
                   pvalue = m1@normed_coefficients$p.value) %>% 
    mutate(sig = ifelse(pvalue < 0.05, "Yes", "No"),
           features = length(m1@features),
           outcome_endtime = time2)
  res_df <- bind_rows(res_df, tmp_df) %>% drop_na(estimate) %>% glimpse()
  
  ## Report
  print(i)
}

## Save
# time_effect_df <- bind_rows(time_effect_df, res_df)
# save(immediate_effect_df, time_effect_df, file = "~/Dropbox/sachs_karell_paper/trump_twitter/results/twitter_results.Rdata")
load(file = "~/Dropbox/sachs_karell_paper/trump_twitter/results/twitter_results.Rdata")

## Plot df
plot_df <- time_effect_df %>% 
  mutate(variable = ifelse(variable == "placebo", "Placebo", "Reinstatement"),
         variable = factor(variable, levels = c("Reinstatement", "Placebo")),
         sig = factor(sig, levels = c("Yes", "No")),
         date = lubridate::as_date(outcome_endtime),
         terms = ifelse(terms == "Jews/\nJewish", "Discursive topic: Jews/Jewish", "Discursive topic: Blacks"),
         period = lubridate::yday(date))

## Plot
ggplot(plot_df) +
  geom_point(aes(x = period, y = estimate, alpha = sig, color = terms), size = 2.75, color = "#0f4d92") +
  geom_linerange(aes(x = period, ymin = estimate - 1.96*se, ymax = estimate + 1.96*se, 
                     color = terms, alpha = sig), linewidth = 1, color = "#0f4d92") +
  scale_alpha_discrete(range = c(1, 0.3)) +
  theme_bw() +
  theme(panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(),
        panel.grid.minor.y = element_blank(),
        strip.text = element_text(size = 12),
        axis.title = element_text(size = 12),
        axis.text = element_text(size = 11),
        legend.text = element_text(size = 11),
        legend.title = element_text(size = 12)) +
  labs(x = "Day of the year\n(November 19 through December 31, 2022)", 
       y = "Normed estimate", 
       alpha = "Empirical\np-value < 0.05", 
       color = "Target group") +
  facet_grid(. ~ terms)


# ## -------
# ## Embedding regression
# ## -------
# 
# ## Which analysis?
# mdf <- df_1mo_nb
# 
# ## Covariate dataset
# covars_df <- mdf %>% select(-full_text)
# 
# ## Preprocess
# # turn into corpus object
# corp <- quanteda::corpus(mdf$full_text, docvars = covars_df)
# # tokenize corpus removing unnecessary (i.e. semantically uninformative) elements
# toks <- tokens(corp, remove_punct = TRUE, remove_symbols = TRUE, remove_numbers = TRUE, remove_separators = TRUE)
# # clean out stopwords and words with 2 or fewer characters
# toks_nostop <- tokens_select(toks, pattern = stopwords("en"), selection = "remove", min_nchar = 3)
# # only use features that appear at least 3 times in the corpus
# feats <- dfm(toks_nostop, tolower = TRUE, verbose = FALSE) %>% dfm_trim(min_termfreq = 3) %>% featnames()
# # leave the pads so that non-adjacent words will not become adjacent
# toks <- tokens_select(toks_nostop, feats, padding = TRUE)
# 
# ## Regression
# m1 <- 
#   conText(formula = 
#             # c(trans, trans, transgender) ~
#             c(woman, women) ~
#             # c(black, blacks, "black lives matter", blm) ~
#             # c(jew, jews, jewish) ~
#             # c(gay, gays, homo, homosexual, lesbian) ~
#             # c(migrants, immigrants, illegals, aliens, mexicans, mexican) ~
#             # reinstatement,
#             placebo,
#           data = toks, 
#           pre_trained = glove, 
#           transform = TRUE, 
#           transform_matrix = transform, 
#           bootstrap = TRUE, 
#           num_bootstraps = 999, 
#           stratify = TRUE, 
#           permute = TRUE, 
#           num_permutations = 999, 
#           window = 6, # 4 or 6?
#           case_insensitive = TRUE, 
#           verbose = TRUE)
# 
# ## Results dataframe
# # res_df <- tibble(terms = NA, duration = NA, variable = NA, estimate = NA, se = NA, pvalue = NA, sig = NA, features = NA, docs = NA)
# tmp_df <- tibble(terms = "Immigrant",
#                  duration = "Three days",
#                  variable = m1@normed_coefficients$coefficient, 
#                  estimate = m1@normed_coefficients$normed.estimate, 
#                  se = m1@normed_coefficients$std.error, 
#                  pvalue = m1@normed_coefficients$p.value) %>% 
#   mutate(sig = ifelse(pvalue < 0.05, "Yes", "No"),
#          features = length(m1@features))
# tmp_df$docs = 101 # change this
# res_df <- bind_rows(res_df, tmp_df) %>% mutate(df = "Unbalanced") %>% glimpse()
# 
# ## Save
# # res_df_1dy <- res_df
# # res_df_1mo <- res_df
# # res_df_2mo <- res_df
# # save(res_df_1dy, res_df_1mo,  res_df_2mo, file = "~/Dropbox/sachs_karell_paper/trump_twitter/results/bal_results.Rdata")
# # res_df_1dy_nb <- res_df
# # res_df_1mo_nb <- res_df
# # res_df_2mo_nb <- res_df
# # save(res_df_1dy_nb, file = "~/Dropbox/sachs_karell_paper/trump_twitter/results/unbal_results.Rdata")
# 
# # res_df_1dy <- res_df_1dy %>% mutate(terms = ifelse(terms == "Immigirants", "Immigrants", terms)) %>% glimpse()
# 
# ## Plot df
# plot_df <- res_df_1dy_nb %>% 
#   # bind_rows(res_df_1mo, res_df_2mo, res_df_1dy_nb, res_df_1mo_nb, res_df_2mo_nb) %>%
#   drop_na(estimate) %>% 
#   # rename(obvs = docs) %>%
#   mutate(variable = ifelse(variable == "placebo", "Placebo", "Reinstatement"),
#          variable = factor(variable, levels = c("Reinstatement", "Placebo")),
#          sig = factor(sig, levels = c("Yes", "No")),
#          duration = factor(duration, levels = c("Three days", "One month", "Two months")),
#          terms = ifelse(terms == "(Anti-)Semitism", "(Anti-)\nSemitism", 
#                         ifelse(terms == "Sexual orientation", "Sexual\norientation", 
#                                ifelse(terms == "Race", "Black", 
#                                       ifelse(terms == "Immigrants", "Immigrant",
#                                              ifelse(terms == "Women", "Woman", terms))))))
# 
# ## Plot
# ggplot(plot_df) +
#   geom_point(aes(x = estimate, y = terms, shape = variable, alpha = sig), 
#              size = 2.75, position = position_dodge(width = 0.5), color = "#0f4d92") +
#   geom_linerange(aes(y = terms, xmin = estimate - 1.96*se, xmax = estimate + 1.96*se, group = variable, alpha = sig), 
#                  linewidth = 1, position = position_dodge(width = 0.5), color = "#0f4d92") +
#   scale_x_continuous(limits = c(0, 2.5), breaks = c(0, 1, 2.5), labels = c(0, 1, 2)) +
#   scale_y_discrete(limits = rev) +
#   scale_alpha_discrete(range = c(1, 0.3)) +
#   theme_bw() +
#   theme(#panel.grid.major.x = element_blank(),
#     panel.grid.major.y = element_blank(),
#     panel.grid.minor.y = element_blank(),
#     strip.text = element_text(size = 12),
#     axis.title = element_text(size = 12),
#     axis.text = element_text(size = 11),
#     legend.text = element_text(size = 11),
#     legend.title = element_text(size = 12)) +
#   labs(y = "", x = "Normed estimate", alpha = "Statistical\nsignifiance", shape = "Treatment\ncondition", color = "") +
#   facet_grid(. ~ duration)
# 
# 
# 
# # ## -------
# # ## Data organization and summary stats
# # ## -------
# # 
# # ## Statistics
# # # total number of tweets?
# # length(unique(mdf1$tweet_id))
# # # how many unique users in original panel?
# # length(unique(tweets_before$user_id))
# # # how many users tweets after treatment
# # tmp <- mdf1 %>% 
# #   filter(reinstatement == 1)
# # length(unique(tmp$user_id))
# # # users' mean number of tweets before treatment
# # tmp <- tweets_before %>% 
# #   group_by(user_id) %>%
# #   summarize(num = n()) %>% 
# #   ungroup() 
# # mean(tmp$num)
# # sd(tmp$num)
# # max(tmp$num)
# # 
# # ## Create balanced panel
# # # earliest observation
# # min(mdf1$time)
# # # latest observation
# # max(mdf1$time)
# # # balanced df
# # mdf2 <- mdf1 %>% filter(time < "2023-01-20 00:00:00" & time > "2022-09-20 00:00:00")
# # 
# # ## Balanced panel statistics
# # # total number of tweets?
# # length(unique(mdf2$tweet_id))
# # # how many unique users in original panel?
# # length(unique(tweets_before$user_id))
# # # how many users tweets after treatment
# # tmp <- mdf2 %>% 
# #   filter(reinstatement == 1)
# # length(unique(tmp$user_id))
# # 
# # ## Subset for analyzing one-day effect
# # mdf1_1day <- mdf1 %>%
# #   filter(time < "2022-11-21 00:00:00")
# # mdf2_1day <- mdf2 %>%
# #   filter(time < "2022-11-21 00:00:00")
# # 
# # ## Subset for analyzing one-week effect
# # mdf1_1week <- mdf1 %>%
# #   filter(time < "2022-11-27 00:00:00")
# # mdf2_1week <- mdf2 %>%
# #   filter(time < "2022-11-27 00:00:00")
# # 
# # ## Subset for analyzing one-month effect
# # mdf1_1mo <- mdf1 %>%
# #   filter(time < "2022-12-20 00:00:00")
# # mdf2_1mo <- mdf2 %>%
# #   filter(time < "2022-12-20 00:00:00")
# 
# 
# 
# 
# 
# # # stats
# # length(unique(mdf1$tweet_id)) # number of tweets
# # table(df_1wk$reinstatement) # tweets with and without treatment
# # length(unique(df_1wk$user_id)) # number of unique users
# # tmp <- mdf1 %>%
# #   filter(reinstatement == 1)
# # length(unique(tmp$user_id)) # how many users tweets after treatment
# # tmp <- tweets_before %>%
# #   group_by(user_id) %>%
# #   summarize(num = n()) %>%
# #   ungroup()
# # mean(tmp$num) # users' mean number of tweets before treatment
# # sd(tmp$num)
# # max(tmp$num)
# 
# 
# 
# 
# 
# 
# 
# ## -------
# ## Interpretation
# ## -------
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# # ## Train local transformation matrix ("A")
# # library(text2vec)
# # # local data
# # load("~/Dropbox/proj/data/effort_2/data_step2.Rda") # parler data
# # df2 <- df %>% dplyr::select(text, clean) %>% drop_na(clean)
# # load("~/Dropbox/proj/data/effort_2/media_text.Rdata") # FNC data
# # # local_corp <- tibble(text = c(df2$text, fnc_df$text)) 
# # local_corp <- tibble(text = sample(mdf1$full_text, size = 500, replace = FALSE))
# # # local_corp <- tibble(text = mdf1$full_text[1:10000])
# # # local_corp <- local_corp[c(1972,4440, 8052),] # causes an error for some reason
# # # tokenize corpus removing unnecessary (i.e. semantically uninformative) elements
# # toks <- tokens(local_corp$text, remove_punct = TRUE, remove_symbols = TRUE, remove_numbers = TRUE, remove_separators = TRUE)
# # # clean out stopwords and words with 2 or fewer characters
# # toks_nostop <- tokens_select(toks, pattern = stopwords("en"), selection = "remove", min_nchar=3)
# # # only use features that appear at least 5 times in the corpus
# # feats <- dfm(toks_nostop, tolower = FALSE, verbose = FALSE) %>% dfm_trim(min_termfreq = 5) %>% featnames()
# # # leave the pads so that non-adjacent words will not become adjacent
# # toks_nostop_feats <- tokens_select(toks_nostop, feats, padding = TRUE)
# # # construct the feature co-occurrence matrix for our toks_nostop_feats object
# # toks_fcm <- fcm(toks_nostop_feats, context = "window", window = 6, count = "frequency", tri = FALSE)
# # # estimate glove model using text2vec
# # glove <- GlobalVectors$new(rank = 300,
# #                            x_max = 10,
# #                            learning_rate = 0.05)
# # wv_main <- glove$fit_transform(toks_fcm, n_iter = 10,
# #                                convergence_tol = 1e-3,
# #                                n_threads = parallel::detectCores()) # set to 'parallel::detectCores()' to use all available cores
# # wv_context <- glove$components
# # local_glove <- wv_main + t(wv_context)
# # # prepare for qualitative check
# # # term_toks <- tokens_context(x = toks_nostop_feats, pattern = "women", window = 6L) # build a tokenized corpus of contexts sorrounding the target term "police"
# # # feats <- featnames(dfm(term_toks)) # we limit candidates to features in our corpus
# # # find_nns(local_glove["women",], pre_trained = local_glove, N = 10) # candidates
# # # compute transform
# # local_transform <- compute_transform(x = toks_fcm, pre_trained = local_glove, weighting = "log")
# # # check
# # term_dfm <- dfm(term_toks)
# # term_dem_local <- dem(x = term_dfm, pre_trained = local_glove, transform = TRUE, transform_matrix = local_transform, verbose = TRUE)
# # term_wv_local <- colMeans(term_dem_local) # take the column average to get a single "corpus-wide" embedding
# # find_nns(term_wv_local, pre_trained = local_glove, N = 10, candidates = term_dem_local@features) # find nearest neighbors for overall target embedding
# # sim2(x = matrix(term_wv_local, nrow = 1), y = matrix(local_glove["women",], nrow = 1), method = "cosine", norm = "l2") # we can also compare to corresponding pre-trained embedding
# # # save
# # save(local_corp, local_glove, local_transform, file = "~/Dropbox/proj/data/effort_2/localA.Rdata")
# # 
