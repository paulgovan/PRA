#' @srrstats {G5.1} *The `building_project` dataset used in examples and the
#'   documentation is exported and documented so tests can be reproduced.*

test_that("building_project has the documented structure", {
  data("building_project", package = "PRA")
  bp <- building_project
  expect_type(bp, "list")

  # Six work packages, consistent across components.
  expect_length(bp$task_names, 6)
  expect_length(bp$task_distributions, 6)
  expect_equal(dim(bp$cor_mat), c(6, 6))
  expect_equal(dim(bp$resource_task), c(6, 6))

  # Each task distribution is a valid triangular spec (a < b < c).
  for (d in bp$task_distributions) {
    expect_identical(d$type, "triangular")
    expect_true(d$a < d$b && d$b < d$c)
  }

  # Risk register components are aligned.
  k <- length(bp$cause_probs)
  expect_length(bp$risks_given_causes, k)
  expect_length(bp$risks_given_not_causes, k)
  expect_length(bp$observed_causes, k)
  expect_equal(nrow(bp$risk_resource), length(bp$risk_names))
  expect_equal(ncol(bp$risk_resource), length(bp$resource_names))
})

test_that("building_project drives the core PRA workflow", {
  bp <- building_project
  set.seed(42)

  sim <- mcs(2000, bp$task_distributions)
  expect_s3_class(sim, "mcs")

  pv1 <- pv(bp$bac, bp$schedule, bp$time_period)
  ev1 <- ev(bp$bac, bp$actual_per_complete)
  expect_true(is.finite(spi(ev1, pv1)))

  prior <- risk_prob(bp$cause_probs, bp$risks_given_causes,
                     bp$risks_given_not_causes)
  post  <- risk_post_prob(bp$cause_probs, bp$risks_given_causes,
                          bp$risks_given_not_causes, bp$observed_causes)
  expect_true(prior >= 0 && prior <= 1)
  expect_true(post  >= 0 && post  <= 1)
  # Observing the adverse cause (weather) raises the posterior.
  expect_gt(post, prior)

  g <- grandparent_dsm(bp$resource_task, bp$risk_resource)
  expect_s3_class(g, "dsm")
})
