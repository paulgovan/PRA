# Define a helper function to generate simulation results for testing
generate_simulation_results <- function() {
  set.seed(123) # Set seed for reproducibility
  num_sims <- 1000
  total_distribution <- rnorm(num_sims, mean = 100, sd = 15)
  list(total_distribution = total_distribution)
}

test_that("contingency function calculates correctly with default percentiles", {
  sims <- generate_simulation_results()
  result <- contingency(sims)
  expect_true(is.numeric(result))

  # Calculate expected values
  expected_phigh_value <- quantile(sims$total_distribution, probs = 0.95)
  expected_pbase_value <- quantile(sims$total_distribution, probs = 0.50)
  expected_contingency <- expected_phigh_value - expected_pbase_value

  expect_equal(result, expected_contingency)
})

test_that("contingency function calculates correctly with custom percentiles", {
  sims <- generate_simulation_results()
  result <- contingency(sims, phigh = 0.90, pbase = 0.10)
  expect_true(is.numeric(result))

  # Calculate expected values
  expected_phigh_value <- quantile(sims$total_distribution, probs = 0.90)
  expected_pbase_value <- quantile(sims$total_distribution, probs = 0.10)
  expected_contingency <- expected_phigh_value - expected_pbase_value

  expect_equal(result, expected_contingency)
})

test_that("contingency function handles edge cases correctly", {
  sims <- generate_simulation_results()

  # phigh is less than pbase (uncommon but should be tested)
  expect_error(contingency(sims, phigh = 0.25, pbase = 0.75), "phigh must be greater than pbase")
})

test_that("contingency function handles invalid input correctly", {
  sims <- generate_simulation_results()

  # Invalid percentile values
  expect_error(contingency(sims, phigh = 1.5, pbase = 0.50), "phigh must be between 0 and 1")
  expect_error(contingency(sims, phigh = 0.95, pbase = -0.5), "pbase must be between 0 and 1")

  # Non-numeric percentiles
  expect_error(contingency(sims, phigh = "high", pbase = 0.50), "phigh must be between 0 and 1")
  expect_error(contingency(sims, phigh = 0.95, pbase = "base"), "pbase must be between 0 and 1")
})
