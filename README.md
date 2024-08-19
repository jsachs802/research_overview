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

1. [Fair Diffusion](https://github.com/jsachs802/research_overview/blob/main/fair_diffusion/fair_diff_readme.md): This study examines fairness in information distribution across 14 Ugandan villages, analyzing how network metrics and a new fairness definition affect the spread of political participation technology. While the new metric improves fairness predictions, it reduces efficiency, highlighting the challenge of balancing fairness and efficiency in complex systems.


2. [The Tik Tok Self](https://github.com/jsachs802/research_overview/blob/main/tiktokself/tiktok_readme.md): This study visualizes a rise in "coming out" videos on TikTok during 2020, attributing it to users finding more agreeable online spaces during the pandemic. It highlights the positive impact of online environments in fostering self-expression and introduces a new dataset of 4.8 million TikTok videos for further research.

3. [Embedding Regression](https://github.com/jsachs802/research_overview/blob/main/embedding_reg/embed_reg_readme.md): This study examines how the symbolic meaning of social media content, specifically Donald Trump's Twitter reinstatement, influences online discourse. It found that the reinstatement shifted discussions about identity-based groups like Black and Jewish people, leading to a short-lived politicization of the discourse. The research highlights the importance of distinguishing between content's lexical and symbolic dimensions.
  
4. [Group Fairness on Networks](https://github.com/jsachs802/research_overview/blob/main/group_fairness/group_fairness.md)
   - _Abstract_: An increasing amount of work studies fairness in socio-technical settings from a computational perspective. This work has introduced a variety of metrics to measure fairness in different settings. Most of these metrics, however, do not account for the interactions between individuals or evaluate any underlying network's effect on the outcomes measured. While a wide body of work studies the organization of individuals into a network structure and how individuals access resources in networks, the impact of network structure on fairness has been largely unexplored.
We introduce templates for group fairness metrics that account for network structure. More specifically, we present two types of group fairness metrics that measure distinct yet complementary forms of bias in networks. The first type of metric evaluates how access to others in the network is distributed across groups. The second type of metric evaluates how groups distribute their interactions across other groups, and hence captures inter-group biases. We find that ignoring the network can lead to spurious fairness evaluations by either not capturing imbalances in influence and reach illuminated by the first type of metric, or by overlooking interaction biases as evaluated by the second type of metric. Our empirical study illustrates these pronounced differences between network and non-network evaluations of fairness.

Short Description: 

This study introduces group fairness metrics that account for network structure, addressing biases in how individuals access others and interact across groups. It shows that ignoring network effects can lead to misleading fairness evaluations, highlighting the importance of considering network structure in socio-technical fairness assessments.
  
5. [LLM Project](https://github.com/jsachs802/research_overview/blob/main/llm_duality/llm_duality_readme.md)
   - _Abstract_: The development of generative artificial intelligence (genAI) has caused concern about its potential risks, including how its ability to generate human-like texts could affect our shared perception of the social world. Yet, it remains unclear how best to assess and understand the genAI’s influence on our understanding of social reality. Building on insights into the representation of social worlds within texts, we take initial steps towards developing a framework for genAI’s content and its consequences for perceptions of social reality. We demonstrate our “synthetic duality” framework in two parts. First, we show that genAI can create, with minimal guidance, reasonable portrayals of actors and ascribe relational meaning to those actors – virtual social worlds within texts, or “Mondo-Breigers”. Second, we examine how these synthetic documents with interior social worlds affect readers’ view of social reality. We find that they change individuals’ perceptions of actors depicted in the documents, likely by updating individuals’ expectations about the actors and their meanings. However, additional exploratory analyses suggest it is models’ style, not their construction of “Mondo-Breigers”, that might be influencing people’s perceptions. We end with a discussion of theoretical and methodological implications, including how genAI may unsettle structural notions of individuality. Namely, reimagining the duality of individuals and groups could help theorize growing homogeneity in an increasingly genAI-informed world.
  
Short Description: 

This study introduces a "synthetic duality" framework to assess how generative AI influences perceptions of social reality. It finds that AI-generated texts can alter individuals' views of depicted actors but suggests that style, rather than content, might drive these changes. The work explores implications for understanding individuality in a genAI-informed world.

6. [Sampling Project](https://github.com/jsachs802/research_overview/blob/main/orthogonal_sampling/orthogonal_readme.md)
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

7. [Topic Models & Visualizations](https://github.com/jsachs802/research_overview/blob/main/bert_modeling/bert_model.md) - Problem
   Short Description
   Practical Applications

#### Other Projects 

8. [College Basketball predictor](https://github.com/jsachs802/research_overview/blob/main/orthogonal_sampling/orthogonal_readme.md) - Problem
   Short Description
   Practical Applications

#### Logistical Code

ABOUT: I've found that general coding tutorials often lack insights for common problems encountered 'in practice.' I wanted to begin a small set of tips or ideas for tasks that often surface in my work.

9. [Iterating Data into an SQL Database with Python](https://github.com/jsachs802/research_overview/blob/main/orthogonal_sampling/orthogonal_readme.md) - Problem
   Short Description
   Practical Applications

10. [Editing Large SQL Files from the Terminal](https://github.com/jsachs802/research_overview/blob/main/orthogonal_sampling/orthogonal_readme.md) - Problem
   Short Description
   Practical Applications

11. [Creating Small Applications for Data Science Tasks](https://github.com/jsachs802/research_overview/blob/main/orthogonal_sampling/orthogonal_readme.md) - Problem
   Short Description
   Practical Applications

12. [Project Setup Template using Bash Script](https://github.com/jsachs802/research_overview/blob/main/orthogonal_sampling/orthogonal_readme.md) - Problem
   Short Description
   Practical Applications

13. [Automating Unzipping](https://github.com/jsachs802/research_overview/blob/main/orthogonal_sampling/orthogonal_readme.md) - Problem
   Short Description
   Practical Applications





