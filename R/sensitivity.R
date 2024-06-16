#' Sensitivity Analysis.
#'
#' @param task_dists A list of lists describing each task distribution.
#' @param cor_mat The correlation matrix for the tasks.
#' @return The function returns a vector of sensitivity results with respect to
#' each task.
#' @examples
#' task_dists <- list(
#'   list(type = "normal", mean = 10, sd = 2),  # Task A: Normal distribution
#'   list(type = "triangular", a = 5, b = 15, c = 10),  # Task B: Triangular distribution
#'   list(type = "uniform", min = 8, max = 12)  # Task C: Uniform distribution
#' )
#' cor_mat <- matrix(c(
#'   1, 0.5, 0.3,
#'  0.5, 1, 0.4,
#'   0.3, 0.4, 1
#' ), nrow = 3, byrow = TRUE)
#' sensitivity_results <- sensitivity(task_dists, cor_mat)
#' cat("Sensitivity of the variance in total cost with respect to the variance in each task cost:\n")
#' print(sensitivity_results)
#' @export

# Define the sensitivity analysis function
sensitivity <- function(task_dists, cor_mat = NULL) {
  num_tasks <- length(task_dists)

  # Extract variances from task distributions
  task_variances <- sapply(task_dists, function(dist) {
    if (dist$type == "normal") {
      return(dist$sd^2)
    } else if (dist$type == "triangular") {
      return((dist$a^2 + dist$b^2 + dist$c^2 - dist$a*dist$b - dist$a*dist$c - dist$b*dist$c) / 18)
    } else if (dist$type == "uniform") {
      return((dist$max - dist$min)^2 / 12)
    } else {
      stop("Unsupported distribution type.")
    }
  })

  # Create the covariance matrix
  if (!is.null(cor_mat)) {
    if (!is.matrix(cor_mat) || nrow(cor_mat) != num_tasks || ncol(cor_mat) != num_tasks) {
      stop("The correlation matrix must be square and match the number of tasks.")
    }

    cov_matrix <- matrix(0, nrow = num_tasks, ncol = num_tasks)
    for (i in 1:num_tasks) {
      for (j in 1:num_tasks) {
        cov_matrix[i, j] <- cor_mat[i, j] * sqrt(task_variances[i] * task_variances[j])
      }
    }
  } else {
    cov_matrix <- diag(task_variances)
  }

  # Calculate the total variance of the project cost
  total_variance <- sum(task_variances) + sum(cov_matrix[upper.tri(cov_matrix)] * 2)

  # Initialize sensitivity vector
  sensitivity <- numeric(num_tasks)

  # Calculate the sensitivity of the total variance with respect to each task's variance
  for (i in 1:num_tasks) {
    sensitivity[i] <- 1 + 2 * sum(cov_matrix[i, -i] / sqrt(task_variances[i] * task_variances[-i]))
  }

  # Return the sensitivity vector
  return(sensitivity)
}
