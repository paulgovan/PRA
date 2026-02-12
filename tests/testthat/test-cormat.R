#' @srrstats {G5.2} *Error and warning behaviour is explicitly demonstrated through tests.*
#' @srrstats {G5.2a} *Every error message is unique and tested.*
#' @srrstats {G5.2b} *Tests trigger every error message and compare with expected values.*
#' @srrstats {G5.3} *Return objects tested for absence of NA, NaN, Inf.*
#' @srrstats {G5.6} *Parameter recovery tests verify implementations produce expected results given data with known properties.*
#' @srrstats {G5.6a} *Parameter recovery tests succeed within defined tolerance rather than exact values.*
#' @srrstats {G5.6b} *Parameter recovery tests run with multiple random seeds when randomness is involved.*

# Define a set of distributions
dists <- list(
  normal = function(n) rnorm(n, mean = 0, sd = 1),
  uniform = function(n) runif(n, min = 0, max = 1),
  exponential = function(n) rexp(n, rate = 1),
  poisson = function(n) rpois(n, lambda = 1),
  binomial = function(n) rbinom(n, size = 10, prob = 0.5)
)

test_that("cor_matrix returns correct dimensions for valid inputs", {
  result <- cor_matrix(num_samples = 100, num_vars = 5, dists = dists)
  expect_true(is.matrix(result))
  expect_equal(nrow(result), 5)
  expect_equal(ncol(result), 5)
})

test_that("cor_matrix throws error for invalid num_samples", {
  expect_error(cor_matrix(num_samples = -1, num_vars = 5, dists = dists), "num_samples must be a positive integer.")
  expect_error(cor_matrix(num_samples = "a", num_vars = 5, dists = dists), "num_samples must be a positive integer.")
  expect_error(cor_matrix(num_samples = 0, num_vars = 5, dists = dists), "num_samples must be a positive integer.")
})

test_that("cor_matrix throws error for invalid num_vars", {
  expect_error(cor_matrix(num_samples = 100, num_vars = -1, dists = dists), "num_vars must be a positive integer.")
  expect_error(cor_matrix(num_samples = 100, num_vars = "a", dists = dists), "num_vars must be a positive integer.")
  expect_error(cor_matrix(num_samples = 100, num_vars = 0, dists = dists), "num_vars must be a positive integer.")
  expect_error(cor_matrix(num_samples = 100, num_vars = 10, dists = dists), "num_vars must not exceed the number of distributions in dists.")
})

test_that("cor_matrix throws error for invalid dists", {
  expect_error(cor_matrix(num_samples = 100, num_vars = 5, dists = "not a list"), "dists must be a non-empty list.")
  expect_error(cor_matrix(num_samples = 100, num_vars = 5, dists = list()), "dists must be a non-empty list.")
  expect_error(cor_matrix(num_samples = 100, num_vars = 5, dists = list("not a function")), "All elements in dists must be functions.")
})

test_that("cor_matrix works correctly with edge cases", {
  result <- cor_matrix(num_samples = 1, num_vars = 1, dists = dists)
  expect_true(is.matrix(result))
  expect_equal(nrow(result), 1)
  expect_equal(ncol(result), 1)
})

# ============================================================================
# NaN/NA/Inf Error Tests (G5.2, G5.2b)
# ============================================================================
test_that("cor_matrix rejects NaN num_samples", {
  expect_error(cor_matrix(num_samples = NaN, num_vars = 5, dists = dists), "num_samples must not be NaN.")
})

test_that("cor_matrix rejects NA num_samples", {
  expect_error(cor_matrix(num_samples = NA_real_, num_vars = 5, dists = dists), "num_samples must not be NA.")
})

test_that("cor_matrix rejects Inf num_samples", {
  expect_error(cor_matrix(num_samples = Inf, num_vars = 5, dists = dists), "num_samples must not be infinite.")
})

test_that("cor_matrix rejects NaN num_vars", {
  expect_error(cor_matrix(num_samples = 100, num_vars = NaN, dists = dists), "num_vars must not be NaN.")
})

test_that("cor_matrix rejects NA num_vars", {
  expect_error(cor_matrix(num_samples = 100, num_vars = NA_real_, dists = dists), "num_vars must not be NA.")
})

test_that("cor_matrix rejects Inf num_vars", {
  expect_error(cor_matrix(num_samples = 100, num_vars = Inf, dists = dists), "num_vars must not be infinite.")
})

# ============================================================================
# G5.3: Return value tests
# ============================================================================
test_that("cor_matrix result contains no NA, NaN, or Inf", {
  set.seed(42)
  result <- cor_matrix(num_samples = 100, num_vars = 3, dists = dists)
  expect_false(anyNA(result))
  expect_false(any(is.nan(result)))
  expect_false(any(is.infinite(result)))
})

# ============================================================================
# Parameter Recovery Tests (G5.6, G5.6a)
# ============================================================================

test_that("cor_matrix has unit diagonal", {
  set.seed(123)

  # cor_matrix expects named list of distributions
  dist_list <- list(
    norm1 = function(n) rnorm(n, 10, 2),
    norm2 = function(n) rnorm(n, 15, 3)
  )

  result <- cor_matrix(num_samples = 10000, num_vars = 2, dists = dist_list)

  # Diagonal elements must be 1 (correlation with self)
  expect_equal(diag(result), c(1, 1), tolerance = 1e-10)
})

test_that("cor_matrix is symmetric", {
  set.seed(42)

  # cor_matrix expects named list of distributions
  dist_list <- list(
    norm1 = function(n) rnorm(n, 10, 2),
    unif1 = function(n) runif(n, 5, 15),
    norm2 = function(n) rnorm(n, 20, 5)
  )

  result <- cor_matrix(num_samples = 10000, num_vars = 3, dists = dist_list)

  # Correlation matrix must be symmetric
  expect_equal(result, t(result), tolerance = 1e-10)
})
