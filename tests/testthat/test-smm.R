#' @srrstats {G5.2} *Error and warning behaviour is explicitly demonstrated through tests.*
#' @srrstats {G5.2a} *Every error message is unique and tested.*
#' @srrstats {G5.2b} *Tests trigger every error message and compare with expected values.*
#' @srrstats {G5.3} *Return objects tested for absence of NA, NaN, Inf.*

test_that("second moment analysis works without correlation matrix", {
  mean <- c(10, 15, 20)
  var <- c(4, 9, 16)
  results <- smm(mean, var)

  expect_equal(results$total_mean, 10 + 15 + 20)
  expect_equal(results$total_std, sqrt(4 + 9 + 16))
})

test_that("second moment analysis works with correlation matrix", {
  mean <- c(10, 15, 20)
  var <- c(4, 9, 16)

  cor_mat <- matrix(c(
    1, 0.5, 0.3,
    0.5, 1, 0.4,
    0.3, 0.4, 1
  ), nrow = 3, byrow = TRUE)

  results <- smm(mean, var, cor_mat)

  task_variances <- c(4, 9, 16)

  cov_matrix <- matrix(0, nrow = 3, ncol = 3)
  for (i in 1:3) {
    for (j in 1:3) {
      cov_matrix[i, j] <- cor_mat[i, j] * sqrt(task_variances[i] * task_variances[j])
    }
  }

  total_variance <- sum(task_variances) + sum(cov_matrix[upper.tri(cov_matrix)] * 2)

  expect_equal(results$total_mean, 10 + 15 + 20)
  expect_equal(results$total_std, sqrt(total_variance))
})

test_that("smm validates NULL inputs correctly", {
  var <- c(4, 9, 16)
  mean <- c(10, 15, 20)

  expect_error(smm(NULL, var), "mean and var must not be NULL")
  expect_error(smm(mean, NULL), "mean and var must not be NULL")
})

test_that("smm validates numeric inputs correctly", {
  mean <- c(10, 15, 20)
  var <- c(4, 9, 16)

  expect_error(smm("not numeric", var), "mean and var must be numeric vectors")
  expect_error(smm(mean, "not numeric"), "mean and var must be numeric vectors")
})

test_that("smm validates empty vectors correctly", {
  # Note: c() returns NULL in R, so it triggers the NULL check first
  expect_error(smm(c(), c(1, 2, 3)), "mean and var must not be NULL")
  expect_error(smm(c(1, 2, 3), c()), "mean and var must not be NULL")

  # Test with numeric(0) which is truly empty but not NULL
  expect_error(smm(numeric(0), c(1, 2, 3)), "mean and var must not be empty")
  expect_error(smm(c(1, 2, 3), numeric(0)), "mean and var must not be empty")
})

test_that("smm validates NA values correctly", {
  expect_error(smm(c(10, NA, 20), c(4, 9, 16)), "mean and var must not contain NA values")
  expect_error(smm(c(10, 15, 20), c(4, NA, 16)), "mean and var must not contain NA values")
})

test_that("smm validates non-negative variance correctly", {
  expect_error(smm(c(10, 15, 20), c(4, -9, 16)), "var values must be non-negative")
})

test_that("smm validates vector length match correctly", {
  expect_error(smm(c(10, 15), c(4, 9, 16)), "The mean and variance vectors must have the same length.")
})

test_that("smm validates correlation matrix correctly", {
  mean <- c(10, 15, 20)
  var <- c(4, 9, 16)

  # Non-square correlation matrix
  bad_cor_mat <- matrix(c(1, 0.5), nrow = 1)
  expect_error(smm(mean, var, bad_cor_mat), "The correlation matrix must be square and match the number of tasks.")

  # Wrong size correlation matrix
  wrong_size_cor_mat <- matrix(c(1, 0.5, 0.5, 1), nrow = 2)
  expect_error(smm(mean, var, wrong_size_cor_mat), "The correlation matrix must be square and match the number of tasks.")
})

test_that("smm print method works correctly", {
  mean <- c(10, 15, 20)
  var <- c(4, 9, 16)
  result <- smm(mean, var)

  expect_output(print(result), "Second Moment Method Results:")
  expect_output(print(result), "Total Mean:")
  expect_output(print(result), "Total Variance:")
  expect_output(print(result), "Total Standard Deviation:")
})

test_that("smm returns correct class", {
  mean <- c(10, 15, 20)
  var <- c(4, 9, 16)
  result <- smm(mean, var)

  expect_s3_class(result, "smm")
})

# ============================================================================
# NaN/NA/Inf Error Tests (G5.2, G5.2b)
# ============================================================================
test_that("smm rejects NaN in mean/var", {
  expect_error(smm(c(10, NaN, 20), c(4, 9, 16)), "mean and var must not contain NaN values")
  expect_error(smm(c(10, 15, 20), c(4, NaN, 16)), "mean and var must not contain NaN values")
})

test_that("smm rejects Inf in mean/var", {
  expect_error(smm(c(10, Inf, 20), c(4, 9, 16)), "mean and var must not contain infinite values")
  expect_error(smm(c(10, 15, 20), c(4, Inf, 16)), "mean and var must not contain infinite values")
})

test_that("smm rejects NaN in cor_mat", {
  mean <- c(10, 15, 20)
  var <- c(4, 9, 16)
  cor_mat <- matrix(c(1, NaN, 0.3, NaN, 1, 0.4, 0.3, 0.4, 1), nrow = 3)
  expect_error(smm(mean, var, cor_mat), "cor_mat must not contain NaN values")
})

test_that("smm rejects NA in cor_mat", {
  mean <- c(10, 15, 20)
  var <- c(4, 9, 16)
  cor_mat <- matrix(c(1, NA, 0.3, NA, 1, 0.4, 0.3, 0.4, 1), nrow = 3)
  expect_error(smm(mean, var, cor_mat), "cor_mat must not contain NA values")
})

test_that("smm rejects Inf in cor_mat", {
  mean <- c(10, 15, 20)
  var <- c(4, 9, 16)
  cor_mat <- matrix(c(1, Inf, 0.3, Inf, 1, 0.4, 0.3, 0.4, 1), nrow = 3)
  expect_error(smm(mean, var, cor_mat), "cor_mat must not contain infinite values")
})

# ============================================================================
# G5.3: Return value tests
# ============================================================================
test_that("smm result components contain no NA, NaN, or Inf", {
  mean <- c(10, 15, 20)
  var <- c(4, 9, 16)
  result <- smm(mean, var)

  expect_false(is.na(result$total_mean))
  expect_false(is.nan(result$total_mean))
  expect_false(is.infinite(result$total_mean))

  expect_false(is.na(result$total_var))
  expect_false(is.nan(result$total_var))
  expect_false(is.infinite(result$total_var))

  expect_false(is.na(result$total_std))
  expect_false(is.nan(result$total_std))
  expect_false(is.infinite(result$total_std))
})
