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

test_that("mcs print method works correctly", {
  set.seed(123)
  normal_dist <- list(list(type = "normal", mean = 10, sd = 2))
  result <- mcs(100, normal_dist)

  expect_output(print(result), "Monte Carlo Simulation Results:")
  expect_output(print(result), "Total Mean:")
  expect_output(print(result), "Total Variance:")
})
