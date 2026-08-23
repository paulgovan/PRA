#' Monte Carlo Simulation.
#'
#' This function performs a Monte Carlo simulation to estimate the total duration of a project
#' based on individual task distributions and an optional correlation matrix.
#'
#' @srrstats {G1.0} *Software lists primary reference from published academic literature.*
#' @srrstats {G1.1} *Software is the first implementation within **R** of the algorithm which has previously been implemented in other languages or contexts.*
#' @srrstats {G1.4} *Software uses [`roxygen2`](https://roxygen2.r-lib.org/) to document all functions.*
#' @srrstats {G2.0} *Implements assertions on lengths of inputs - validates num_sims is single value and cor_mat dimensions match tasks.*
#' @srrstats {G2.0a} *Parameter documentation explicitly states expected input structure.*
#' @srrstats {G2.1} *Implements assertions on types of inputs via is.numeric(), is.list(), and is.matrix() checks.*
#' @srrstats {G2.1a} *Parameter documentation explicitly states data types expected.*
#' @srrstats {G2.2} *Prohibits multivariate input for num_sims which must be a single positive integer.*
#' @srrstats {G2.4a} *Uses as.integer() for integer comparison of num_sims.*
#' @srrstats {G2.13} *Implements checks for NA values in num_sims.*
#' @srrstats {G2.14a} *Errors on missing data with informative message.*
#' @srrstats {G2.15} *Implements checks for NaN values via is.nan() prior to processing.*
#' @srrstats {G2.16} *Implements checks for Inf/-Inf values via is.infinite() prior to processing.*
#' @srrstats {G3.1} *Correlation handling is user-controlled via optional cor_mat parameter.*
#' @srrstats {G3.1a} *Documentation describes usage of correlation matrix in examples.*
#' @srrstats {G5.2a} *Each error message produced by stop() is unique.*
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
#' @note When a correlation matrix is supplied, dependence is induced by
#' Cholesky decomposition. The correlation matrix is factored, independent
#' standard normal scores are multiplied by the Cholesky factor to carry the
#' target correlation, and each column is then returned to its own scale through
#' the normal CDF and that task's inverse CDF. Applying the factor to standard
#' normal scores rather than to the raw task draws is required for the
#' factorization to be valid, since it presumes unit-variance inputs. Every
#' marginal distribution is therefore preserved exactly. The sampled rank
#' correlation matches the target matrix, while the product-moment correlation
#' is approximate: it is attenuated for strongly skewed marginals, an inherent
#' property of the transform. [smm()] remains available when only first and second moments are
#' needed; see the package's design-structure tools for modeling structural
#' dependence directly.
#' @references
#' Damnjanovic, Ivan, and Kenneth Reinschmidt. Data analytics for engineering and
#' construction project risk management. No. 172534. Cham, Switzerland: Springer, 2020.
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
#' @importFrom mc2d rtriang qtriang
#' @importFrom stats rnorm runif var sd quantile pnorm qnorm qunif
#' @export

# Monte Carlo Simulation
mcs <- function(num_sims, task_dists, cor_mat = NULL) {
  # Error handling
  if (is.null(num_sims) || is.null(task_dists)) {
    stop("num_sims and task_dists must not be NULL")
  }
  if (!is.numeric(num_sims) || length(num_sims) != 1) {
    stop("num_sims must be a single positive integer")
  }
  if (is.nan(num_sims)) {
    stop("num_sims must not be NaN")
  }
  if (is.na(num_sims)) {
    stop("num_sims must not be NA")
  }
  if (is.infinite(num_sims)) {
    stop("num_sims must not be infinite")
  }
  if (num_sims <= 0 || num_sims != as.integer(num_sims)) {
    stop("num_sims must be a positive integer")
  }
  if (!is.list(task_dists) || length(task_dists) == 0) {
    stop("task_dists must be a non-empty list")
  }

  num_tasks <- length(task_dists)

  # Validate the correlation matrix before drawing any samples
  if (!is.null(cor_mat)) {
    validate_cor_mat(cor_mat, num_tasks)
  }

  task_samples <- matrix(NA, nrow = num_sims, ncol = num_tasks)

  if (is.null(cor_mat)) {
    # Independent tasks: draw each task directly from its own distribution.
    for (i in seq_along(task_dists)) {
      dist <- task_dists[[i]]
      if (dist$type == "normal") {
        task_samples[, i] <- stats::rnorm(num_sims, mean = dist$mean, sd = dist$sd)
      } else if (dist$type == "triangular") {
        task_samples[, i] <- mc2d::rtriang(num_sims, min = dist$a, mode = dist$b, max = dist$c)
      } else if (dist$type == "uniform") {
        task_samples[, i] <- stats::runif(num_sims, min = dist$min, max = dist$max)
      } else {
        stop("Unsupported distribution type.")
      }
    }
  } else {
    # Correlated tasks: Cholesky decomposition. The Cholesky factor is applied
    # to independent standard normal scores (the factorization presumes
    # unit-variance inputs, so it must not be applied to the raw task draws),
    # which are mapped to percentiles by the normal CDF and then returned to
    # each task's own scale by its inverse CDF. Because each task is drawn from
    # its own quantile function, the marginal distributions are preserved
    # exactly while the sample reproduces the target correlation.
    z <- matrix(stats::rnorm(num_sims * num_tasks), nrow = num_sims, ncol = num_tasks)
    u <- stats::pnorm(z %*% chol(cor_mat))

    for (i in seq_along(task_dists)) {
      dist <- task_dists[[i]]
      if (dist$type == "normal") {
        task_samples[, i] <- stats::qnorm(u[, i], mean = dist$mean, sd = dist$sd)
      } else if (dist$type == "triangular") {
        task_samples[, i] <- mc2d::qtriang(u[, i], min = dist$a, mode = dist$b, max = dist$c)
      } else if (dist$type == "uniform") {
        task_samples[, i] <- stats::qunif(u[, i], min = dist$min, max = dist$max)
      } else {
        stop("Unsupported distribution type.")
      }
    }
  }

  # Calculate total project duration for each simulation
  total_distribution <- rowSums(task_samples)

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
#' @return None. Prints the results to the console.
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
#' # print(results)
#' @export
print.mcs <- function(x, ...) {
  cat("Monte Carlo Simulation Results:\n")
  cat("Total Mean:", x$total_mean, "\n")
  cat("Total Variance:", x$total_variance, "\n")
  cat("Total Standard Deviation:", x$total_sd, "\n")
  cat("Percentiles:\n")
  print(x$percentiles)
}
