## Consistency 
library(tidyverse)

# Golf Consistency
load("####/consistency_objects.Rda")
load("####/estimate_objects.Rda")
g_con_objs = consistency_objects
# ground truth 
g_gt = estimate_objects[[4]][1]

rm(consistency_objects)
rm(estimate_objects)

g_con_objs
g_biases = vector(mode = "numeric", length = length(g_con_objs))
g_lower_ci = vector(mode = "numeric", length = length(g_con_objs))
g_upper_ci = vector(mode = "numeric", length = length(g_con_objs))
fractions = vector(mode = "numeric", length = length(g_con_objs))
for(i in 1:length(g_con_objs)){
  
  g_biases[i] <- abs(g_con_objs[[i]][[1]] - g_gt)
  g_lower_ci[i] <- g_con_objs[[i]][[2]][1]
  g_upper_ci[i] <- g_con_objs[[i]][[3]][1]
  fractions[i] <- g_con_objs[[i]][[4]][1]
}

g_re = abs(g_biases)/g_gt

g_re

g_df <- tibble(size = fractions, re = g_re, lower_ci = g_lower_ci, upper_ci = g_upper_ci, hashtag = "Golf")

g_df

# Work Consistency
load("#####/consistency_objects.Rda")
w_con_objs = consistency_objects
load("####/estimate_objects.Rda")
# ground truth 
w_gt = estimate_objects[[4]][1]

rm(consistency_objects)
rm(estimate_objects)

w_biases = vector(mode = "numeric", length = length(w_con_objs))
w_lower_ci = vector(mode = "numeric", length = length(w_con_objs))
w_upper_ci = vector(mode = "numeric", length = length(w_con_objs))
for(i in 1:length(w_con_objs)){
  
  w_biases[i] <- abs(w_con_objs[[i]][[1]] - w_gt)
  w_lower_ci[i] <- w_con_objs[[i]][[2]][1]
  w_upper_ci[i] <- w_con_objs[[i]][[3]][1]
}

w_biases
w_con_objs
w_re = abs(w_biases)/w_gt
w_df <- tibble(size = fractions, re = w_re, lower_ci = w_lower_ci, upper_ci = w_upper_ci, hashtag = "Work")
w_df


# Biased_Golf Consistency
load("####/consistency_objects.Rda")
bg_con_objs = consistency_objects
load("####/estimate_objects.Rda")
# ground truth 
bg_gt = estimate_objects[[4]][1]

rm(consistency_objects)
rm(estimate_objects)

bg_biases = vector(mode = "numeric", length = length(bg_con_objs))
bg_lower_ci = vector(mode = "numeric", length = length(bg_con_objs))
bg_upper_ci = vector(mode = "numeric", length = length(bg_con_objs))
for(i in 1:length(bg_con_objs)){
  
  bg_biases[i] <- abs(bg_con_objs[[i]][[1]] - bg_gt)
  bg_lower_ci[i] <- bg_con_objs[[i]][[2]][1]
  bg_upper_ci[i] <- bg_con_objs[[i]][[3]][1]
}

bg_re = abs(bg_biases)/bg_gt

bg_df <- tibble(size = fractions, re = bg_re, lower_ci = bg_lower_ci, upper_ci = bg_upper_ci, hashtag = "Biased Golf")

bg_df

### Combine the dataframes 
all_df <- rbind(g_df, w_df, bg_df)


### Plot results 
library(ggplot2)


line_width = 3
line_width_b = 1
alph = 0.3
bg_col = "#0bb4ff"
gt_col = "#e60049"
org_col = "#9b19f5"
boot_col = "#ffa300"
ci_col = "#dc0ab4"
panel_col = "#3b3734"



### BIASED GOLF PLOT
ggplot(bg_df) + 
  # geom_smooth(mapping = aes(x = size, y = bias), method = loess, se=F, color=bg_col, linewidth = line_width) + 
  geom_line(mapping = aes(x = size, y = bg_re), color=bg_col, linewidth = line_width) +
  # geom_smooth(mapping = aes(x = size, y = lower_ci), method = loess, se=F, linetype=2, color=bg_col) +
  # geom_smooth(mapping = aes(x = size, y = upper_ci), method = loess, se=F, linetype=2, color=bg_col) +
  # geom_hline(aes(yintercept=w_gt), color=org_col, linewidth=line_width) +
  labs(x = "Sample Size", y = "Relative Error") +
  theme(panel.background = element_rect(fill = panel_col, 
                                        color = panel_col), 
        panel.border = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), 
        plot.background = element_rect(fill = panel_col), 
        text = element_text(color = "white"), 
        axis.text = element_text(color = "white", size = 10), 
        axis.title = element_text(color = "white", size = 15))


### WORK PLOT
ggplot(w_df) + 
  # geom_smooth(mapping = aes(x = size, y = bias), method = lm, se=F, color=bg_col, linewidth = line_width) + 
  geom_line(mapping = aes(x = size, y = re), color=bg_col, linewidth = line_width) +
  # geom_smooth(mapping = aes(x = size, y = lower_ci), method = loess, se=F, linetype=2, color=bg_col) +
  # geom_smooth(mapping = aes(x = size, y = upper_ci), method = loess, se=F, linetype=2, color=bg_col) +
  # geom_hline(aes(yintercept=w_gt), color=org_col, linewidth=line_width) +
  labs(x = "Sample Size", y = "Relative Error") +
  theme(panel.background = element_rect(fill = panel_col, 
                                        color = panel_col), 
        panel.border = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), 
        plot.background = element_rect(fill = panel_col), 
        text = element_text(color = "white"), 
        axis.text = element_text(color = "white", size = 10), 
        axis.title = element_text(color = "white", size = 15))


### GOLF PLOT
ggplot(g_df) + 
  # geom_smooth(mapping = aes(x = size, y = bias), method = lm, se=F, color=bg_col, linewidth = line_width) + 
  geom_line(mapping = aes(x = size, y = re), color=bg_col, linewidth = line_width) +
  # geom_smooth(mapping = aes(x = size, y = lower_ci), method = loess, se=F, linetype=2, color=bg_col) +
  # geom_smooth(mapping = aes(x = size, y = upper_ci), method = loess, se=F, linetype=2, color=bg_col) +
  # geom_hline(aes(yintercept=w_gt), color=org_col, linewidth=line_width) +
  labs(x = "Sample Size", y = "Relative Error") +
  theme(panel.background = element_rect(fill = panel_col, 
                                        color = panel_col), 
        panel.border = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), 
        plot.background = element_rect(fill = panel_col), 
        text = element_text(color = "white"), 
        axis.text = element_text(color = "white", size = 10), 
        axis.title = element_text(color = "white", size = 15))

  
