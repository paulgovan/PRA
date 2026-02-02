test_that("risk_post_prob handles fully observed causes", {
  cause_probs <- c(0.3, 0.2)
  risks_given_causes <- c(0.8, 0.6)
  risks_given_not_causes <- c(0.2, 0.4)
  observed_causes <- c(1, 0)

  result <- risk_post_prob(cause_probs, risks_given_causes, risks_given_not_causes, observed_causes)
  expect_true(is.numeric(result))
  expect_true(result >= 0 && result <= 1)
})

test_that("risk_post_prob handles partially observed causes", {
  cause_probs <- c(0.3, 0.2, 0.5)
  risks_given_causes <- c(0.8, 0.6, 0.7)
  risks_given_not_causes <- c(0.2, 0.4, 0.3)
  observed_causes <- c(1, NA, 0)

  result <- risk_post_prob(cause_probs, risks_given_causes, risks_given_not_causes, observed_causes)
  expect_true(is.numeric(result))
  expect_true(result >= 0 && result <= 1)
})

test_that("cost_post_pdf generates valid samples", {
  num_sims <- 1000
  observed_risks <- c(1, NA, 1)
  means_given_risks <- c(10000, 15000, 5000)
  sds_given_risks <- c(2000, 1000, 1000)
  base_cost <- 2000

  samples <- cost_post_pdf(num_sims, observed_risks, means_given_risks, sds_given_risks, base_cost)
  expect_equal(length(samples), num_sims)
  expect_true(all(is.numeric(samples)))
})

test_that("cost_post_pdf handles no observed risks", {
  num_sims <- 1000
  observed_risks <- c(NA, NA, NA)
  means_given_risks <- c(10000, 15000, 5000)
  sds_given_risks <- c(2000, 1000, 1000)
  base_cost <- 2000

  samples <- cost_post_pdf(num_sims, observed_risks, means_given_risks, sds_given_risks, base_cost)
  expect_equal(length(samples), num_sims)
  expect_true(all(samples == base_cost))
})

# Error handling tests for risk_post_prob
test_that("risk_post_prob validates input vector lengths", {
  expect_error(
    risk_post_prob(c(0.3), c(0.8, 0.6), c(0.2, 0.4), c(1, 0)),
    "All input vectors must have the same length."
  )
})

test_that("risk_post_prob validates probability ranges", {
  expect_error(
    risk_post_prob(c(0.3, 1.5), c(0.8, 0.6), c(0.2, 0.4), c(1, 0)),
    "All values in cause_probs must be between 0 and 1."
  )
  expect_error(
    risk_post_prob(c(0.3, 0.2), c(0.8, 1.6), c(0.2, 0.4), c(1, 0)),
    "All values in risks_given_causes must be between 0 and 1."
  )
  expect_error(
    risk_post_prob(c(0.3, 0.2), c(0.8, 0.6), c(0.2, -0.4), c(1, 0)),
    "All values in risks_given_not_causes must be between 0 and 1."
  )
})

test_that("risk_post_prob validates observed_causes values", {
  expect_error(
    risk_post_prob(c(0.3, 0.2), c(0.8, 0.6), c(0.2, 0.4), c(1, 2)),
    "All values in observed_causes must be 0, 1, or NA."
  )
})

# Error handling tests for cost_post_pdf
test_that("cost_post_pdf validates num_sims", {
  expect_error(
    cost_post_pdf(-100, c(1, 0), c(10000, 15000), c(2000, 1000), 2000),
    "num_sims must be a positive integer."
  )
  expect_error(
    cost_post_pdf("not a number", c(1, 0), c(10000, 15000), c(2000, 1000), 2000),
    "num_sims must be a positive integer."
  )
})

test_that("cost_post_pdf validates observed_risks values", {
  expect_error(
    cost_post_pdf(1000, c(1, 2), c(10000, 15000), c(2000, 1000), 2000),
    "All values in observed_risks must be 0, 1, or NA."
  )
})

test_that("cost_post_pdf validates vector lengths", {
  expect_error(
    cost_post_pdf(1000, c(1, 0, 1), c(10000, 15000), c(2000, 1000), 2000),
    "observed_risks, means_given_risks, and sds_given_risks must have the same length."
  )
})

test_that("cost_post_pdf validates non-negative standard deviations", {
  expect_error(
    cost_post_pdf(1000, c(1, 0), c(10000, 15000), c(2000, -1000), 2000),
    "Standard deviations must be non-negative."
  )
})

test_that("risk_post_prob handles all observed causes correctly", {
  cause_probs <- c(0.3, 0.2)
  risks_given_causes <- c(0.8, 0.6)
  risks_given_not_causes <- c(0.2, 0.4)
  observed_causes <- c(1, 1)

  result <- risk_post_prob(cause_probs, risks_given_causes, risks_given_not_causes, observed_causes)
  expect_true(is.numeric(result))
  expect_true(result >= 0 && result <= 1)
})

test_that("cost_post_pdf handles zero observed risks correctly", {
  num_sims <- 1000
  observed_risks <- c(0, 0, 0)
  means_given_risks <- c(10000, 15000, 5000)
  sds_given_risks <- c(2000, 1000, 1000)
  base_cost <- 2000

  samples <- cost_post_pdf(num_sims, observed_risks, means_given_risks, sds_given_risks, base_cost)
  expect_equal(length(samples), num_sims)
  expect_true(all(samples == base_cost))
})
