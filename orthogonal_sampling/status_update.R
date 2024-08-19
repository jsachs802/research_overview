# STATUSES  -------------------------------------------------------------------

### ---------------------- UPDATE STATUS ------------------------
# INPUTS: 
# status - text string indicating status 
# name - text for indicating hashtag of interest and where to save
#
# OUTPUTS: 
# save - save of status text (to keep track of where in the sampling process)

update_status_fn <- function(status, root, name){
  text <- paste("TIME:", Sys.time(), "STATUS:", status, "for #", name)
  file <- paste0(root, "orthogonal_sampling_project/", name, "/statuses.txt")
  write(text, file, sep = "\n", append = TRUE)
  
}
