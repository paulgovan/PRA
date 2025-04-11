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
