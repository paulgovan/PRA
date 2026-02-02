# Unit tests for risk_prob function
test_that("risk_prob calculates correct risk probabilities", {
  cause_probs <- c(0.3, 0.2)
  risks_given_causes <- c(0.8, 0.6)
  risks_given_not_causes <- c(0.2, 0.4)

  result <- risk_prob(cause_probs, risks_given_causes, risks_given_not_causes)
  expected <- (0.3 * 0.8) + ((1 - 0.3) * 0.2) + (0.2 * 0.6) + ((1 - 0.2) * 0.4)
  expect_equal(result, expected)
})

test_that("risk_prob handles input validation correctly", {
  expect_error(risk_prob(c(0.3, 1.2), c(0.8, 0.6), c(0.2, 0.4)), "All values in cause_probs must be between 0 and 1.")
  expect_error(risk_prob(c(0.3, 0.2), c(0.8, 1.6), c(0.2, 0.4)), "All values in risks_given_causes must be between 0 and 1.")
  expect_error(risk_prob(c(0.3, 0.2), c(0.8, 0.6), c(0.2, -0.4)), "All values in risks_given_not_causes must be between 0 and 1.")
  expect_error(risk_prob(c(0.3, 0.2), c(0.8), c(0.2, 0.4)), "All input vectors must have the same length.")
})

# Unit tests for cost_pdf function
test_that("cost_pdf generates correct sample sizes", {
  num_sims <- 1000
  risk_probs <- c(0.3, 0.5)
  means_given_risks <- c(10000, 15000)
  sds_given_risks <- c(2000, 1000)
  base_cost <- 2000

  samples <- cost_pdf(num_sims, risk_probs, means_given_risks, sds_given_risks, base_cost)
  expect_equal(length(samples), num_sims)
})

test_that("cost_pdf handles input validation correctly", {
  expect_error(cost_pdf(-1000, c(0.3, 0.5), c(10000, 15000), c(2000, 1000), 2000), "num_sims must be a positive integer.")
  expect_error(cost_pdf(1000, c(0.3, 1.5), c(10000, 15000), c(2000, 1000), 2000), "All risk_probs must be between 0 and 1.")
  expect_error(cost_pdf(1000, c(0.3, 0.5), c(10000), c(2000, 1000), 2000), "risk_probs, means_given_risks, and sds_given_risks must have the same length.")
  expect_error(cost_pdf(1000, c(0.3, 0.5), c(10000, 15000), c(2000, -1000), 2000), "Standard deviations must be non-negative.")
})

test_that("cost_pdf generates realistic samples", {
  num_sims <- 1000
  risk_probs <- c(0.3)
  means_given_risks <- c(10000)
  sds_given_risks <- c(2000)
  base_cost <- 2000

  samples <- cost_pdf(num_sims, risk_probs, means_given_risks, sds_given_risks, base_cost)
  expect_true(all(samples >= base_cost))
  expect_gt(mean(samples), base_cost)
})

# Additional risk_prob tests
test_that("risk_prob handles single cause correctly", {
  cause_probs <- c(0.5)
  risks_given_causes <- c(0.8)
  risks_given_not_causes <- c(0.2)

  result <- risk_prob(cause_probs, risks_given_causes, risks_given_not_causes)
  expected <- (0.5 * 0.8) + (0.5 * 0.2)
  expect_equal(result, expected)
})

test_that("risk_prob handles extreme probabilities correctly", {
  # All causes certain
  cause_probs <- c(1.0, 1.0)
  risks_given_causes <- c(0.8, 0.6)
  risks_given_not_causes <- c(0.2, 0.4)

  result <- risk_prob(cause_probs, risks_given_causes, risks_given_not_causes)
  expect_true(is.numeric(result))

  # No causes
  cause_probs <- c(0.0, 0.0)
  result <- risk_prob(cause_probs, risks_given_causes, risks_given_not_causes)
  expect_true(is.numeric(result))
})

# Additional cost_pdf tests
test_that("cost_pdf handles zero risk probabilities correctly", {
  num_sims <- 1000
  risk_probs <- c(0, 0)
  means_given_risks <- c(10000, 15000)
  sds_given_risks <- c(2000, 1000)
  base_cost <- 2000

  samples <- cost_pdf(num_sims, risk_probs, means_given_risks, sds_given_risks, base_cost)
  expect_equal(length(samples), num_sims)
  expect_true(all(samples == base_cost))
})

test_that("cost_pdf validates sum of risk_probs", {
  expect_error(
    cost_pdf(1000, c(0.6, 0.6), c(10000, 15000), c(2000, 1000), 2000),
    "Sum of risk_probs must not exceed 1."
  )
})

test_that("cost_pdf handles default base_cost correctly", {
  num_sims <- 100
  risk_probs <- c(0)
  means_given_risks <- c(10000)
  sds_given_risks <- c(2000)

  samples <- cost_pdf(num_sims, risk_probs, means_given_risks, sds_given_risks)
  expect_true(all(samples == 0))
})
