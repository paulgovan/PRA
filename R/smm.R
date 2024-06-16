# # Estimated means of the work packages
# mean <- c(1036, 180, 75, 3.4, 17.7, 38.1, 71.7, 136, 124, 71.9, 140, 1089,
#           -3.4, 38.7, 3.2, 6.4, 6.4, 8)
#
# # Estimated correlation matrix for the work packages
# cor <- matrix(
#   data = c(1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
#            0 , 1, 0.6, 0, 0, 0.6, 0.6, 0.6, 0.6, 0, 0, 0.8, 0, 0, 0, 0, 0, 0,
#            0, 0.6, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
#            0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
#            0, 0, 0, 0, 1, 0.8, 0.8, 0.6, 0, 0, 0, 0.8, 0, 0, 0.8, 0, 0, 0),
#   nrow = 18, ncol = 18)
#
# # Estimated standard deviations of the work packages
# sd <- c(0.78, 33.3, 19.5, 4.36, 8.29, 15.8, 34.4, 29.3, 19.5, 19.9, 10.2, 33.4,
#          9.82, 56.4, 4.6, 9.34, 9.34, 11.7)

#' Second Moment Analysis.
#'
#' @param mean The mean vector.
#' @param var The variance vector.
#' @param cor_mat The correlation matrix.
#' @return The function returns a list of the total mean, variance, and standard deviation for the project.
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

