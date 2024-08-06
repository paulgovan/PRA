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
