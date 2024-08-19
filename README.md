# A Showcase of Selected Research 

Welcome to Jeff Sachs's public github repository! 

Jeff Sachs is a computational social science researcher. He received his PhD in sociology from Yale University and works as an academic researcher of organizational behavior. Jeff uses quantitative and computational approaches to examine organizational problems. Jeff’s research contributions include: 

 1. Costs/tradeoffs in the prediction of information diffusion across different groups.
   * _Practical Applications:_
        - Information requirements and costs related to managing the spread of information.
        - Understanding the complexity of prediction in a complex system.
        - Costs associated with targeting hard to reach population segments.
    
 2. The impacts of social networks on group fairness measures.
   * _Practical Applications:_ 
        - Evaluating decision-making dynamics and knowledge flows in an organization.
        - Measuring bias in organizational culture.
    
 3. Techniques for removing selection bias in social media data samples.
   * _Practical Applications:_ 
        - Generating representative samples of social media data. 
        - Making population inferences with social listening data. 

Jeff has also completed projects on generative AI and LLMs in his research. Currently, Jeff serves as a post-doctoral social science researcher for the USDA Forest Service as part of the Wildfire Crisis Strategy, gathering data and analyzing communication landscapes surrounding wildfire adaptation with the objective of shrinking information gaps between adaptation programs and stakeholders. 

Overall, Jeff’s research focuses on organizational flows and evaluating problems related to communication, decision-making, and resource allocations.

Connect with me on [LinkedIn](https://www.linkedin.com/in/jeffrey-sachs/).


NOTE ON CODE:
The projects below were added to this public repository after their completion. Not all the code is available for some projects. In these cases, the code is too dependent on data that cannot be made publicly available. That is, some code is not very useful without the data.


### Academic Research 

1. [Fair Diffusion](https://github.com/jsachs802/research_overview/blob/main/fair_diffusion/fair_diff_readme.md)
   - _Abstract_:
   This research investigates fairness in information spread within 14 distinct Ugandan villages, focusing on
   the distribution of information about a political participation technology. The study applies a Simulated
   Method of Moments to assess the impact of different network metrics and fairness definitions on the
   spread of information across male and female villagers. Initial findings highlight significant differences
   in the likelihood of achieving fair outcomes with various interventions. Although some fair strategies
   show slight improvements, they still exhibit low probabilities of fair outcomes. The introduction of a
   new fairness definition, Seed Average x Coverage Fairness, enhances the prediction of fair outcomes
   across many network metrics, albeit with a trade-off in the efficiency of information spread. The research
   underscores the difficulty of controlling outcomes in a complex system, and the dynamics of efficiency
   and fairness, demonstrating that context plays a vital role for these processes. 

3. [The Tik Tok Self](https://github.com/jsachs802/research_overview/blob/main/tiktokself/tiktok_readme.md)
   - _Abstract_: The COVID-19 pandemic has shifted many social worlds from in-person interaction to online activity. As a result, people increasingly have the freedom to choose more agreeable everyday environments. While 
   such freedom has often been associated with negative outcomes – namely, the emergence of “echo-chambers” that corral insensitivity – this data visualization suggests a positive outcome: “flowering-chambers”, where the 
   freedom has enabled expressions of a truer self. Drawing on an original dataset of TikTok videos, the visualization charts a considerable increase in the number of “coming out” gender identity and sexual orientation 
   videos during the latter three quarters of 2020. These results suggests that many TikTok users have publicly revealed private aspects of their identities, which we attribute to individuals becoming increasingly 
   embedded in agreeable online spaces while quarantining or socially distancing. The visualization additionally introduces a publicly available dataset of 4.8 million TikToks to facilitate future research using data 
   from the platform.

5. [Embedding Regression](https://github.com/jsachs802/research_overview/blob/main/embedding_reg/embed_reg_readme.md)
   - _Abstract_: How does social media content affect users’ online discourse? Existing scholarship sheds light on how users’ speech can be influenced by several social media features involving content. However, this 
   research often conflates content’s lexical dimension with its symbolic dimension. The authors analyze how the symbolic properties of online content can distinctly affect discourse on social media. Specifically, they 
examine how the symbolic meanings conveyed by Twitter’s reinstatement of Donald Trump’s account influenced Twitter users’ discourse. The results of embedding regressions indicate that Trump’s reinstatement immediately 
   shifted users’ discourse about social and political identity-based groups, but only when they discussed Black and Jewish people. Additional results suggest that the discourse became more politicized and that the 
 discursive shift was short-lived. The authors’ findings contribute conceptual and analytical clarity to the socio-semantic dynamics of online discourse, encouraging future research to distinguish and compare the 
   lexical and symbolic dimensions of online content. 
  
6. [Group Fairness on Networks](https://github.com/jsachs802/research_overview/blob/main/group_fairness/group_fairness.md)
   - _Abstract_: An increasing amount of work studies fairness in socio-technical settings from a computational perspective. This work has introduced a variety of metrics to measure fairness in different settings. Most of these metrics, however, do not account for the interactions between individuals or evaluate any underlying network's effect on the outcomes measured. While a wide body of work studies the organization of individuals into a network structure and how individuals access resources in networks, the impact of network structure on fairness has been largely unexplored.
We introduce templates for group fairness metrics that account for network structure. More specifically, we present two types of group fairness metrics that measure distinct yet complementary forms of bias in networks. The first type of metric evaluates how access to others in the network is distributed across groups. The second type of metric evaluates how groups distribute their interactions across other groups, and hence captures inter-group biases. We find that ignoring the network can lead to spurious fairness evaluations by either not capturing imbalances in influence and reach illuminated by the first type of metric, or by overlooking interaction biases as evaluated by the second type of metric. Our empirical study illustrates these pronounced differences between network and non-network evaluations of fairness.
  
8. [LLM Project](https://github.com/jsachs802/research_overview/blob/main/llm_duality/llm_duality_readme.md)
   - _Abstract_: The development of generative artificial intelligence (genAI) has caused concern about its potential risks, including how its ability to generate human-like texts could affect our shared perception of the social world. Yet, it remains unclear how best to assess and understand the genAI’s influence on our understanding of social reality. Building on insights into the representation of social worlds within texts, we take initial steps towards developing a framework for genAI’s content and its consequences for perceptions of social reality. We demonstrate our “synthetic duality” framework in two parts. First, we show that genAI can create, with minimal guidance, reasonable portrayals of actors and ascribe relational meaning to those actors – virtual social worlds within texts, or “Mondo-Breigers”. Second, we examine how these synthetic documents with interior social worlds affect readers’ view of social reality. We find that they change individuals’ perceptions of actors depicted in the documents, likely by updating individuals’ expectations about the actors and their meanings. However, additional exploratory analyses suggest it is models’ style, not their construction of “Mondo-Breigers”, that might be influencing people’s perceptions. We end with a discussion of theoretical and methodological implications, including how genAI may unsettle structural notions of individuality. Namely, reimagining the duality of individuals and groups could help theorize growing homogeneity in an increasingly genAI-informed world.

12. [Sampling Project](https://github.com/jsachs802/research_overview/blob/main/orthogonal_sampling/orthogonal_readme.md)
    - _Abstract_: Social scientists studying contemporary public debates, discourses, and
sentiments often turn to social media platforms for data. They typically
collect these data by querying platforms' application program interfaces
(APIs) using a term of interest, as well as terms related to the target
term, or "topic-based sampling". Unfortunately, because of how APIs
work, this risks introducing bias into the samples, likely resulting in
inaccurate estimates of how prevalent a discourse is on the platform. We
introduce and demonstrate an approach to topic-based sampling that
reduces bias and allows for more reliable inferences about the
population. Building on theory from animal ecology and previous efforts
to address social media sampling problems, and using tools from natural
language processing, we first develop and detail the procedures for our
"orthogonal sampling approach". The method consists of incorporating
layers of independence into data collection. It is based on the core idea
that a discursive space, such as a social media platform, can be treated
geometrically and thus leveraged to set initial locations for data
collection to topics that are orthogonal to the topic of interest. After
explaining our approach, we provide evidence that our approach
produces samples of a discourse that are representative of the true
abundance of the discourse. Our results additionally indicate that as the
samples' sizes increase, so should their representativeness. We also find
that gathering social media by querying a target term and related terms
-- a common practice in the scholarship -- can have strong negative
effects on properties that are characteristics of a representative sample,
suggesting that mitigating sampling bias when collecting social media
data should be a priority for many studies analyzing online discourse.

#### Other Projects 
8. [Topic Models & Visualizations](https://github.com/jsachs802/research_overview/blob/main/orthogonal_sampling/orthogonal_readme.md) - Problem
   Short Description
   Practical Applications
9. [College Basketball predictor](https://github.com/jsachs802/research_overview/blob/main/orthogonal_sampling/orthogonal_readme.md) - Problem
   Short Description
   Practical Applications

#### Logistical Code

ABOUT:

10. [Iterating Data into an SQL Database with Python](https://github.com/jsachs802/research_overview/blob/main/orthogonal_sampling/orthogonal_readme.md) - Problem
   Short Description
   Practical Applications

11. [Editing Large SQL Files from the Terminal](https://github.com/jsachs802/research_overview/blob/main/orthogonal_sampling/orthogonal_readme.md) - Problem
   Short Description
   Practical Applications

12. [Creating Small Applications for Data Science Tasks](https://github.com/jsachs802/research_overview/blob/main/orthogonal_sampling/orthogonal_readme.md) - Problem
   Short Description
   Practical Applications





