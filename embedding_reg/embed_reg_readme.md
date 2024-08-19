Back to [Main Page](https://github.com/jsachs802/research_overview/blob/main/README.md)

### Twitter Discourse Shift/Embedding Regression

Abstract: How does social media content affect users’ online discourse? Existing scholarship sheds light on how users’ speech can be influenced by several social media features involving content. However, this research often conflates content’s lexical dimension with its symbolic dimension. The authors analyze how the symbolic properties of online content can distinctly affect discourse on social media. Specifically, they examine how the symbolic meanings conveyed by Twitter’s reinstatement of Donald Trump’s account influenced Twitter users’ discourse. The results of embedding regressions indicate that Trump’s reinstatement immediately shifted users’ discourse about social and political identity-based groups, but only when they discussed Black and Jewish people. Additional results suggest that the discourse became more politicized and that the discursive shift was short-lived. The authors’ findings contribute conceptual and analytical clarity to the socio-semantic dynamics of online discourse, encouraging future research to distinguish and compare the lexical and symbolic dimensions of online content.

[Article Published in Socius, 9 2023](https://journals.sagepub.com/doi/full/10.1177/23780231231212108)

Data collection began prior to the date of Trump's reinstatement. 

[Collection](https://github.com/jsachs802/research_overview/blob/main/embedding_reg/trump_collect_tweets.R) - script for collecting Tweets [DEPRECATED: Package used for collecting from Twitter no longer functional since switch to X]

[Activity Functions](https://github.com/jsachs802/research_overview/blob/main/embedding_reg/trump_activity_functions.R) - functions for collecting and monitoring user activity of trump followers.

[Activity Main Script](https://github.com/jsachs802/research_overview/blob/main/embedding_reg/trump_follower_activity.R) - script for running activity functions. 

Trump follower activity was monitored using a dashboard that looked like this: 
![Dashboard](/embedding_reg/Trump Dash.png)
