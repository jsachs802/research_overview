### Efficiency 

# Biased Golf bootstrapped variances 
load("####/variances.Rda")
bg_variances = variances
w_mean_fn <- function(x, w) sum(x*w)
bg_boot_strap = boot::boot(bg_variances, statistic = w_mean_fn, R = 1000, stype = "w")
get_boot_conf_int_fn <- function(boot_strap){
  
  conf_int = boot::boot.ci(boot_strap, type = "basic")
  return(conf_int)
}
bg_var_ci <- get_boot_conf_int_fn(bg_boot_strap)
bg_var_ci$basic[4]
bg_var_ci$basic[5]
bg_boot_strap$t0


# Golf bootsrapped variances 
load("#####/variances.Rda")
g_variances = variances
w_mean_fn <- function(x, w) sum(x*w)
g_boot_strap = boot::boot(g_variances, statistic = w_mean_fn, R = 1000, stype = "w")
get_boot_conf_int_fn <- function(boot_strap){
  
  conf_int = boot::boot.ci(boot_strap, type = "basic")
  return(conf_int)
}
g_var_ci <- get_boot_conf_int_fn(g_boot_strap)
g_var_ci$basic[4]
g_var_ci$basic[5]
g_boot_strap$t0

## Relative Efficiency 
relative_efficiency = g_boot_strap$t0/bg_boot_strap$t0
relative_efficiency

g_var_ci$basic

min_upper = min(g_var_ci$basic[5], bg_var_ci$basic[5])
max_lower = max(bg_var_ci$basic[4], g_var_ci$basic[4])

min_upper - max_lower
## Stability of Variances 
max(0, (min_upper - max_lower))

bg_var_ci$basic[4]


