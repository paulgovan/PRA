#' Contingency Calculation.
#'
#' @param sims List of results from a Monte Carlo simulation.
#' @param phigh Percentile level for contingency calculation.
#' @param pbase Base level for contingency calculation.
#' @return The function returns the value of calculated contingency.
#' @examples
#' num_sims <- 10000
#' task_dists <- list(
#'   list(type = "normal", mean = 10, sd = 2),  # Task A: Normal distribution
#'   list(type = "triangular", a = 5, b = 10, c = 15),  # Task B: Triangular distribution
#'   list(type = "uniform", min = 8, max = 12)  # Task C: Uniform distribution
#' )
#' cor_mat <- matrix(c(
#'   1, 0.5, 0.3,
#'   0.5, 1, 0.4,
#'   0.3, 0.4, 1
#' ), nrow = 3, byrow = TRUE)
#' results <- mcs(num_sims, task_dists, cor_mat)
#' contingency <- contingency(results, phigh = 0.95, pbase = 0.50)
#' cat("Contingency based on 95th percentile and 50th percentile:", contingency)
#' @export
contingency <- function(sims, phigh = 0.95, pbase = 0.50) {
  # Check for valid p-values
  if (!is.numeric(phigh) || phigh < 0 || phigh > 1) {
    stop("phigh must be between 0 and 1")
  }
  if (!is.numeric(pbase) || pbase < 0 || phigh > 1) {
    stop("pbase must be between 0 and 1")
  }
  if (phigh < pbase) {
    stop("phigh must be greater than pbase.")
  }

  # Extract the relevant percentiles from the simulation results
  phigh_value <- stats::quantile(sims$total_distribution, probs = phigh)
  pbase_value <- stats::quantile(sims$total_distribution, probs = pbase)

  # Calculate the contingency
  contingency <- phigh_value - pbase_value

  # Return the contingency value
  return(contingency)
}
