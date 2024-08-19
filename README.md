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
  
4. [Group Fairness on Networks](https://github.com/jsachs802/research_overview/blob/main/group_fairness/group_fairness.md): This study introduces group fairness metrics that account for network structure, addressing biases in how individuals access others and interact across groups. It shows that ignoring network effects can lead to misleading fairness evaluations, highlighting the importance of considering network structure in socio-technical fairness assessments.
  
5. [LLM Project](https://github.com/jsachs802/research_overview/blob/main/llm_duality/llm_duality_readme.md): This study introduces a "synthetic duality" framework to assess how generative AI influences perceptions of social reality. It finds that AI-generated texts can alter individuals' views of depicted actors but suggests that style, rather than content, might drive these changes. The work explores implications for understanding individuality in a genAI-informed world.

6. [Sampling Project](https://github.com/jsachs802/research_overview/blob/main/orthogonal_sampling/orthogonal_readme.md): This study introduces an "orthogonal sampling approach" to reduce bias in social media data collection, improving the accuracy of discourse prevalence estimates. The method treats discursive spaces geometrically to ensure more representative samples, addressing the limitations of traditional topic-based sampling that often skews results due to inherent biases in API querying.

7. [Wildfire Communication Landscape](https://github.com/jsachs802/research_overview/blob/main/bert_modeling/bert_model.md): Some initial modeling and visualizations for an ongoing project with the USDA Forest Service. Part of several communications projects within the Wildfire Crisis Strategy (WCS). 

#### Other Projects 

8. [College Basketball predictor](https://github.com/jsachs802/research_overview/blob/main/college_basketball/college_bb.md): Last year, I attempted to created a prediction model for college basketball games. It was relatively accurate for in-conference play (~75%) and did a horrible job of selecting my bracket. This was put together with not much time left in last year's season. For the 2024/25 season, I plan to build a new an improved predictor using deep learning and play-by-play simulation.
   
#### Logistical Code

ABOUT: I've found that general coding tutorials often lack insights for common problems encountered 'in practice.' I wanted to begin a small set of tips or ideas for tasks that often surface in my work.

9. [Iterating Data into an SQL Database with Python](https://github.com/jsachs802/research_overview/blob/main/orthogonal_sampling/orthogonal_readme.md): Loading data sequentially into an SQL database in chunks for memory management. 

10. [Editing Large SQL Files from the Terminal](https://github.com/jsachs802/research_overview/blob/main/orthogonal_sampling/orthogonal_readme.md): Making required changes to large scripts (e.g., a large SQL script) that cannot be loaded into memory entirely due to memory limitations.

11. [Project Setup Template using Bash Script](https://github.com/jsachs802/research_overview/blob/main/orthogonal_sampling/orthogonal_readme.md): Automate the build of new project setups: environment, directories, git init, and coding libraries using bash scripts that can easily be changed for specific needs.






