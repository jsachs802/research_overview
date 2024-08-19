# VISUALIZATION ----------------------------------------------------------------

### ---------------------- MAKE VISUALIZATION FUNCTION ------------------------
# INPUTS: 
# paths - files paths making visualization
# name - hashtag of interest or folder name for title of plot
#
# OUTPUTS: 
# plot - density of plot of sampling distribution with GT, estimate, and confidence intevals

make_viz_fn <- function(paths, name){
  
  #load ground truth data <paths[1]>
  load(paths[1])
  # load estimate objects <paths[2]>
  load(paths[2])
  
  
  # get rounded date interval
  date_range = get_date_range_fn(ground_truth)
  #subset ground truth data to date interval 
  gt_sub = set_date_interval_fn(ground_truth, date_range)
  
  ## objects for plot
  estimate = estimate_objects[[1]]
  ci = estimate_objects[[2]]
  sample_dist = estimate_objects[[3]]
  gt_count = nrow(gt_sub)
  
  
  ## Aesthetic Specs for Plot
  line_width = 1.2
  line_width_b = 1
  alph = 0.3
  bg_col = "#0bb4ff"
  gt_col = "#e60049"
  org_col = "#9b19f5"
  boot_col = "#ffa300"
  ci_col = "#dc0ab4"
  panel_col = "#3b3734"
  
  ## Saving plot as png
  png(filename = paths[3], width = 10, height = 8, units = "in", res = 300)
  ggplot() + 
    # geom_histogram(mapping = aes(x = estimate, y = ..density..), color = "white", fill = NA, bins = 28) + 
    geom_density(mapping = aes(sample_dist), fill = bg_col, 
                 color = "white", alpha = alph) + 
    geom_vline(aes(xintercept = gt_count), linetype = "solid", 
               color = gt_col, linewidth = line_width) +
    geom_vline(aes(xintercept = estimate), linetype = "dashed", 
               color = boot_col, size = line_width) +
    geom_vline(aes(xintercept = ci[1]), linetype = "dotted", 
               color = ci_col, linewidth = line_width_b) +
    geom_vline(aes(xintercept = ci[2]), linetype = "dotted", 
               color = ci_col, linewidth = line_width_b) +
    labs(Title = paste0(name," Sampling Distribution"), 
         x = "Population Abundance Estimate", y = "Density") + 
    theme(panel.background = element_rect(fill = panel_col, 
                                          color = panel_col), 
          panel.border = element_blank(),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(), 
          plot.background = element_rect(fill = panel_col), 
          text = element_text(color = "white"), 
          axis.text = element_text(color = "white"))
  dev.off()
  
  ## Creating plot object to return
  plot <- ggplot() + 
    # geom_histogram(mapping = aes(x = estimate, y = ..density..), color = "white", fill = NA, bins = 28) + 
    geom_density(mapping = aes(sample_dist), fill = bg_col, 
                 color = "white", alpha = alph) + 
    geom_vline(aes(xintercept = gt_count), linetype = "solid", 
               color = gt_col, linewidth = line_width) +
    geom_vline(aes(xintercept = estimate), linetype = "dashed", 
               color = boot_col, size = line_width) +
    geom_vline(aes(xintercept = ci[1]), linetype = "dotted", 
               color = ci_col, linewidth = line_width_b) +
    geom_vline(aes(xintercept = ci[2]), linetype = "dotted", 
               color = ci_col, linewidth = line_width_b) +
    labs(Title = paste0(name," Sampling Distribution"), 
         x = "Population Abundance Estimate", y = "Density") + 
    theme(panel.background = element_rect(fill = panel_col, 
                                          color = panel_col), 
          panel.border = element_blank(),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(), 
          plot.background = element_rect(fill = panel_col), 
          text = element_text(color = "white"), 
          axis.text = element_text(color = "white"))
  
  return(plot)
  
}


