#' @srrstats {G5.2} *Error and warning behaviour is explicitly demonstrated through tests.*
#' @srrstats {G5.2a} *Every error message is unique and tested.*
#' @srrstats {G5.2b} *Tests trigger every error message and compare with expected values.*
#' @srrstats {G5.3} *Return objects tested for absence of NA, NaN, Inf.*
#' @srrstats {G5.6} *Parameter recovery tests verify implementations produce expected results given data with known properties.*
#' @srrstats {G5.6a} *Parameter recovery tests succeed within defined tolerance rather than exact values.*
#' @srrstats {G5.6b} *Parameter recovery tests run with multiple random seeds when randomness is involved.*

test_that("mcs function works correctly with different distribution types", {
  set.seed(123) # Set seed for reproducibility

  # Test with normal distribution
  normal_dist <- list(list(type = "normal", mean = 10, sd = 2))
  result <- mcs(1000, normal_dist)
  expect_true(is.list(result))

  # Test with triangular distribution
  triangular_dist <- list(list(type = "triangular", a = 5, b = 10, c = 15))
  result <- mcs(1000, triangular_dist)
  expect_true(is.list(result))

  # Test with uniform distribution
  uniform_dist <- list(list(type = "uniform", min = 5, max = 15))
  result <- mcs(1000, uniform_dist)
  expect_true(is.list(result))
})

test_that("mcs function handles correlation matrix correctly", {
  set.seed(123) # Set seed for reproducibility

  # Test with correlation matrix
  normal_dist <- list(
    list(type = "normal", mean = 10, sd = 2),
    list(type = "normal", mean = 20, sd = 3)
  )
  cor_mat <- matrix(c(1, 0.8, 0.8, 1), nrow = 2)
  result <- mcs(1000, normal_dist, cor_mat)
  expect_true(is.list(result))
})

test_that("mcs function calculates statistics correctly", {
  set.seed(123) # Set seed for reproducibility

  # Test with normal distribution
  normal_dist <- list(list(type = "normal", mean = 10, sd = 2))
  result <- mcs(1000, normal_dist)
  expect_true(is.numeric(result$total_mean))
  expect_true(is.numeric(result$total_variance))
  expect_true(is.numeric(result$total_sd))
  expect_true(is.numeric(result$percentiles))
})

test_that("mcs function handles errors correctly", {
  set.seed(123) # Set seed for reproducibility

  # Test unsupported distribution type
  unsupported_dist <- list(list(type = "unsupported", mean = 10, sd = 2))
  expect_error(mcs(1000, unsupported_dist), "Unsupported distribution type.")

  # Test incorrect correlation matrix
  normal_dist <- list(
    list(type = "normal", mean = 10, sd = 2),
    list(type = "normal", mean = 20, sd = 3)
  )
  incorrect_cor_mat <- matrix(c(1, 0.8), nrow = 1)
  expect_error(mcs(1000, normal_dist, incorrect_cor_mat), "The correlation matrix must be square and match the number of tasks.")
})

test_that("mcs function validates num_sims correctly", {
  normal_dist <- list(list(type = "normal", mean = 10, sd = 2))

  # Test NULL num_sims
  expect_error(mcs(NULL, normal_dist), "num_sims and task_dists must not be NULL")

  # Test non-numeric num_sims
  expect_error(mcs("1000", normal_dist), "num_sims must be a single positive integer")

  # Test negative num_sims
  expect_error(mcs(-100, normal_dist), "num_sims must be a positive integer")

  # Test zero num_sims
  expect_error(mcs(0, normal_dist), "num_sims must be a positive integer")

  # Test non-integer num_sims
  expect_error(mcs(100.5, normal_dist), "num_sims must be a positive integer")

  # Test NA num_sims
  expect_error(mcs(NA, normal_dist), "num_sims must be a single positive integer")
})

test_that("mcs function validates task_dists correctly", {
  # Test NULL task_dists
  expect_error(mcs(1000, NULL), "num_sims and task_dists must not be NULL")

  # Test empty task_dists
  expect_error(mcs(1000, list()), "task_dists must be a non-empty list")

  # Test non-list task_dists
  expect_error(mcs(1000, "not a list"), "task_dists must be a non-empty list")
})

# ============================================================================
# NaN/NA/Inf Error Tests (G5.2, G5.2b)
# ============================================================================
test_that("mcs rejects NaN num_sims", {
  normal_dist <- list(list(type = "normal", mean = 10, sd = 2))
  expect_error(mcs(NaN, normal_dist), "num_sims must not be NaN")
})

test_that("mcs rejects NA_real_ num_sims", {
  normal_dist <- list(list(type = "normal", mean = 10, sd = 2))
  expect_error(mcs(NA_real_, normal_dist), "num_sims must not be NA")
})

test_that("mcs rejects Inf num_sims", {
  normal_dist <- list(list(type = "normal", mean = 10, sd = 2))
  expect_error(mcs(Inf, normal_dist), "num_sims must not be infinite")
})

test_that("mcs rejects NaN in cor_mat", {
  normal_dist <- list(
    list(type = "normal", mean = 10, sd = 2),
    list(type = "normal", mean = 20, sd = 3)
  )
  cor_mat <- matrix(c(1, NaN, NaN, 1), nrow = 2)
  expect_error(mcs(100, normal_dist, cor_mat), "cor_mat must not contain NaN values")
})

test_that("mcs rejects NA in cor_mat", {
  normal_dist <- list(
    list(type = "normal", mean = 10, sd = 2),
    list(type = "normal", mean = 20, sd = 3)
  )
  cor_mat <- matrix(c(1, NA, NA, 1), nrow = 2)
  expect_error(mcs(100, normal_dist, cor_mat), "cor_mat must not contain NA values")
})

test_that("mcs rejects Inf in cor_mat", {
  normal_dist <- list(
    list(type = "normal", mean = 10, sd = 2),
    list(type = "normal", mean = 20, sd = 3)
  )
  cor_mat <- matrix(c(1, Inf, Inf, 1), nrow = 2)
  expect_error(mcs(100, normal_dist, cor_mat), "cor_mat must not contain infinite values")
})

# ============================================================================
# G5.3: Return value tests
# ============================================================================
test_that("mcs result components contain no NA, NaN, or Inf", {
  set.seed(42)
  normal_dist <- list(list(type = "normal", mean = 10, sd = 2))
  result <- mcs(100, normal_dist)

  expect_false(is.na(result$total_mean))
  expect_false(is.nan(result$total_mean))
  expect_false(is.infinite(result$total_mean))

  expect_false(is.na(result$total_variance))
  expect_false(is.nan(result$total_variance))
  expect_false(is.infinite(result$total_variance))

  expect_false(is.na(result$total_sd))
  expect_false(is.nan(result$total_sd))
  expect_false(is.infinite(result$total_sd))

  expect_false(anyNA(result$percentiles))
  expect_false(any(is.nan(result$percentiles)))
  expect_false(any(is.infinite(result$percentiles)))

  expect_false(anyNA(result$total_distribution))
  expect_false(any(is.nan(result$total_distribution)))
  expect_false(any(is.infinite(result$total_distribution)))
})

test_that("mcs print method works correctly", {
  set.seed(123)
  normal_dist <- list(list(type = "normal", mean = 10, sd = 2))
  result <- mcs(100, normal_dist)

  expect_output(print(result), "Monte Carlo Simulation Results:")
  expect_output(print(result), "Total Mean:")
  expect_output(print(result), "Total Variance:")
})

# ============================================================================
# Parameter Recovery Tests (G5.6, G5.6a, G5.6b)
# ============================================================================

test_that("mcs converges to theoretical mean for normal distribution (seed 123)", {
  set.seed(123)

  # Large sample size for convergence
  num_sims <- 100000
  task_dists <- list(
    list(type = "normal", mean = 10, sd = 2),
    list(type = "normal", mean = 15, sd = 3)
  )

  result <- mcs(num_sims, task_dists)

  # Expected mean = sum of individual means (no correlation)
  expected_mean <- 10 + 15

  # With large N, sample mean should converge to theoretical mean
  expect_equal(result$total_mean, expected_mean, tolerance = 0.1)
})

test_that("mcs converges to theoretical mean for normal distribution (seed 42)", {
  set.seed(42)

  # Same test with different seed (G5.6b)
  num_sims <- 100000
  task_dists <- list(
    list(type = "normal", mean = 10, sd = 2),
    list(type = "normal", mean = 15, sd = 3)
  )

  result <- mcs(num_sims, task_dists)
  expected_mean <- 10 + 15

  expect_equal(result$total_mean, expected_mean, tolerance = 0.1)
})

test_that("mcs converges to theoretical variance for independent tasks (seed 123)", {
  set.seed(123)

  num_sims <- 100000
  task_dists <- list(
    list(type = "normal", mean = 10, sd = 2),
    list(type = "normal", mean = 15, sd = 3)
  )

  result <- mcs(num_sims, task_dists)

  # Expected variance = sum of individual variances (independent)
  expected_var <- 2^2 + 3^2  # 4 + 9 = 13

  expect_equal(result$total_variance, expected_var, tolerance = 0.2)
})

test_that("mcs converges to theoretical variance for independent tasks (seed 789)", {
  set.seed(789)

  # Third seed for G5.6b coverage
  num_sims <- 100000
  task_dists <- list(
    list(type = "normal", mean = 10, sd = 2),
    list(type = "normal", mean = 15, sd = 3)
  )

  result <- mcs(num_sims, task_dists)
  expected_var <- 2^2 + 3^2

  expect_equal(result$total_variance, expected_var, tolerance = 0.2)
})

test_that("mcs with high correlation produces higher variance", {
  set.seed(123)

  num_sims <- 10000
  task_dists <- list(
    list(type = "normal", mean = 10, sd = 2),
    list(type = "normal", mean = 15, sd = 3)
  )
  # High correlation (0.99 instead of 1.0 to avoid singularity)
  cor_mat <- matrix(c(1, 0.99, 0.99, 1), nrow = 2)

  result <- mcs(num_sims, task_dists, cor_mat)

  # With high correlation, variance should be larger than independent case
  # Var(X + Y) = Var(X) + Var(Y) + 2*Cov(X,Y)
  # When cor=0.99: Cov(X,Y) ≈ SD(X)*SD(Y)*0.99 = 2*3*0.99 = 5.94
  expected_var_approx <- 4 + 9 + 2*5.94  # ≈ 24.88

  expect_equal(result$total_variance, expected_var_approx, tolerance = 0.5)
})
