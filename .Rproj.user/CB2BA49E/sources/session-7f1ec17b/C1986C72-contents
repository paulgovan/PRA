#' Second Moment Analysis.
#'
#' @param mean The mean vector.
#' @param var The variance vector.
#' @param cor_mat The correlation matrix (optional).
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
#' @export
# Second Moment Method
smm <- function(mean, var, cor_mat = NULL) {

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
    for (i in 1:num_tasks) {
      for (j in 1:num_tasks) {
        cov_matrix[i, j] <- cor_mat[i, j] * sqrt(var[i] * var[j])
      }
    }
  } else {
    cov_matrix <- diag(var)
  }

    # Calculate the total mean
    total_mean <- sum(mean)

    # Calculate the total variance
    total_var <- sum(var) + sum(cov_matrix[upper.tri(cov_matrix)] *2)

    # Return a list with the results
    result <- list(total_mean = total_mean,
                   total_var = total_var,
                   total_std = sqrt(total_var))

    return(result)

}

