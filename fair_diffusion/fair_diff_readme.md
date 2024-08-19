Back to [Main Page](https://github.com/jsachs802/research_overview/blob/main/README.md)

#### Fair Diffusion Project

Abstract: This research investigates fairness in information spread within 14 distinct Ugandan villages, focusing on the distribution of information about a political participation technology. The study applies a Simulated Method of Moments to assess the impact of different network metrics and fairness definitions on the spread of information across male and female villagers. Initial findings highlight significant differences in the likelihood of achieving fair outcomes with various interventions. Although some fair strategies show slight improvements, they still exhibit low probabilities of fair outcomes. The introduction of a new fairness definition, Seed Average x Coverage Fairness, enhances the prediction of fair outcomes across many network metrics, albeit with a trade-off in the efficiency of information spread. The research underscores the difficulty of controlling outcomes in a complex system, and the dynamics of efficiency and fairness, demonstrating that context plays a vital role for these processes.

Article - link to the draft of the research from my dissertation. For a better sense of how the code works, refer to the methods section of the paper.

_NOTE:_ Currently, the article is being revised for submission to a peer-reviewed publication. 

#### CODE 

_NOTE:_ Whenever I do a project, I create a project template which has a specific root/path setup (See here for instructions on how to do this). The scripts found here often rely on linkages to eachother, but I have redacted the paths since potential users will probably not have the same directory setup. For this reason, configuring the scripts to work with eachother will require you to reestablish the paths.  

_Calibration_: The first set of scripts are for calibrating diffusion models to empirical network diffusion data.

[Calibration](https://github.com/jsachs802/research_overview/blob/main/fair_diffusion/CALIBRATION_DIFFUSION_SIM.R) - this script is used to calibrate the model to the empirical diffusion process. The actual script was run on a high performance computer that uses bash for scheduling. [Calibration2](https://github.com/jsachs802/research_overview/blob/main/fair_diffusion/CALIBRATION_DIFFUSION_SIM_Com_Args.R) script can be used with bash and takes arguments for which village (empirical network) to calibrate to from the terminal. The scripts that follow in the calibration process are called by the main calibration script.

[Main Data](https://github.com/jsachs802/research_overview/blob/main/fair_diffusion/MAIN_DATA_PAGE.R) - I cannot provide the actual empirical diffusion data, as I it is not mine to make public. But this script shows some of the preprocessing for configuring the empirical network data. 

[Empirical Moments](https://github.com/jsachs802/research_overview/blob/main/fair_diffusion/EMPIRICAL_MOMENTS.R) - functions that calculate the empirical moments of the Method of Simulated Moments from the empirical networks. 

[Simulated Moments](https://github.com/jsachs802/research_overview/blob/main/fair_diffusion/MOMENT_FUNCTIONS_E.R) - functions that calculate the simulated moments of the calibrated diffusion process.

[Moment Evaluation](https://github.com/jsachs802/research_overview/blob/main/fair_diffusion/MOMENT_EVAL_FUNCTIONS_E.R) - functions that evaluate the performance of the calibration process (hyperparameter tuning) which produce results for best parameter tuning.

_Strategy_: The second set of scripts allows one to run different seeding strategies on the calibrated models and measure the fairness of the outcomes.
