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
