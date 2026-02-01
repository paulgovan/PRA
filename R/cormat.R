#' Generate Correlation Matrix from Random Samples.
#'
#' This function generates random samples from specified probability distributions
#' and computes the correlation matrix for the generated samples.
#'
#' @param num_samples The number of samples to generate.
#' @param num_vars The number of distributions to sample.
#' @param dists A list describing each distribution. Each element should be a function
#' that generates random samples. The names of the list elements will be used to
#' identify the distributions.
#'
#' @return The function returns the correlation matrix for the distributions.
#' @examples
#' # List of probability distributions
#' dists <- list(
#'   normal = function(n) rnorm(n, mean = 0, sd = 1),
#'   uniform = function(n) runif(n, min = 0, max = 1),
#'   exponential = function(n) rexp(n, rate = 1),
#'   poisson = function(n) rpois(n, lambda = 1),
#'   binomial = function(n) rbinom(n, size = 10, prob = 0.5)
#' )
#'
#' # Generate correlation matrix
#' cor_matrix <- cor_matrix(num_samples = 100, num_vars = 5, dists = dists)
#'
#' # Print correlation matrix
#' print(cor_matrix)
#'
#' @importFrom stats cor
#' @export
# Function to generate random samples and calculate correlation matrix
cor_matrix <- function(num_samples = 100, num_vars = 5, dists = dists) {
  # Error handling
  if (!is.list(dists) || length(dists) == 0) {
    stop("dists must be a non-empty list.")
  }
  if (!all(sapply(dists, is.function))) {
    stop("All elements in dists must be functions.")
  }

  # Error checks for num_samples
  if (!is.numeric(num_samples) || num_samples <= 0 || num_samples != as.integer(num_samples)) {
    stop("num_samples must be a positive integer.")
  }

  # Error checks for num_vars
  if (!is.numeric(num_vars) || num_vars <= 0 || num_vars != as.integer(num_vars)) {
    stop("num_vars must be a positive integer.")
  }
  if (num_vars > length(dists)) {
    stop("num_vars must not exceed the number of distributions in dists.")
  }

  # Initialize a matrix to store the samples
  samples <- matrix(0, nrow = num_samples, ncol = num_vars)

  # Randomly select distributions and generate samples
  for (i in 1:num_vars) {
    dist_name <- sample(names(dists), 1)
    samples[, i] <- dists[[dist_name]](num_samples)
  }

  # Calculate the correlation matrix
  cor_matrix <- stats::cor(samples)

  return(cor_matrix)
}
