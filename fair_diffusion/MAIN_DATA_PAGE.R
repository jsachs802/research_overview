
######################## DATA MANAGEMENT PAGE #################################

# 1. MAIN NODES DATAFRAME ----------------------------------------------------
load("~/Github/Fair-Diff-Conflicts/R-Code/DATA/nodes_df.Rda")
# Loads <nodes_df> dataframe object

## Correctly specifying variables
nodes_df$heard <- as.logical(nodes_df$heard)
nodes_df$adopt <- as.logical(nodes_df$adopt)
nodes_df$female <- as.logical(nodes_df$female)
nodes_df$income <- as.factor(nodes_df$income)
nodes_df$edu <- as.logical(nodes_df$edu)
nodes_df$hasPhone <- as.logical(nodes_df$hasPhone)
nodes_df$leader <- as.logical(nodes_df$leader)
nodes_df$attend <- as.logical(nodes_df$attend)
nodes_df$priority <- as.factor(nodes_df$priority)
nodes_df$village <- as.factor(nodes_df$village)
nodes_df$usePhoneText <- as.logical(nodes_df$usePhoneText)


# 2. MAIN EDGELIST DATAFRAME -------------------------------------------------
load("~/Github/Fair-Diff-Conflicts/R-Code/DATA/edgelist.Rda")
# Loads <edgelist> dataframe object 

## 3. SECONDARY OJBECTS TO LOAD 
load("~/Github/Fair-Diff-Conflicts/R-Code/DATA/prob_grid.Rda") ## probability grid
load("~/Github/Fair-Diff-Conflicts/R-Code/DATA/empirical_moments.Rda") ## empirical moments 
### Village referred to by column 

# 4. CREATED INPUTS --------------------------------------------------------
villages <- c(7, 9, 14, 29, 40, 46, 47, 50, 51, 55, 66, 77, 80, 81)


vill_logit = glm(adopt ~ degree + age + edu + female + hasPhone, data = nodes_df, family = binomial()) 
# vill_logit <- glm(adopt ~ female + usePhoneText + edu + hasPhone + vil, data = nodes_df, family = "binomial") ## Main Village Logistic Regression estimate 
# vill_logit <- glm(adopt ~ female + degree + edu + pol_index, data = nodes_df, family = "binomial")
# init_adopt_logit <- glm(adopt ~ age + edu + hasPhone + degree, data = nodes_df[nodes_df$attend == 1, ], family = "binomial") ## Logistic regression estimate for adoption among meeting attendees
# init_adopt_logit <- glm(adopt ~ income + leader + edu + pol_index, data = nodes_df[nodes_df$attend == 1, ], family = "binomial")
n_moments <- 6 ## Number of moments in calibration model
t <-  6
vill <- NA
sims <- 100


### CREATING NEW VARIABLES FOR STRATEGIES 
# Likelihoods
nodes_df$likelihood <- NA
nodes_df$likelihood <- unname(predict(vill_logit, newdata = nodes_df, type = "response"))

# Both 
nodes_df$both <- NA
nodes_df$both <- nodes_df$degree*nodes_df$likelihood

### LOGIT ESTIMATIONS
### Clustered Standard Errors for Full Logit Model
# logit_full = glm(adopt ~ degree + age + edu + female + hasPhone + income + leader + distMeeting, data = nodes_df, family = binomial())
# robust_full<- coeftest(logit_full, vcov. = vcovCL(logit_full, cluster = nodes_df$village, type = "HC1"))
# 
# ### Restricted Models
# logit_res1 = glm(adopt ~ degree + age + edu + female + hasPhone + income + leader, data = nodes_df, family = binomial())
# robust_res1<- coeftest(logit_res1, vcov. = vcovCL(logit_res1, cluster = nodes_df$village, type = "HC1"))
# summary(logit_res1)
# robust_res1
# 
# logit_res2 = glm(adopt ~ degree + age + edu + female + hasPhone + income, data = nodes_df, family = binomial())
# robust_res2 <- coeftest(logit_res2, vcov. = vcovCL(logit_res2, cluster = nodes_df$village, type = "HC1"))
# summary(logit_res2)
# robust_res2

# logit_res3 = glm(adopt ~ degree + age + edu + female + hasPhone, data = nodes_df, family = binomial()) # MODEL I USE
# robust_res3 <- lmtest::coeftest(logit_res3, vcov. = sandwich::vcovCL(logit_res3, cluster = nodes_df$village, type = "HC1"))
# summary(logit_res3)
# robust_res3



