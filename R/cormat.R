# Internal: validate a user-supplied correlation matrix. Shared by mcs(), smm()
# and sensitivity() so the same matrix is accepted or rejected identically
# wherever it is used, and so a matrix that is not a correlation matrix is
# caught here rather than surfacing later as a cryptic Cholesky failure.
validate_cor_mat <- function(cor_mat, num_tasks) {
  if (!is.matrix(cor_mat) || nrow(cor_mat) != num_tasks ||
      ncol(cor_mat) != num_tasks) {
    stop("The correlation matrix must be square and match the number of tasks.")
  }
  if (any(is.nan(cor_mat))) {
    stop("cor_mat must not contain NaN values")
  }
  if (anyNA(cor_mat)) {
    stop("cor_mat must not contain NA values")
  }
  if (any(is.infinite(cor_mat))) {
    stop("cor_mat must not contain infinite values")
  }
  if (!isTRUE(all.equal(cor_mat, t(cor_mat), check.attributes = FALSE))) {
    stop("cor_mat must be symmetric")
  }
  if (any(cor_mat < -1 | cor_mat > 1)) {
    stop("cor_mat values must be between -1 and 1")
  }
  if (!isTRUE(all.equal(as.numeric(diag(cor_mat)), rep(1, num_tasks)))) {
    stop("cor_mat must have ones on the diagonal")
  }
  invisible(TRUE)
}

#' Generate Correlation Matrix from Random Samples.
#'
#' This function generates random samples from specified probability distributions
#' and computes the correlation matrix for the generated samples.
#'
#' @srrstats {G1.0} *Software lists primary reference from published academic literature.*
#' @srrstats {G1.1} *Software is the first implementation within **R** of the algorithm which has previously been implemented in other languages or contexts.*
#' @srrstats {G1.4} *Software uses [`roxygen2`](https://roxygen2.r-lib.org/) to document all functions.*
#' @srrstats {G2.0} *Implements assertions on lengths of inputs - validates num_vars does not exceed length of dists.*
#' @srrstats {G2.0a} *Parameter documentation explicitly states expected input types.*
#' @srrstats {G2.1} *Implements assertions on types of inputs via is.numeric() and is.list() checks.*
#' @srrstats {G2.1a} *Parameter documentation explicitly states data types expected (positive integers, list of functions).*
#' @srrstats {G2.4a} *Uses as.integer() for integer comparison of num_samples and num_vars.*
#' @srrstats {G2.15} *Implements checks for NaN values via is.nan() prior to processing.*
#' @srrstats {G2.16} *Implements checks for Inf/-Inf values via is.infinite() prior to processing.*
#' @srrstats {G5.2a} *Each error message produced by stop() is unique.*
#'
#' @param num_samples The number of samples to generate.
#' @param num_vars The number of distributions to sample. The first `num_vars`
#' elements of `dists` are used.
#' @param dists A list describing each distribution. Each element should be a function
#' that generates random samples. The names of the list elements are used to
#' label the rows and columns of the result.
#'
#' @return The function returns the correlation matrix for the distributions,
#' with rows and columns named after the distributions they were drawn from.
#' Because the columns are sampled independently, the off-diagonal entries are
#' sampling noise about zero: this generates correctly shaped, positive-definite
#' input for testing and for a near-independent baseline, and is not an
#' estimator of dependence between tasks.
#' @references
#' Govan, Paul, and Ivan Damnjanovic. "The resource-based view on project risk management."
#' Journal of construction engineering and management 142.9 (2016): 04016034.
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
cor_matrix <- function(num_samples = 100, num_vars = 5, dists) {
  # Error handling
  if (!is.list(dists) || length(dists) == 0) {
    stop("dists must be a non-empty list.")
  }
  if (!all(sapply(dists, is.function))) {
    stop("All elements in dists must be functions.")
  }

  # Error checks for num_samples
  if (is.numeric(num_samples) && length(num_samples) == 1 && is.nan(num_samples)) {
    stop("num_samples must not be NaN.")
  }
  if (is.numeric(num_samples) && length(num_samples) == 1 && !is.nan(num_samples) && is.na(num_samples)) {
    stop("num_samples must not be NA.")
  }
  if (is.numeric(num_samples) && length(num_samples) == 1 && is.infinite(num_samples)) {
    stop("num_samples must not be infinite.")
  }
  if (!is.numeric(num_samples) || num_samples <= 0 || num_samples != as.integer(num_samples)) {
    stop("num_samples must be a positive integer.")
  }

  # Error checks for num_vars
  if (is.numeric(num_vars) && length(num_vars) == 1 && is.nan(num_vars)) {
    stop("num_vars must not be NaN.")
  }
  if (is.numeric(num_vars) && length(num_vars) == 1 && !is.nan(num_vars) && is.na(num_vars)) {
    stop("num_vars must not be NA.")
  }
  if (is.numeric(num_vars) && length(num_vars) == 1 && is.infinite(num_vars)) {
    stop("num_vars must not be infinite.")
  }
  if (!is.numeric(num_vars) || num_vars <= 0 || num_vars != as.integer(num_vars)) {
    stop("num_vars must be a positive integer.")
  }
  if (num_vars > length(dists)) {
    stop("num_vars must not exceed the number of distributions in dists.")
  }

  # Initialize a matrix to store the samples
  samples <- matrix(0, nrow = num_samples, ncol = num_vars)

  # Column i is drawn from distribution i, so the rows and columns of the
  # returned matrix line up with the distributions the caller supplied. Taking
  # the first num_vars of them keeps the mapping obvious when num_vars is
  # smaller than the number supplied.
  for (i in seq_len(num_vars)) {
    samples[, i] <- dists[[i]](num_samples)
  }

  # Calculate the correlation matrix
  cor_matrix <- stats::cor(samples)

  # Label the result so each row and column names its distribution.
  labels <- names(dists)
  if (is.null(labels) || any(!nzchar(labels))) {
    labels <- paste0("V", seq_along(dists))
  }
  dimnames(cor_matrix) <- list(labels[seq_len(num_vars)],
                               labels[seq_len(num_vars)])

  return(cor_matrix)
}
