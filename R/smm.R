#' Second Moment Method Analysis.
#'
#' This function performs the Second Moment Method (SMM) analysis to estimate the
#' total mean, variance, and standard deviation of a project based on individual
#' task means, variances, and an optional correlation matrix.
#'
#' @param mean  The mean vector.
#' @param var The variance vector.
#' @param cor_mat The correlation matrix (optional). If not provided, tasks are assumed to be independent.
#' @return The function returns a list of the total mean, variance, and standard deviation for the project.
#' @examples
#'
#' # Set the mean vector, variance vector, and correlation matrix for a toy project.
#' mean <- c(10, 15, 20)
#' var <- c(4, 9, 16)
#' cor_mat <- matrix(c(
#'   1, 0.5, 0.3,
#'   0.5, 1, 0.4,
#'   0.3, 0.4, 1
#' ), nrow = 3, byrow = TRUE)
#'
#' # Use the Second Moment Method to estimate the results for the project.
#' result <- smm(mean, var, cor_mat)
#' print(result)
#'
#' # Without correlation matrix (independent tasks)
#' result <- smm(mean, var)
#' print(result)
#'
#' # When certain tasks are discrete and others are continuous, the SMM can still
#' # be applied as long as the variance values accurately reflect the variability of each task.
#'
#' discrete_mean <- c(5, 10)
#' discrete_var <- c(0, 0)
#' continuous_mean <- c(15, 20)
#' continuous_var <- c(4, 5)
#' mean <- c(discrete_mean, continuous_mean)
#' var <- c(discrete_var, continuous_var)
#' cor_mat <- matrix(c(
#'   1, 0, 0.2, 0.3,
#'   0, 1, 0.1, 0.2,
#'   0.2, 0.1, 1, 0.4,
#'   0.3, 0.2, 0.4,
#'   1
#' ), nrow = 4, byrow = TRUE)
#' result <- smm(mean, var, cor_mat)
#' print(result)
#'
#' @export
# Second Moment Method
smm <- function(mean, var, cor_mat = NULL) {
  # Error handling
  if (is.null(mean) || is.null(var)) {
    stop("mean and var must not be NULL")
  }
  if (!is.numeric(mean) || !is.numeric(var)) {
    stop("mean and var must be numeric vectors")
  }
  if (length(mean) == 0 || length(var) == 0) {
    stop("mean and var must not be empty")
  }
  if (anyNA(mean) || anyNA(var)) {
    stop("mean and var must not contain NA values")
  }
  if (any(var < 0)) {
    stop("var values must be non-negative")
  }
  # Check if the mean and variance vectors have the same length
  if (length(mean) != length(var)) {
    stop("The mean and variance vectors must have the same length.")
  }

  num_tasks <- length(mean)

  # Calculate the covariance matrix
  if (!is.null(cor_mat)) {
    if (!is.matrix(cor_mat) || nrow(cor_mat) != num_tasks || ncol(cor_mat) != num_tasks) {
      stop("The correlation matrix must be square and match the number of tasks.")
    }

    cov_matrix <- matrix(0, nrow = num_tasks, ncol = num_tasks)
    for (i in seq_len(num_tasks)) {
      for (j in seq_len(num_tasks)) {
        cov_matrix[i, j] <- cor_mat[i, j] * sqrt(var[i] * var[j])
      }
    }
  } else {
    cov_matrix <- diag(var)
  }

  # Calculate the total mean
  total_mean <- sum(mean)

  # Calculate the total variance
  total_var <- sum(var) + sum(cov_matrix[upper.tri(cov_matrix)] * 2)

  # Return a list with the results
  result <- list(
    total_mean = total_mean,
    total_var = total_var,
    total_std = sqrt(total_var)
  )

  class(result) <- "smm"
  return(result)
}

#' Print method for SMM results.
#'
#' This function defines how to print the results of the Second Moment Method
#' (SMM) analysis. It formats the output to display the total mean, variance,
#' and standard deviation in a readable manner.
#' @param x An object of class "smm" containing the SMM results.
#' @param ... Additional arguments (not used).
#' @export
#' @method print smm
#' @examples
#' mean <- c(10, 15, 20)
#' var <- c(4, 9, 16)
#' cor_mat <- matrix(c(
#'   1, 0.5, 0.3,
#'   0.5, 1, 0.4,
#'   0.3, 0.4, 1
#' ), nrow = 3, byrow = TRUE)
#' result <- smm(mean, var, cor_mat)
#' print(result)
#'
#' # Without correlation matrix (independent tasks)
#' result <- smm(mean, var)
#' print(result)
#'
print.smm <- function(x, ...) {
  cat("Second Moment Method Results:\n")
  cat("------------------------------\n")
  cat("Total Mean: ", x$total_mean, "\n")
  cat("Total Variance: ", x$total_var, "\n")
  cat("Total Standard Deviation: ", x$total_std, "\n")
}
