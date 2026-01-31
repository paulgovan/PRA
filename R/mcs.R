#' Monte Carlo Simulation.
#'
#' This function performs a Monte Carlo simulation to estimate the total duration of a project
#' based on individual task distributions and an optional correlation matrix.
#'
#' @param num_sims The number of simulations to run.
#' @param task_dists A list of lists describing each task distribution with its parameters.
#' Each task distribution should be specified as a list with a "type" field (indicating
#' the distribution type: "normal", "triangular", or "uniform") and the corresponding
#' parameters: for "normal" (mean, sd), for "triangular" (a, b, c), and for "uniform"
#' (min, max). For example:
#' list(
#'  list(type = "normal", mean = 10, sd = 2),
#'  list(type = "triangular", a = 5, b = 10, c = 15),
#'  list(type = "uniform", min = 8, max = 12)
#'  )
#' @param cor_mat The correlation matrix for the tasks (Optional). If not provided,
#' tasks are assumed to be independent.
#' @return The function returns a list of the total mean, variance, standard deviation,
#' and percentiles for the project.
#' @examples
#' # Set the number of simulations and task distributions for a toy project.
#' num_sims <- 10000
#' task_dists <- list(
#'   list(type = "normal", mean = 10, sd = 2), # Task A: Normal distribution
#'   list(type = "triangular", a = 5, b = 10, c = 15), # Task B: Triangular distribution
#'   list(type = "uniform", min = 8, max = 12) # Task C: Uniform distribution
#' )
#'
#' # Set the correlation matrix for the correlations between tasks.
#' cor_mat <- matrix(c(
#'   1, 0.5, 0.3,
#'   0.5, 1, 0.4,
#'   0.3, 0.4, 1
#' ), nrow = 3, byrow = TRUE)
#'
#' # Run the Monte Carlo sumulation and print the results.
#' results <- mcs(num_sims, task_dists, cor_mat)
#' cat("Mean Total Duration:", results$total_mean, "\n")
#' cat("Variance of Total Variance:", results$total_variance, "\n")
#' cat("Standard Deviation of Total Duration:", results$total_sd, "\n")
#' cat("5th Percentile:", results$percentiles[1], "\n")
#' cat("Median (50th Percentile):", results$percentiles[2], "\n")
#' cat("95th Percentile:", results$percentiles[3], "\n")
#' hist(results$total_distribution,
#'   breaks = 50, main = "Distribution of Total Project Duration",
#'   xlab = "Total Duration", col = "skyblue", border = "white"
#' )
#' legend("topright", legend = c("Total Duration Distribution"), fill = c("skyblue"))
#'
#' @importFrom mc2d rtriang
#' @importFrom stats rnorm runif var sd quantile
#' @export

# Monte Carlo Simulation
mcs <- function(num_sims, task_dists, cor_mat = NULL) {
  num_tasks <- length(task_dists)

  # Generate uncorrelated random samples for each task based on the specified distributions
  uncorrelated_samples <- matrix(NA, nrow = num_sims, ncol = num_tasks)
  for (i in seq_along(task_dists)) {
    dist <- task_dists[[i]]
    if (dist$type == "normal") {
      uncorrelated_samples[, i] <- stats::rnorm(num_sims, mean = dist$mean, sd = dist$sd)
    } else if (dist$type == "triangular") {
      uncorrelated_samples[, i] <- mc2d::rtriang(num_sims, min = dist$a, mode = dist$b, max = dist$c)
    } else if (dist$type == "uniform") {
      uncorrelated_samples[, i] <- stats::runif(num_sims, min = dist$min, max = dist$max)
    } else {
      stop("Unsupported distribution type.")
    }
  }

  # Apply Cholesky decomposition to the correlation matrix if provided
  if (!is.null(cor_mat)) {
    if (!is.matrix(cor_mat) || nrow(cor_mat) != num_tasks || ncol(cor_mat) != num_tasks) {
      stop("The correlation matrix must be square and match the number of tasks.")
    }
    cholesky_decomp <- chol(cor_mat)
    correlated_samples <- uncorrelated_samples %*% cholesky_decomp
  } else {
    correlated_samples <- uncorrelated_samples
  }

  # Calculate total project duration for each simulation
  total_distribution <- rowSums(correlated_samples)

  # Analyze the results
  total_mean <- mean(total_distribution)
  total_variance <- stats::var(total_distribution)
  total_sd <- stats::sd(total_distribution)
  percentiles <- stats::quantile(total_distribution, probs = c(0.05, 0.50, 0.95))

  # Create a list to return the results
  result <- list(
    total_mean = total_mean,
    total_variance = total_variance,
    total_sd = total_sd,
    percentiles = percentiles,
    total_distribution = total_distribution
  )

  class(result) <- "mcs"
  return(result)
}

#' Print method for Monte Carlo Simulation results.
#'
#' Displays the total mean, variance, standard deviation, and percentiles of the
#' Monte Carlo Simulation results in a readable format.
#' @param x An object of class "mcs".
#' @param ... Additional arguments (not used).
#' @export
#'
print.mcs <- function(x, ...) {
  cat("Monte Carlo Simulation Results:\n")
  cat("Total Mean:", x$total_mean, "\n")
  cat("Total Variance:", x$total_variance, "\n")
  cat("Total Standard Deviation:", x$total_sd, "\n")
  cat("Percentiles:\n")
  print(x$percentiles)
}
