### Trump Followers

trump <- lookup_users("realDonaldTrump")
trump_followers <- get_followers(trump$id, n = 3000000, retryonratelimit = TRUE, token = auth)

next_page <- next_cursor(trump_followers)

trump_followers2 <- get_followers(trump$id, n = 75000, retryonratelimit = TRUE, token = auth, cursor = 1)

next_cursor(trump_followers)
