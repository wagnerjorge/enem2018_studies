#' Scale change
#' 
#' Used to change the  (0, 1) scale for (mu, sigma) scale, where mu and sigma indicate the
#' mean and the standard deviation, respectively. These values should be defined by user.
scale_change <- function(value, mu, sigma){
  sigma * value + mu
}