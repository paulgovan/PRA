#' Second Moment Method Analysis.
#'
#' This function performs the Second Moment Method (SMM) analysis to estimate the
#' total mean, variance, and standard deviation of a project based on individual
#' task means, variances, and an optional correlation matrix.
#'
#' @srrstats {G1.0} *Software lists primary reference from published academic literature.*
#' @srrstats {G1.1} *Software is the first implementation within **R** of the algorithm which has previously been implemented in other languages or contexts.*
#' @srrstats {G1.4} *Software uses [`roxygen2`](https://roxygen2.r-lib.org/) to document all functions.*
#' @srrstats {G2.0} *Implements assertions on lengths of inputs - mean and var vectors must have same length.*
#' @srrstats {G2.0a} *Parameter documentation explicitly states expected input structure.*
#' @srrstats {G2.1} *Implements assertions on types of inputs via is.numeric() and is.matrix() checks.*
#' @srrstats {G2.1a} *Parameter documentation explicitly states data types expected.*
#' @srrstats {G2.13} *Implements checks for missing data via anyNA() prior to processing.*
#' @srrstats {G2.14a} *Errors on missing data with informative message.*
#' @srrstats {G2.15} *Implements checks for NaN values via is.nan() prior to processing.*
#' @srrstats {G2.16} *Implements checks for Inf/-Inf values via is.infinite() prior to processing.*
#' @srrstats {G3.1} *Correlation handling is user-controlled via optional cor_mat parameter.*
#' @srrstats {G3.1a} *Documentation describes usage of correlation matrix in examples.*
#' @srrstats {G5.2a} *Each error message produced by stop() is unique.*
#'
#' @param mean  The mean vector.
#' @param var The variance vector.
#' @param cor_mat The correlation matrix (optional). If not provided, tasks are assumed to be independent.
#' @return An S3 object of class `"smm"`: a list of the total mean
#' (`total_mean`), variance (`total_var`) and standard deviation
#' (`total_std`) for the project. Objects of this class have [print.smm()],
#' [summary.smm()] and [plot.smm()] methods.
#' @references
#' Damnjanovic, Ivan, and Kenneth Reinschmidt. Data analytics for engineering and
#' construction project risk management. No. 172534. Cham, Switzerland: Springer, 2020.
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
  if (any(is.nan(mean)) || any(is.nan(var))) {
    stop("mean and var must not contain NaN values")
  }
  if (anyNA(mean) || anyNA(var)) {
    stop("mean and var must not contain NA values")
  }
  if (any(is.infinite(mean)) || any(is.infinite(var))) {
    stop("mean and var must not contain infinite values")
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
    validate_cor_mat(cor_mat, num_tasks)

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
#' @return Invisibly returns `x`.
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
#' @export
#' @method print smm
print.smm <- function(x, ...) {
  cat("Second Moment Method Results:\n")
  cat("------------------------------\n")
  cat("Total Mean: ", x$total_mean, "\n")
  cat("Total Variance: ", x$total_var, "\n")
  cat("Total Standard Deviation: ", x$total_std, "\n")
  invisible(x)
}


#' Summarize Second Moment Method results.
#'
#' Summarizes the propagated moments and reports the percentiles implied by a
#' normal approximation.
#'
#' The Second Moment Method constrains only the first two moments of the total,
#' so the percentiles reported here are those of the normal distribution with
#' that mean and variance. This is the maximum-entropy distribution consistent
#' with what SMM computes, but it is an approximation: durations and costs are
#' non-negative while the normal is not, so the lower percentiles are unreliable
#' when `total_mean` is less than roughly three standard deviations. Use
#' [mcs()] when the shape of the distribution matters.
#'
#' @param object An object of class `"smm"`.
#' @param conf_level Unused placeholder retained for symmetry; percentiles are
#'   fixed at P5/P50/P95.
#' @param ... Additional arguments (not used).
#' @return An object of class `"summary.smm"`, a list with components:
#'   \describe{
#'     \item{total_mean, total_variance, total_sd}{Propagated moments. Note the
#'       canonical names, which match those used by [summary.mcs()]; the `smm`
#'       object itself carries `total_var` and `total_std`.}
#'     \item{cv}{Coefficient of variation. `NA` when the mean is zero.}
#'     \item{percentiles}{Named numeric vector of the P5, P50 and P95
#'       percentiles implied by the normal approximation.}
#'   }
#' @srrstats {G1.4} *Documented with roxygen2.*
#' @examples
#' result <- smm(c(10, 15, 20), c(4, 9, 16))
#' summary(result)
#' @export
#' @method summary smm
summary.smm <- function(object, conf_level = 0.95, ...) {
  sd <- object$total_std
  probs <- c(0.05, 0.50, 0.95)
  percentiles <- if (is.finite(sd) && sd >= 0) {
    stats::setNames(
      stats::qnorm(probs, mean = object$total_mean, sd = sd),
      paste0(probs * 100, "%")
    )
  } else {
    stats::setNames(rep(NA_real_, length(probs)), paste0(probs * 100, "%"))
  }

  result <- list(
    total_mean = object$total_mean,
    total_variance = object$total_var,
    total_sd = sd,
    cv = if (isTRUE(object$total_mean != 0)) sd / object$total_mean else NA_real_,
    percentiles = percentiles
  )
  class(result) <- "summary.smm"
  result
}


#' Print a Second Moment Method summary.
#'
#' @param x An object of class `"summary.smm"` returned by [summary.smm()].
#' @param ... Additional arguments (not used).
#' @return Invisibly returns `x`.
#' @examples
#' print(summary(smm(c(10, 15, 20), c(4, 9, 16))))
#' @export
#' @method print summary.smm
print.summary.smm <- function(x, ...) {
  cat("Second Moment Method Summary\n")
  cat("------------------------------\n")
  cat("Total Mean: ", x$total_mean, "\n")
  cat("Total Variance: ", x$total_variance, "\n")
  cat("Total Standard Deviation: ", x$total_sd, "\n")
  cat("Coefficient of Variation: ",
      format(round(x$cv, 4), scientific = FALSE), "\n\n")
  cat("Percentiles (normal approximation):\n")
  print(x$percentiles)
  invisible(x)
}


#' Plot Second Moment Method results.
#'
#' Displays the normal density implied by the propagated mean and standard
#' deviation, with the P50 and P95 percentiles marked.
#'
#' The Second Moment Method constrains only two moments, so this curve is the
#' maximum-entropy distribution consistent with them rather than an estimate of
#' the true distribution's shape. The left tail is an artifact when
#' `total_mean` is less than roughly three standard deviations, since costs and
#' durations are non-negative and the normal is not. Use [plot.mcs()] on a
#' [mcs()] result when the shape matters.
#'
#' @param x An object of class `"smm"`.
#' @param main Optional plot title. If `NULL`, a default title is generated.
#' @param col Fill color under the density curve. If `NULL`, uses the package
#'   palette.
#' @param xlab Optional x-axis label.
#' @param ... Additional arguments passed to [graphics::plot()].
#' @return Invisibly returns `x`.
#' @importFrom graphics polygon abline legend lines
#' @srrstats {G1.4} *Documented with roxygen2.*
#' @examples
#' plot(smm(c(10, 15, 20), c(4, 9, 16)))
#' @export
#' @method plot smm
plot.smm <- function(x, main = NULL, col = NULL, xlab = NULL, ...) {
  sd <- x$total_std
  if (!is.finite(sd) || sd <= 0) {
    message("Nothing to plot: total variance is zero or undefined.")
    return(invisible(x))
  }
  pal <- pra_cols()
  if (is.null(col)) col <- unname(pal["fill_alpha"])
  if (is.null(main)) main <- "Second Moment Method: implied normal"
  if (is.null(xlab)) xlab <- "Total Project Duration/Cost"

  xs <- seq(x$total_mean - 3.5 * sd, x$total_mean + 3.5 * sd, length.out = 200)
  ys <- stats::dnorm(xs, mean = x$total_mean, sd = sd)

  graphics::plot(xs, ys,
    type = "n", main = main, xlab = xlab, ylab = "Density", ...
  )
  graphics::polygon(c(xs[1], xs, xs[length(xs)]), c(0, ys, 0),
    col = col, border = NA
  )
  graphics::lines(xs, ys, col = unname(pal["ink"]), lwd = 2)

  qs <- stats::qnorm(c(0.50, 0.95), mean = x$total_mean, sd = sd)
  graphics::abline(v = qs, col = unname(pal[c("p50", "p95")]), lty = 2, lwd = 1.5)
  graphics::legend("topright",
    legend = c("Implied normal", "P50", "P95"),
    col = unname(pal[c("ink", "p50", "p95")]),
    lty = c(1, 2, 2), lwd = c(2, 1.5, 1.5), cex = 0.8, bg = "white"
  )
  invisible(x)
}
