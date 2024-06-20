test_that("sensitivity function calculates correctly for normal distributions", {
  normal_dists <- list(
    list(type = "normal", mean = 10, sd = 2),
    list(type = "normal", mean = 20, sd = 3)
  )
  result <- sensitivity(normal_dists)
  expect_true(is.numeric(result))
  expect_length(result, 2)

  # Expected variances
  expected_variances <- sapply(normal_dists, function(dist) dist$sd^2)
  expected_sensitivity <- 1 + 2 * 0 # Since there is no correlation matrix provided

  expect_equal(result[1], expected_sensitivity)
  expect_equal(result[2], expected_sensitivity)
})

test_that("sensitivity function calculates correctly for triangular distributions", {
  triangular_dists <- list(
    list(type = "triangular", a = 1, b = 3, c = 5),
    list(type = "triangular", a = 2, b = 4, c = 6)
  )
  result <- sensitivity(triangular_dists)
  expect_true(is.numeric(result))
  expect_length(result, 2)
})

test_that("sensitivity function calculates correctly for uniform distributions", {
  uniform_dists <- list(
    list(type = "uniform", min = 1, max = 5),
    list(type = "uniform", min = 2, max = 6)
  )
  result <- sensitivity(uniform_dists)
  expect_true(is.numeric(result))
  expect_length(result, 2)
})

test_that("sensitivity function handles correlation matrix correctly", {
  normal_dists <- list(
    list(type = "normal", mean = 10, sd = 2),
    list(type = "normal", mean = 20, sd = 3)
  )
  cor_mat <- matrix(c(1, 0.8, 0.8, 1), nrow = 2)
  result <- sensitivity(normal_dists, cor_mat)
  expect_true(is.numeric(result))
  expect_length(result, 2)
})

test_that("sensitivity function handles errors correctly", {
  normal_dists <- list(
    list(type = "normal", mean = 10, sd = 2),
    list(type = "normal", mean = 20, sd = 3)
  )

  # Unsupported distribution type
  unsupported_dists <- list(list(type = "unsupported", mean = 10, sd = 2))
  expect_error(sensitivity(unsupported_dists), "Unsupported distribution type.")

  # Incorrect correlation matrix
  incorrect_cor_mat <- matrix(c(1, 0.8), nrow = 1)
  expect_error(sensitivity(normal_dists, incorrect_cor_mat), "The correlation matrix must be square and match the number of tasks.")
})
