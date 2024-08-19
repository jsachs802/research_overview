Back to [Main Page](https://github.com/jsachs802/research_overview/blob/main/README.md)

### ORTHOGONAL SAMPLING APPROACH 

Abstract: Social scientists studying contemporary public debates, discourses, and sentiments often turn to social media platforms for data. They typically collect these data by querying platforms' application program interfaces (APIs) using a term of interest, as well as terms related to the target term, or "topic-based sampling". Unfortunately, because of how APIs work, this risks introducing bias into the samples, likely resulting in inaccurate estimates of how prevalent a discourse is on the platform. We introduce and demonstrate an approach to topic-based sampling that reduces bias and allows for more reliable inferences about the population. Building on theory from animal ecology and previous efforts to address social media sampling problems, and using tools from natural language processing, we first develop and detail the procedures for our "orthogonal sampling approach". The method consists of incorporating layers of independence into data collection. It is based on the core idea that a discursive space, such as a social media platform, can be treated geometrically and thus leveraged to set initial locations for data collection to topics that are orthogonal to the topic of interest. After explaining our approach, we provide evidence that our approach produces samples of a discourse that are representative of the true abundance of the discourse. Our results additionally indicate that as the samples' sizes increase, so should their representativeness. We also find that gathering social media by querying a target term and related terms -- a common practice in the scholarship -- can have strong negative effects on properties that are characteristics of a representative sample, suggesting that mitigating sampling bias when collecting social media data should be a priority for many studies analyzing online discourse.

[Manuscript](https://github.com/jsachs802/research_overview/blob/main/orthogonal_sampling/sampling_manuscript%20(1).pdf)

NOTE: PACKAGE IN CODE IS OUT OF SERVICE SINCE CHANGE FROM TWITTER TO X. The general approach is applicable to other social media platforms and social listening services like Sprinklr.

Scripts for [Data Cleaning](https://github.com/jsachs802/research_overview/blob/main/orthogonal_sampling/data_wrangling.R) and [Status Updates](https://github.com/jsachs802/research_overview/blob/main/orthogonal_sampling/status_update.R). 

#### Collection Sequence: 

[Step 1](https://github.com/jsachs802/research_overview/blob/main/orthogonal_sampling/step_one_orth_hashtags.R) - functions for collecting orthogonal hashtags. 

[Step 2](https://github.com/jsachs802/research_overview/blob/main/orthogonal_sampling/step_two_collect_users.R) - functions for collecting users. 

[Step 3](https://github.com/jsachs802/research_overview/blob/main/orthogonal_sampling/step_three_collect_folls.R) - functions for collecting followers. 

[Step 4](https://github.com/jsachs802/research_overview/blob/main/orthogonal_sampling/step_four_collect_tweets.R) - functions for collecting tweets. 


#### ESTIMATION AND TESTING

[Estimation](https://github.com/jsachs802/research_overview/blob/main/orthogonal_sampling/estimation.R) - functions for estimating capture probability.

[Coverage](https://github.com/jsachs802/research_overview/blob/main/orthogonal_sampling/coverage_assessment.R) - functions for estimating confidence interval converage test. 

[Consistency](https://github.com/jsachs802/research_overview/blob/main/orthogonal_sampling/consistency_assessment.R) - functions for assessing consistency of estimator. 

[Efficiency](https://github.com/jsachs802/research_overview/blob/main/orthogonal_sampling/efficiency_assessment.R) - functions for assessing efficiency of estimator. 

[Visualization](https://github.com/jsachs802/research_overview/blob/main/orthogonal_sampling/visualization.R) - functions for creating visualization.

##### Overall Scripts

[Main Script](https://github.com/jsachs802/research_overview/blob/main/orthogonal_sampling/sampling_approach_main.R) - script for calling all functions in the collection, estimation, and visualization sequence. 

[All Functions](https://github.com/jsachs802/research_overview/blob/main/orthogonal_sampling/functions.R) - all functions in the sequence (if you prefer this to the separate scripts above). 
