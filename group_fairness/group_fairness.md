Back to [Main Page](https://github.com/jsachs802/research_overview/blob/main/README.md)

### REVISITING GROUP FAIRNESS: THE ROLE OF NETWORKS


Abstract: An increasing amount of work studies fairness in socio-technical settings from a computational perspective. This work has introduced a variety of metrics to measure fairness in different settings. Most of these metrics, however, do not account for the interactions between individuals or evaluate any underlying network's effect on the outcomes measured. While a wide body of work studies the organization of individuals into a network structure and how individuals access resources in networks, the impact of network structure on fairness has been largely unexplored. We introduce templates for group fairness metrics that account for network structure. More specifically, we present two types of group fairness metrics that measure distinct yet complementary forms of bias in networks. The first type of metric evaluates how access to others in the network is distributed across groups. The second type of metric evaluates how groups distribute their interactions across other groups, and hence captures inter-group biases. We find that ignoring the network can lead to spurious fairness evaluations by either not capturing imbalances in influence and reach illuminated by the first type of metric, or by overlooking interaction biases as evaluated by the second type of metric. Our empirical study illustrates these pronounced differences between network and non-network evaluations of fairness.

[Published in Proceedings of the ACM on Human-Computer Interaction, Volume 6, Issue CSCW2, 2022](https://dl.acm.org/doi/abs/10.1145/3555100)

Here's a short presentation of the work:

[![Proceedings Youtube Presentation](https://github.com/jsachs802/research_overview/blob/main/group_fairness/group_fair_vid.png)](https://www.youtube.com/watch?v=MmvGPqtfr3M)

[Pokec Experiment](https://github.com/jsachs802/research_overview/blob/main/group_fairness/pokec-simulation.ipynb) - notebook for the Pokec example from the paper. 

[Ugandan Villages](https://github.com/jsachs802/research_overview/blob/main/group_fairness/ugandan-villages-simulation.ipynb) - notebook for the Ugandan villages example from the paper.

[Add Health](https://github.com/jsachs802/research_overview/blob/main/group_fairness/Section4_2Metrics.Rmd) - notebook for the Add Health example from the paper.
